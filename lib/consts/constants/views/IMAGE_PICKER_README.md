# 📸 ImagePecker Widget

## نظرة عامة
`ImagePecker` هو widget محسّن لاختيار الصور مع دعم كامل للويب والموبايل، تم إنشاؤه بناءً على `ImagePecker` من JoDija Templates لكن مع تحسينات كبيرة.

## ✨ المميزات

### 1. **دعم شامل للمنصات**
- ✅ دعم كامل للويب (Web) باستخدام `Uint8List`
- ✅ دعم للموبايل (iOS/Android) باستخدام `File`
- ✅ دعم عرض الصور من الشبكة (Network Images)

### 2. **إدارة حالة محسّنة**
- ✅ إدارة حالة تحميل الصورة (Loading State)
- ✅ معالجة الأخطاء (Error Handling)
- ✅ Progress Indicator أثناء التحميل

### 3. **واجهة مستخدم أفضل**
- ✅ أزرار واضحة للكاميرا والمعرض
- ✅ نص توضيحي (Helper Text)
- ✅ Animation سلسة للخيارات
- ✅ تصميم متجاوب مع الوضع الداكن/الفاتح

### 4. **مرونة في التخصيص**
- ✅ قابل للتخصيص بالكامل (شكل، حجم، ألوان)
- ✅ دعم BorderRadius للأشكال المستطيلة
- ✅ دعم Box Shadows

## 📋 البنية

### ImageFileModel
نموذج البيانات الذي يحتوي على الصورة المختارة:

```dart
class ImageFileModel {
  final XFile? xFile;           // الملف الأصلي من image_picker
  final File? file;             // للموبايل
  final Uint8List? bytes;       // للويب
  final String? networkUrl;     // للصور من الشبكة
  
  bool get hasImage;  // هل يوجد صورة؟
}
```

## 🚀 الاستخدام

### مثال أساسي

```dart
ImagePecker(
  placeholderAsset: AppAsset.imgplaceholder,
  networkImage: category?.image,
  height: 200,
  width: double.infinity,
  onImageSelected: (imageModel) {
    // احفظ الصورة المختارة
    setState(() {
      selectedImage = imageModel;
    });
  },
)
```

### مثال متقدم مع جميع الخيارات

```dart
ImagePecker(
  // الصورة الافتراضية (placeholder)
  placeholderAsset: 'assets/images/placeholder.png',
  
  // صورة من الشبكة (إن وجدت)
  networkImage: 'https://example.com/image.jpg',
  
  // الأبعاد
  height: 200,
  width: double.infinity,
  
  // الشكل والتصميم
  shape: BoxShape.rectangle,
  borderRadius: BorderRadius.circular(12),
  backgroundColor: Colors.white,
  
  // الأيقونة
  iconColor: Color(0xFFD4AF37),
  iconSize: 40,
  
  // Border وShadows
  border: Border.all(color: Colors.grey, width: 2),
  boxShadow: [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ],
  
  // نص توضيحي
  helperText: 'اضغط لاختيار صورة',
  
  // هل يمكن استخدام الكاميرا؟ (للموبايل فقط)
  enableCamera: true,
  
  // دالة عند اختيار صورة
  onImageSelected: (imageModel) {
    if (imageModel.hasImage) {
      // للويب
      if (imageModel.bytes != null) {
        print('Bytes length: ${imageModel.bytes!.length}');
      }
      
      // للموبايل
      if (imageModel.file != null) {
        print('File path: ${imageModel.file!.path}');
      }
      
      // لجميع المنصات
      if (imageModel.xFile != null) {
        print('XFile name: ${imageModel.xFile!.name}');
      }
    }
  },
)
```

## 🔄 مقارنة مع JoDija ImagePecker

| الميزة | JoDija ImagePecker | ImagePecker الجديد |
|--------|-------------------|---------------------------|
| دعم الويب | ⚠️ محدود | ✅ كامل |
| إدارة الحالة | BLoC معقد | State محسّن |
| معالجة الأخطاء | ❌ غير موجودة | ✅ موجودة |
| Loading State | ❌ غير موجود | ✅ موجود |
| واجهة المستخدم | ⚠️ قديمة | ✅ عصرية |
| سهولة الاستخدام | ⚠️ معقدة | ✅ بسيطة |
| التوثيق | ❌ غير موجود | ✅ كامل |

## 📱 السلوك على المنصات المختلفة

