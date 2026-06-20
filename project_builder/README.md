# 🚀 نظام البناء المتكامل ومتعدد المستأجرين (Multi-Tenant Builder)

مرحباً بك في نظام البناء والتهيئة الذكي لـ **Delta Matger Pro**. هذا النظام مصمم لتبسيط تهيئة التطبيق وتخصيص الهوية البصرية (White-Labeling)، ثم تشغيله محلياً أو رفعه مباشرة إلى استضافة Firebase للعميل النشط دون أي عناء أو أخطاء يدوية.

---

## 📋 الإعداد المبدئي (مرة واحدة فقط)
قبل تشغيل السكريبت لأول مرة، يجب إعطاؤه صلاحية التشغيل في نظام التشغيل (macOS/Linux). افتح الـ Terminal في المجلد الرئيسي للمشروع واكتب الأمر التالي:

```bash
chmod +x ./project_builder/build_client.sh
```

---

## 🌐 1. اختيار العميل النشط
الملف الرئيسي والمصدر الوحيد لتحديد العميل والبيئة النشطة هو:
👉 **[project_builder/config.yaml](file:///Users/moaz/Desktop/delta/products/under%20process/matger-pro/delta-mager-pro-client-app/project_builder/config.yaml)**

افتح هذا الملف، وقم بتعديل حقل `activeClient` ليتطابق مع العميل الذي تريد العمل عليه (على سبيل المثال: `domansy`, `mall`, `factory`, `distribution`):

```yaml
activeClient: "domansy"  # اسم العميل النشط
```

> [!NOTE]
> يجب أن يطابق الاسم المكتوب اسم ملف التكوين الخاص به والموجود في مجلد `project_builder/clients/<client>.yaml`.

### 🧩 بنية ملف العميل (`clients/<client>.yaml`)
كل عميل يجب أن يحتوي على تعريف التطبيقين بشكل صريح:

```yaml
firebase:
  project: "domansy-dev"
  hosting:
    dashboard: "domancy-orgs"
    admin: "domancy-admin"

apps:
  dashboard:
    buildTarget: "lib/main_dashboard.dart"
    hostingSite: "domancy-orgs"
  admin:
    buildTarget: "lib/main_admin.dart"
    hostingSite: "domancy-admin"
```

بهذه الطريقة السكربت يعرف بدقة:
- سيتم البناء من أي `main` لكل تطبيق.
- سيتم الرفع على أي Firebase Hosting site لكل تطبيق.

---

## 🏃 2. تشغيل السكريبت والأوامر المتاحة

بعد تحديد العميل في ملف الـ config، يمكنك تشغيل السكريبت من المجلد الرئيسي للمشروع بعدة طرق مرنة ومريحة:

### 📱 أ. الوضع التفاعلي (Interactive Mode)
إذا قمت بتشغيل السكريبت دون كتابة أي معاملات إضافية، سيعرض عليك قائمة خيارات بسيطة وواضحة جداً لتختر منها بضغطة زر:
```bash
./project_builder/build_client.sh
```

**الخيارات المتاحة في القائمة:**
1. **💻 بناء وتشغيل محلي (Build & Run Locally):** لتهيئة إعدادات العميل، بناء التطبيق للويب، وتشغيل سيرفر محلي لتجربته.
2. **🚀 بناء ونشر للـ Firebase (Build & Deploy):** لتهيئة الإعدادات، بناء التطبيق للويب، ورفعه مباشرة لاستضافة الـ Firebase الحية الخاصة بالعميل.
3. **⚙️ تهيئة الملفات فقط (Configure Only):** لتحديث ملفات التكوين والربط مع Firebase محلياً فقط وبسرعة دون بدء عملية البناء.

---

### ⚡ ب. وضع الاختصار السريع (Direct Commands)
لتخطي القائمة التفاعلية والبدء فوراً، يمكنك كتابة الإجراء المطلوب مباشرة بجانب اسم السكريبت كمعامل:

#### 1. التشغيل المحلي الفوري (Serve only):
يشغل آخر ناتج تم بناؤه مسبقاً:
```bash
./project_builder/build_client.sh run dashboard
./project_builder/build_client.sh run admin
./project_builder/build_client.sh run both
```
> [!NOTE]
> `dashboard` يعمل على المنفذ `8085` و`admin` على `8086`.
> لكي يعمل `run` يجب أن تكون قد بنيت التطبيق المطلوب مسبقاً.

#### 2. البناء والرفع المباشر للاستضافة (للعميل النشط في الـ Config):
يقوم بتهيئة الإعدادات، البناء، ثم الرفع حسب التطبيق المختار:
```bash
./project_builder/build_client.sh deploy dashboard
./project_builder/build_client.sh deploy admin
./project_builder/build_client.sh deploy both
```
> [!IMPORTANT]
> **ذكاء فحص الإصدارات:** عند تشغيل الرفع (`deploy`) أو التهيئة (`config`)، يقوم النظام بفحص رقم الإصدار الحالي في الـ `pubspec.yaml` ومقارنته بالإصدار الجديد في ملف تكوين العميل المختار. إذا كانا مختلفين، سيظهر لك **تنبيه أصفر تحذيري** يوضح ذلك، ثم يقوم النظام تلقائياً بمزامنتهم وتحديثهم في الـ `pubspec.yaml` ويكمل عملية البناء والرفع بنجاح دون أي توقف!

#### 3. التهيئة والتحديث المحلي السريع فقط (للعميل النشط في الـ Config):
يقوم بتحديث إعدادات التطبيق وتوليد ملفات `.firebaserc` و `firebase.json` فوراً للعميل النشط دون بناء:
```bash
./project_builder/build_client.sh config
```

#### 4. البناء ثم التشغيل المحلي:
```bash
./project_builder/build_client.sh build-run dashboard
./project_builder/build_client.sh build-run admin
./project_builder/build_client.sh build-run both
```

### 🏷️ 3. نظام مزامنة الإصدارات وسجل التحديثات (Version Sync & Logs)
يحتوي النظام على ميزتين فائقتين لإدارة ومتابعة الإصدارات تلقائياً:

1. **مزامنة الـ `pubspec.yaml` تلقائياً:**
   بمجرد تشغيل السكريبت لأي عميل، يقرأ الإصدار ورقم البناء المكتوبين في ملف إعدادات العميل (مثلاً `appVersion: "1.0.0"` و `appBuildIndex: 1`) ويقوم **تلقائياً بتحديث سطر الإصدار داخل ملف الـ `pubspec.yaml` الخاص بالـ Flutter** ليكون متطابقاً تماماً مع إعدادات هذا العميل النشط!

2. **سجل التحديثات التاريخي (`version_history.md`):**
   عند تنفيذ أي إجراء (تهيئة، تشغيل محلي، أو رفع)، يقوم النظام تلقائياً بتدوين وسجل هذه العملية داخل ملف خاص يُسمى:
   👉 **[project_builder/version_history.md](file:///Users/moaz/Desktop/delta/products/under%20process/matger-pro/delta-mager-pro-client-app/project_builder/version_history.md)**
   
   ستجد فيه جدولاً تاريخياً مرتباً يحتوي على:
   * **التاريخ والوقت** الدقيق للعملية.
   * **اسم العميل** النشط.
   * **رقم الإصدار** المتزامن ورقم البناء.
   * **نوع العملية** (تهيئة، تشغيل محلي، رفع).
   * **حالة العملية** (ناجحة ✅).

---

## 🧠 كيف يعمل النظام خلف الكواليس؟
1. **سكريبت البايثون (`configure.py`):** هو العقل المفكر؛ يقرأ تفاصيل ملف العميل YAML من مجلد `clients/` ويولد ديناميكياً ملفات الـ Firebase الخاصة بالمستأجر النشط، ويقوم بمزامنة وتحديث الـ `pubspec.yaml` الخاص بالفلاتر في المشاريع النشطة، ويسجل التاريخ والنسخة في ملف الـ history.
2. **سكريبت الباش (`build_client.sh`):** هو المنظم؛ يتلقى اختيارك ويقوم بتنفيذ عمليات البناء بالـ Flutter والتشغيل المحلي أو الرفع المباشر باستعمال خوادم Firebase CLI الموثقة.

