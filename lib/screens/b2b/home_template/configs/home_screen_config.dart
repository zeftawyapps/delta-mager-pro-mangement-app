/// ─────────────────────────────────────────────────────────────────────────────
/// Home Screen Root Config — يجمع كل الـ configs في مكان واحد
/// ─────────────────────────────────────────────────────────────────────────────

import 'home_header_config.dart';
import 'home_footer_config.dart';
import 'home_section_config.dart';

export 'home_header_config.dart';
export 'home_footer_config.dart';
export 'home_section_config.dart';

class HomeScreenConfig {
  /// إعدادات الـ Header الثابت
  final HomeHeaderConfig header;

  /// إعدادات الـ Footer (desktop only)
  final HomeFooterConfig footer;

  /// قائمة الـ sections المرتبة — كل section له config خاص
  final List<HomeSectionConfig> sections;

  /// هل يظهر الـ search bar
  final bool showSearchBar;

  /// placeholder text للـ search
  final String searchHintText;

  /// الـ breakpoint الفاصل بين mobile وdesktop (px)
  final double mobileBreakpoint;

  const HomeScreenConfig({
    required this.header,
    required this.sections,
    this.footer = HomeFooterConfig.disabled,
    this.showSearchBar = true,
    this.searchHintText = 'ابحث عن منتج...',
    this.mobileBreakpoint = 768,
  });
}