### الويب (Web)
- ✅ يظهر زر "معرض" فقط
- ✅ يستخدم `Uint8List` لتخزين الصورة
- ✅ لا يظهر خيار الكاميرا

### الموبايل (iOS/Android)
- ✅ يظهر زران: "كاميرا" و "معرض"
- ✅ يستخدم `File` لتخزين الصورة
- ✅ يمكن التقاط صورة مباشرة

## 🎨 التخصيص

### الشكل الدائري

```dart
ImagePecker(
  shape: BoxShape.circle,
  height: 150,
  width: 150,
  // ...
)
```

### الشكل المستطيل مع حواف دائرية

```dart
ImagePecker(
  shape: BoxShape.rectangle,
  borderRadius: BorderRadius.circular(20),
  height: 200,
  width: double.infinity,
  // ...
)
```

## 📦 المعلمات (Parameters)

| المعلمة | النوع | إلزامي | الافتراضي | الوصف |
|---------|------|--------|-----------|-------|
| `onImageSelected` | `Function(ImageFileModel)` | ✅ | - | دالة يتم استدعاؤها عند اختيار صورة |
| `placeholderAsset` | `String` | ✅ | - | مسار الصورة الافتراضية |
| `networkImage` | `String?` | ❌ | null | رابط صورة من الشبكة |
| `height` | `double` | ❌ | 200 | الارتفاع |
| `width` | `double` | ❌ | infinity | العرض |
| `shape` | `BoxShape` | ❌ | rectangle | الشكل |
| `backgroundColor` | `Color` | ❌ | white | لون الخلفية |
| `iconColor` | `Color` | ❌ | #D4AF37 | لون الأيقونة |
| `iconSize` | `double` | ❌ | 40 | حجم الأيقونة |
| `border` | `BoxBorder?` | ❌ | auto | حدود الحاوية |
| `borderRadius` | `BorderRadius?` | ❌ | null | حواف دائرية |
| `boxShadow` | `List<BoxShadow>?` | ❌ | null | ظلال |
| `helperText` | `String?` | ❌ | null | نص توضيحي |
| `enableCamera` | `bool` | ❌ | true | تفعيل الكاميرا |

## 🔧 التكامل مع Forms

### في CategoryInputForm

```dart
class _CategoryInputFormState extends State<CategoryInputForm> {
  ImageFileModel? selectedImage;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImagePecker(
          placeholderAsset: AppAsset.imgplaceholder,
          networkImage: widget.category?.image,
          onImageSelected: (imageModel) {
            setState(() {
              selectedImage = imageModel;
            });
          },
        ),
        // باقي الحقول...
      ],
    );
  }
}
```

### في ProductInputForm

```dart
class _ProductInputFormState extends State<ProductInputForm> {
  ImageFileModel? selectedImage;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImagePecker(
          placeholderAsset: "assets/images/placeholder.png",
          networkImage: widget.product?.images?.first,
          onImageSelected: (imageModel) {
            setState(() {
              selectedImage = imageModel;
            });
          },
        ),
        // باقي الحقول...
      ],
    );
  }
}
```

## 💡 نصائح الاستخدام

1. **احفظ الصورة في State**: استخدم `setState` لحفظ الصورة المختارة
2. **تحقق من hasImage**: استخدم `imageModel.hasImage` للتحقق من وجود صورة
3. **استخدم XFile للرفع**: `imageModel.xFile` يعمل على جميع المنصات
4. **تخصيص حسب الحاجة**: استخدم المعلمات المتاحة لتخصيص المظهر

## ⚠️ ملاحظات مهمة

- Widget مستقل تماماً ولا يحتاج BLoC خارجي
- يدير حالته الداخلية بشكل كامل
- معالجة الأخطاء مدمجة
- يعرض رسائل خطأ تلقائياً باستخدام SnackBar

## 🔄 التحديثات المستقبلية المقترحة

- [ ] دعم اختيار صور متعددة
- [ ] دعم Crop/Edit للصورة
- [ ] دعم Video
- [ ] معاينة الصورة بملء الشاشة
- [ ] دعم Drag & Drop للويب

## 📄 الملفات المرتبطة

- `/lib/constants/views/image_picker_widget.dart` - الـ Widget الرئيسي
- `/lib/control_panel/screens/inputs/category_input_form.dart` - مثال استخدام
- `/lib/control_panel/screens/inputs/product_input_form.dart` - مثال استخدام

---

تم إنشاؤه بواسطة: Tantast Team
التاريخ: ديسمبر 2025
