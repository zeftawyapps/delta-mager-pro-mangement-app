# ImagePecker - الميزات المتقدمة

## 🎯 الميزات الجديدة

### 1. حساب حجم الصورة تلقائياً
يتم حساب حجم الصورة بثلاث طرق:
- **بالبايت** (`fileSizeInBytes`)
- **بالكيلوبايت** (`fileSizeInKB`)
- **بالميجابايت** (`fileSizeInMB`)
- **نص مقروء** (`readableFileSize`) - يختار الوحدة المناسبة تلقائياً

```dart
ImageFileModel? selectedImage;

ImagePecker(
  onImageSelected: (imageModel) {
    print('حجم الملف: ${imageModel.readableFileSize}');
    print('بالكيلوبايت: ${imageModel.fileSizeInKB} KB');
    print('بالميجابايت: ${imageModel.fileSizeInMB} MB');
  },
)
```

### 2. عرض حجم الملف في الواجهة
```dart
ImagePecker(
  showFileSize: true, // تفعيل عرض حجم الملف (افتراضي: true)
  // ...
)
```

يظهر الحجم في **Badge** ملون أسفل الصورة مباشرة.

### 3. تحديد حد أقصى لحجم الصورة
```dart
ImagePecker(
  maxFileSizeMB: 5.0, // الحد الأقصى 5 ميجابايت
  // ...
)
```

**السلوك:**
- إذا تجاوزت الصورة الحد الأقصى، يتم **رفضها**
- يظهر **SnackBar** تحذيري بلون برتقالي
- يعرض حجم الصورة والحد الأقصى المسموح
- لا يتم استدعاء `onImageSelected`

### 4. أداة Crop (قص الصورة)
```dart
ImagePecker(
  enableCrop: true, // تفعيل Crop (افتراضي: true)
  cropAspectRatio: 1.0, // نسبة 1:1 (مربع)
  // cropAspectRatio: 16/9, // نسبة 16:9 (عريض)
  // cropAspectRatio: null, // حر (المستخدم يختار)
  // ...
)
```

**ملاحظات:**
- يعمل فقط على **الموبايل** (Android/iOS)
- لا يعمل على **الويب** (Web) - يتم تجاهله
- يظهر بعد اختيار الصورة مباشرة
- واجهة احترافية مع خيارات متعددة
- المستخدم يمكنه:
  - اختيار المنطقة المراد قصها
  - تدوير الصورة
  - تغيير نسبة العرض للارتفاع (إذا `cropAspectRatio: null`)
  - إلغاء العملية

**النسب المتاحة في Crop:**
- `CropAspectRatioPreset.square` - مربع (1:1)
- `CropAspectRatioPreset.ratio3x2` - (3:2)
- `CropAspectRatioPreset.ratio4x3` - (4:3)
- `CropAspectRatioPreset.ratio16x9` - (16:9)
- `CropAspectRatioPreset.original` - الأصلي

---

## 📱 أمثلة الاستخدام

### مثال 1: صور المنتجات (مربع + حد أقصى)
```dart
ImagePecker(
  placeholderAsset: 'assets/product_placeholder.png',
  height: 250,
  width: 250,
  enableCrop: true,
  cropAspectRatio: 1.0, // مربع
  maxFileSizeMB: 3.0, // 3 ميجابايت كحد أقصى
  showFileSize: true,
  helperText: 'صورة المنتج (مربعة)',
  onImageSelected: (imageModel) {
    // حفظ الصورة
    product.image = imageModel;
  },
)
```

### مثال 2: صور الغلاف (عريض + بدون حد)
```dart
ImagePecker(
  placeholderAsset: 'assets/cover_placeholder.png',
  height: 200,
  width: double.infinity,
  shape: BoxShape.rectangle,
  borderRadius: BorderRadius.circular(16),
  enableCrop: true,
  cropAspectRatio: 16 / 9, // عريض
  maxFileSizeMB: null, // بدون حد أقصى
  showFileSize: true,
  helperText: 'صورة الغلاف (16:9)',
  onImageSelected: (imageModel) {
    category.coverImage = imageModel;
  },
)
```

