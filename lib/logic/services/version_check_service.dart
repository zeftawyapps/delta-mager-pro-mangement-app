import 'package:JoDija_reposatory/utilis/http_remotes/http_client.dart';
import 'package:JoDija_reposatory/utilis/http_remotes/http_methos_enum.dart';
import 'package:JoDija_reposatory/constes/api_urls.dart';
import 'package:JoDija_reposatory/utilis/models/remote_base_model.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import 'package:dio/dio.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/version_check_result.dart';

class VersionCheckService {
  Future<VersionCheckResult?> checkAppVersion({
    required String currentVersion,
    required int buildIndex,
    required String appType,
    required String platform,
    required String orgId,
  }) async {
    final String url = "${ApiUrls.BASE_URL}/system/version-check";
    try {
      final result = await HttpClient(userToken: false).sendRequest(
        method: HttpMethod.POST,
        url: url,
        body: {
          'currentVersion': currentVersion,
          'buildIndex': buildIndex,
          'appType': appType,
          'platform': platform,
          'organizationId': orgId,
        },
        cancelToken: CancelToken(),
      );

      if (result.data?.status == StatusModel.success) {
        final data = result.data?.data;
        if (data != null) {
          return VersionCheckResult.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      // Direct fallback/print in case of any network issue during version check
      print('Error checking version: $e');
    }
    return null;
  }
}
