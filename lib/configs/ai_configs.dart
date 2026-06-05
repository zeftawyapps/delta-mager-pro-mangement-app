import 'package:JoDija_tamplites/util/jsonengen/json_asset_reader.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIConfigs {
  String apiKey = "";
  late GenerativeModel model;
  late GenerateContentResponse response;

  /// Initializes the AI configuration by loading the API key from a JSON asset.
  /// You can pass the path to the asset, e.g., MyConfigAssets.AIKey
  Future<void> aiConfigInit(String assetPath) async {
    apiKey = await getApiKey(assetPath);
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest', // High rate-limits, perfect for development and production
      apiKey: apiKey,
    );
  }

  /// Direct initialization with an API key if you want to pass it from env or settings.
  void aiConfigInitWithKey(String key) {
    apiKey = key;
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
  }

  /// Helper to read the API key from a JSON asset file
  Future<String> getApiKey(String path) async {
    try {
      var data = await JsonAssetReader(path: path).data;
      var aiconfig = data['ai_keys'];
      apiKey = aiconfig['gen_key'];
      return apiKey;
    } catch (e) {
      print("Error loading API Key from assets: $e");
      return "";
    }
  }

  /// Tests the AI connection with a sample prompt
  void aiOperationTest(String assetPath) async {
    String aikey = await getApiKey(assetPath);
    print("API Key retrieved: $aikey");
    final testModel = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: aikey,
    );

    final prompt = ' هذا تطبيق يعبر فيه المستخدم عن مشاعره اريدك ان تكتب لي عبارات اعبر فيها عن حبي لامي بحيث تكون العبارات تبدا '
        ' ب علامة ** وتنتهي بعلامة ** '
        'وتكون العبارات باللغة العربية'
        'قبل كتابة العبارات ابداها برمز @@ '
        'وتنتهي برمز //';

    final content = [Content.text(prompt)];
    final response = await testModel.generateContent(content);
    print("Test Response: ${response.text}");
  }

  /// Generates custom prompt in Arabic
  String getTextPrompt(String prompt) {
    if (prompt == "") {
      prompt = " اريد ان اعبر عن حبي لزوجتي ";
    }

    String mainText = ' هذا تطبيق يعبر فيه المستخدم عن مشاعره ' +
        prompt +
        ' بحيث تكون العبارة تفضل بينها علامة  '
            '  ** '
            'وتكون العبارات باللغة العربية'
            'في حالة عدم فهمك  عبارة ' +
        prompt +
        'ارسل لي عبارة واحدة فقط عن الحب و المشاعر '
            ' بحيث تكون العبارات تفضل بينها علامة  '
            '  ** ';

    return mainText;
  }

  /// Generates custom prompt in English
  String getTextPromptEn(String prompt) {
    if (prompt == "") {
      prompt = "I want to express my love for my wife";
    }

    String mainText = ' This is an application in which the user expresses his feelings ' +
        prompt +
        ' so that the phrase is preferred between the mark '
            '  ** '
            'The phrases are in English '
            'If you do not understand a phrase ' +
        prompt +
        'Send me only one phrase about love and feelings '
            ' so that the phrase is preferred between the mark '
            '  ** ';

    return mainText;
  }

  /// Calls Gemini API with the given prompt
  Future<GenerateContentResponse> aiOperation(String prompt) async {
    final content = [Content.text(prompt)];
    response = await model.generateContent(content);
    return response;
  }

  /// Safely extracts the text from a Gemini response
  String getGeneratedText(GenerateContentResponse response) {
    if (response.text != null) {
      return response.text!;
    } else {
      return "";
    }
  }

  /// Splits the generated text by '**' to get a list of phrases
  List<String> getGeneratedTextList(String text) {
    List<String> textList = [];
    if (response.text != null) {
      textList = response.text!.split("**");
    }
    return textList;
  }
}