### مثال 3: صورة الملف الشخصي (دائري + Crop حر)
```dart
ImagePecker(
  placeholderAsset: 'assets/avatar_placeholder.png',
  height: 150,
  width: 150,
  shape: BoxShape.circle,
  enableCrop: true,
  cropAspectRatio: null, // حر - المستخدم يختار
  maxFileSizeMB: 2.0,
  showFileSize: false, // إخفاء حجم الملف
  helperText: 'صورة الملف الشخصي',
  onImageSelected: (imageModel) {
    user.avatar = imageModel;
  },
)
```

### مثال 4: رفع مستندات (بدون Crop + حد كبير)
```dart
ImagePecker(
  placeholderAsset: 'assets/document_placeholder.png',
  height: 300,
  width: double.infinity,
  enableCrop: false, // بدون Crop
  maxFileSizeMB: 10.0, // 10 ميجابايت
  showFileSize: true,
  helperText: 'صورة المستند (PNG, JPG)',
  onImageSelected: (imageModel) {
    document.scan = imageModel;
  },
)
```

---

## 🔧 الإعدادات الافتراضية

| الخاصية | القيمة الافتراضية | الوصف |
|---------|-------------------|--------|
| `enableCrop` | `true` | تفعيل Crop |
| `cropAspectRatio` | `null` | نسبة Crop (null = حر) |
| `maxFileSizeMB` | `null` | حد أقصى للحجم (null = بلا حد) |
| `showFileSize` | `true` | عرض حجم الملف |
| `enableCamera` | `true` | تفعيل الكاميرا (موبايل) |

---

## 🎨 تخصيص واجهة Crop

يتم التخصيص تلقائياً بناءً على `iconColor`:
- **لون الـ Toolbar**: `iconColor`
- **لون النصوص**: أبيض
- **النسب المتاحة**: Square, 3:2, 4:3, 16:9, Original

```dart
ImagePecker(
  iconColor: Color(0xFFD4AF37), // ذهبي
  // ستكون واجهة Crop بنفس اللون
)
```

---

## ⚠️ التعامل مع الأخطاء

### 1. تجاوز الحد الأقصى للحجم
```dart
ImagePecker(
  maxFileSizeMB: 5.0,
  onImageSelected: (imageModel) {
    // لن يتم استدعاء هذه الدالة إذا تجاوز الحجم
  },
)
```
**النتيجة:** SnackBar برتقالي + عدم تحديث الصورة

### 2. إلغاء Crop
```dart
ImagePecker(
  enableCrop: true,
  onImageSelected: (imageModel) {
    // لن يتم استدعاء هذه الدالة إذا ألغى المستخدم Crop
  },
)
```
**النتيجة:** العودة دون تحديث الصورة

### 3. خطأ في Crop
```dart
// في حالة خطأ في Crop، يتم استخدام الصورة الأصلية
```

---

## 📊 معلومات تقنية

### حساب الحجم
```dart
class ImageFileModel {
  final int? fileSizeInBytes;
  
  double? get fileSizeInKB => fileSizeInBytes != null 
      ? fileSizeInBytes! / 1024 
      : null;
  
  double? get fileSizeInMB => fileSizeInBytes != null 
      ? fileSizeInBytes! / (1024 * 1024) 
      : null;
  
  String get readableFileSize {
    if (fileSizeInBytes == null) return 'غير معروف';
    if (fileSizeInBytes! < 1024) return '$fileSizeInBytes بايت';
    if (fileSizeInBytes! < 1024 * 1024) 
      return '${fileSizeInKB!.toStringAsFixed(2)} كيلوبايت';
    return '${fileSizeInMB!.toStringAsFixed(2)} ميجابايت';
  }
}
```

### المكتبات المستخدمة
```yaml
dependencies:
  image_picker: ^1.1.2   # اختيار الصور
  image_cropper: ^8.0.2  # قص الصور
  image: ^4.2.0          # معالجة الصور
```

---

## 🚀 الخلاصة

**ImagePecker** الآن يوفر:
✅ حساب حجم الصورة تلقائياً  
✅ عرض الحجم في الواجهة  
✅ تحديد حد أقصى للحجم  
✅ أداة Crop احترافية (موبايل)  
✅ واجهة نظيفة وسهلة الاستخدام  
✅ دعم كامل للويب والموبايل  

**مثالي لـ:** صور المنتجات، الفئات، الملفات الشخصية، الأغلفة، والمستندات.
