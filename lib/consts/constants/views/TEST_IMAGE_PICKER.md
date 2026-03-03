# 🧪 تجربة ImagePecker

## كيفية التجربة

### 1️⃣ افتح شاشة الفئات
```
المسار: لوحة التحكم > الفئات
```

### 2️⃣ اضغط على زر "إضافة فئة"
- سيظهر نموذج إضافة فئة جديدة

### 3️⃣ جرب اختيار الصورة
اضغط على منطقة الصورة (المستطيل الكبير في الأعلى)

#### على الويب:
- ✅ سيظهر زر "معرض" فقط
- اضغط على "معرض" لاختيار صورة من جهازك

#### على الموبايل:
- ✅ سيظهر زران: "كاميرا" و "معرض"
- اضغط على "كاميرا" لالتقاط صورة مباشرة
- أو "معرض" لاختيار من معرض الصور

### 4️⃣ املأ باقي الحقول
- **اسم الفئة (عربي)**: مثلاً "العناية بالشعر"
- **اسم الفئة (انجليزية)**: مثلاً "Hair Care"
- **وصف الفئة**: وصف مختصر للفئة

### 5️⃣ اضغط "إضافة الفئة"
سيظهر:
- ✅ رسالة نجاح خضراء
- 📋 معلومات في Console

## 📊 ما الذي ستراه في Console

عند اختيار صورة:
```
✅ تم اختيار صورة للفئة
📸 hasImage: true
📁 XFile name: IMG_1234.jpg
📁 XFile path: /path/to/image.jpg
💾 Bytes length: 245678 (للويب)
📂 File path: /path/to/image.jpg (للموبايل)
```

عند الحفظ:
```
📋 بيانات النموذج:
الاسم بالعربي: العناية بالشعر
الاسم بالإنجليزي: Hair Care
الوصف: منتجات طبيعية للعناية بالشعر
هل يوجد صورة: true
```

## ✨ المميزات التي ستلاحظها

### 1. واجهة سلسة
- ❌ لا animation معقد من JoDija ImagePecker
- ✅ animation بسيطة وسريعة للخيارات

### 2. Loading Indicator
- عند اختيار صورة كبيرة، سيظهر مؤشر تحميل

### 3. معالجة الأخطاء
- إذا فشل اختيار الصورة، سيظهر SnackBar بالخطأ

### 4. عرض الصورة
- الصورة المختارة تظهر فوراً
- يمكن تغييرها بالضغط مرة أخرى

### 5. Network Image Support
- إذا فتحت فئة موجودة للتعديل، ستظهر صورتها الحالية
- يمكن تغييرها باختيار صورة جديدة

## 🎨 التخصيص الحالي

في `category_input_form.dart`:

```dart
ImagePecker(
  placeholderAsset: AppAsset.imgplaceholder,  // صورة placeholder
  networkImage: widget.category?.image,       // صورة الفئة الحالية
  height: 200.h,                              // ارتفاع 200
  width: double.infinity,                      // عرض كامل
  shape: BoxShape.rectangle,                   // شكل مستطيل
  borderRadius: BorderRadius.circular(12),     // حواف دائرية 12
  helperText: 'اضغط لاختيار صورة الفئة',      // نص توضيحي
  onImageSelected: (imageModel) { ... },      // دالة عند الاختيار
)
```

## 🔧 تجارب إضافية مقترحة

### تجربة 1: تغيير الشكل إلى دائري
```dart
shape: BoxShape.circle,
height: 150.h,
width: 150.h,
// borderRadius لن يعمل مع circle
```

### تجربة 2: إضافة Shadows
```dart
boxShadow: [
  BoxShadow(
    color: Colors.black26,
    blurRadius: 10,
    offset: Offset(0, 4),
  ),
],
```

### تجربة 3: تغيير الألوان
```dart
backgroundColor: Colors.grey[100],
iconColor: Colors.blue,
iconSize: 50,
```

### تجربة 4: تعطيل الكاميرا
```dart
enableCamera: false,  // للموبايل فقط
```

## 📱 اختبار على منصات مختلفة

### الويب (Chrome/Safari/Firefox)
1. شغّل `flutter run -d chrome`
2. جرب اختيار صور بأحجام مختلفة
3. تحقق من السرعة

### Android
1. شغّل على Android emulator
2. جرب الكاميرا
3. جرب المعرض

### iOS
1. شغّل على iOS simulator
2. جرب الكاميرا (قد تحتاج device حقيقي)
3. جرب Photo Library

## ⚠️ ملاحظات

1. **الصور كبيرة الحجم**: يتم ضغطها تلقائياً إلى `imageQuality: 85`
2. **الحد الأقصى للأبعاد**: `maxWidth/maxHeight: 1920px`
3. **BLoC**: لا يستخدم BLoC ثقيل، فقط State بسيط
4. **الحفظ**: حالياً فقط print، يمكن إضافة logic حقيقي لاحقاً

## 🐛 إذا واجهت مشاكل

### المشكلة: لا تظهر الصورة بعد الاختيار
**الحل**: تحقق من Console للأخطاء

### المشكلة: الكاميرا لا تعمل على الويب
**الطبيعي**: الكاميرا غير متاحة على الويب

### المشكلة: placeholder لا يظهر
**الحل**: تأكد من وجود `AppAsset.imgplaceholder` في assets

---

**نصيحة**: افتح Developer Console قبل التجربة لرؤية جميع logs! 🎯
