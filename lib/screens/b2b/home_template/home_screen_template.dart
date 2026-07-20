/// ─────────────────────────────────────────────────────────────────────────────
/// HomeScreenTemplate — الـ Template الرئيسي
///
/// يقبل:
///   - [config]   : شكل الشاشة (header + footer + sections)
///   - [delegate] : البيانات والـ callbacks
///
/// لا يعتمد على أي model أو Bloc خاص بالتطبيق
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/configs/app_backend_env.dart';
import 'package:provider/provider.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'configs/home_screen_config.dart';
import 'delegate/home_screen_delegate.dart';
import 'widgets/home_header_widget.dart';
import 'widgets/home_footer_widget.dart';
import 'widgets/home_search_bar_widget.dart';
import 'widgets/home_promo_slider_widget.dart';
import 'widgets/home_categories_section_widget.dart';
import 'widgets/home_products_section_widget.dart';

export 'configs/home_screen_config.dart';
export 'delegate/home_screen_delegate.dart';

class HomeScreenTemplate extends StatefulWidget {
  final HomeScreenConfig config;
  final HomeScreenDelegate delegate;

  /// widget اختياري يظهر في الـ drawer (mobile) — لو null لا يظهر drawer
  final Widget? drawerWidget;

  /// widget اختياري للـ bottom navigation bar (mobile)
  final Widget? bottomNavigationBarWidget;

  const HomeScreenTemplate({
    super.key,
    required this.config,
    required this.delegate,
    this.drawerWidget,
    this.bottomNavigationBarWidget,
  });

  @override
  State<HomeScreenTemplate> createState() => _HomeScreenTemplateState();
}

class _HomeScreenTemplateState extends State<HomeScreenTemplate> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _offersKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreenConfig get _config => widget.config;
  HomeScreenDelegate get _delegate => widget.delegate;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll Helpers ─────────────────────────────────────────────────────────

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToOffers() {
    final ctx = _offersKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  // ── Refresh ────────────────────────────────────────────────────────────────

  Future<void> _handleRefresh() async {
    await _delegate.onLoadData(forceRefresh: true);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final priceType = context.watch<AppChangesValues>().priceType;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < _config.mobileBreakpoint;

    // بناء الـ nav links مع ربط الـ scroll functions
    final headerConfigWithScrollLinks = _buildHeaderWithScrollLinks(
      _config.header,
      isMobile,
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? widget.drawerWidget : null,
      bottomNavigationBar: isMobile ? widget.bottomNavigationBarWidget : null,
      body: Column(
        children: [
          // ── Sticky Header ──────────────────────────────────────────────
          HomeHeaderWidget(
            config: headerConfigWithScrollLinks,
            isDark: isDark,
            isMobile: isMobile,
            authState: _delegate.authState,
            cartItemCount: _delegate.cartItemCount,
            onLogoTap: _scrollToTop,
            onCartTap: _delegate.onCartTap,
            onLoginTap: _delegate.onLoginTap,
            onLogoutTap: _delegate.onLogoutTap,
            onProfileTap: _delegate.onProfileTap,
            onOrdersTap: _delegate.onOrdersTap,
            // نستخدم _scaffoldKey بدل Scaffold.of(context) لتجنب null context
            onMenuTap: isMobile && widget.drawerWidget != null
                ? () => _scaffoldKey.currentState?.openDrawer()
                : null,
          ),
          if (priceType != null && priceType.isNotEmpty)
            _buildPriceTypeBanner(context, priceType),

          // ── Scrollable Content ─────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    if (_config.showSearchBar)
                      HomeSearchBarWidget(
                        allProducts: _delegate.products,
                        isDark: isDark,
                        hintText: _config.searchHintText,
                        onProductTap: _delegate.onProductTap,
                        onSearchSubmit: _delegate.onAllProductsTap != null
                            ? (query) => _delegate.onAllProductsTap!()
                            : (_) {},
                      ),

                    // Sections
                    ..._config.sections.map(
                      (sec) => _buildSection(sec, isDark),
                    ),

                    const SizedBox(height: 40),

                    // Footer (desktop only)
                    if (!isMobile)
                      HomeFooterWidget(
                        config: _config.footer,
                        isDark: isDark,
                        storeTitle: _config.header.title,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Builder ────────────────────────────────────────────────────────

  Widget _buildSection(HomeSectionConfig section, bool isDark) {
    if (!section.isActive) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        if (section.title != null && section.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              section.title!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

        // Section content
        _buildSectionContent(section, isDark),
      ],
    );
  }

  Widget _buildSectionContent(HomeSectionConfig section, bool isDark) {
    if (section is OffersHomeSectionConfig) {
      if (_delegate.offers.isEmpty) return const SizedBox.shrink();
      if (section.displayMode == HomeSectionDisplayMode.horizontalList) {
        return SizedBox(
          key: _offersKey,
          height: section.horizontalListHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _delegate.offers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 280,
              child: _buildOfferCard(_delegate.offers[index], isDark),
            ),
          ),
        );
      }
      if (section.displayMode == HomeSectionDisplayMode.grid) {
        return Container(
          key: _offersKey,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _delegate.offers.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: section.gridCrossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: section.gridChildAspectRatio,
            ),
            itemBuilder: (context, index) =>
                _buildOfferCard(_delegate.offers[index], isDark),
          ),
        );
      }
      return Container(
        key: _offersKey,
        child: HomePromoSliderWidget(
          offers: _delegate.offers,
          isDark: isDark,
          height: section.sliderHeight,
          autoPlayDuration: section.autoPlayDuration,
          onTap: _delegate.onOfferTap,
        ),
      );
    }

    if (section is CategoriesHomeSectionConfig) {
      return HomeCategoriesSectionWidget(
        categories: _delegate.categories,
        config: section,
        isDark: isDark,
        onCategoryTap: _delegate.onCategoryTap,
        itemBuilder: _delegate.categoryCardBuilder,
      );
    }

    if (section is ProductsHomeSectionConfig) {
      return HomeProductsSectionWidget(
        allProducts: _delegate.products,
        config: section,
        isDark: isDark,
        onProductTap: _delegate.onProductTap,
        onAddToCart: _delegate.onAddToCart,
        onRemoveFromCart: _delegate.onRemoveFromCart,
        cardBuilder: _delegate.productCardBuilder,
      );
    }

    if (section is JokerHomeSectionConfig) {
      return HomeJokerSectionWidget(
        allProducts: _delegate.products,
        filter: section.filter,
        crossAxisCount: section.crossAxisCount,
        childAspectRatio: section.childAspectRatio,
        onProductTap: _delegate.onProductTap,
        jokerCardBuilder: _delegate.jokerCardBuilder,
      );
    }

    if (section is CustomBannerHomeSectionConfig) {
      if (section.imageUrl.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(section.borderRadius),
          child: Image.network(
            section.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: section.height,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildOfferCard(HomeOfferItem offer, bool isDark) {
    final imageUrl = AppBackendEnv.resolveImageUrl(offer.imageUrl).trim();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _delegate.onOfferTap(offer),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildOfferFallback(isDark),
                    )
                  : _buildOfferFallback(isDark),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.58),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Text(
                  offer.nameAr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferFallback(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: const Icon(Icons.local_offer, size: 42, color: Colors.grey),
    );
  }

  // ── Header Nav Links with Scroll bindings ──────────────────────────────────

  /// يُنشئ HomeHeaderConfig جديد بنفس الخصائص لكن مع ربط scroll functions للـ nav links
  HomeHeaderConfig _buildHeaderWithScrollLinks(
    HomeHeaderConfig original,
    bool isMobile,
  ) {
    if (isMobile || !original.showNavLinks) return original;

    final updatedLinks = original.navLinks.map((link) {
      // ربط الـ scroll callbacks بالـ nav links القياسية
      if (link.route == '_scroll_top' || link.label == 'الرئيسية') {
        return HomeNavLinkConfig(
          label: link.label,
          onTap: link.onTap ?? _scrollToTop,
        );
      }
      if (link.route == '_scroll_offers' || link.label == 'العروض الحصرية') {
        return HomeNavLinkConfig(
          label: link.label,
          onTap: link.onTap ?? _scrollToOffers,
        );
      }
      if (link.route == '_scroll_bottom' || link.label == 'اتصل بنا') {
        return HomeNavLinkConfig(
          label: link.label,
          onTap: link.onTap ?? _scrollToBottom,
        );
      }
      return link;
    }).toList();

    return HomeHeaderConfig(
      title: original.title,
      logoAssetPath: original.logoAssetPath,
      logoNetworkUrl: original.logoNetworkUrl,
      showCartButton: original.showCartButton,
      showNavLinks: original.showNavLinks,
      navLinks: updatedLinks,
      desktopHorizontalPadding: original.desktopHorizontalPadding,
      mobileHorizontalPadding: original.mobileHorizontalPadding,
    );
  }

  Widget _buildPriceTypeBanner(BuildContext context, String priceType) {
    final isWholesale = priceType == 'wholesale';
    final label = isWholesale
        ? 'تصفح بأسعار الجملة تفعيل مخصص'
        : 'تصفح بأسعار الموزعين تفعيل مخصص';
    final subtitle = isWholesale
        ? 'Wholesale Pricing Mode Active'
        : 'Distributor Pricing Mode Active';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWholesale
              ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]
              : [const Color(0xFF1E293B), const Color(0xFFD97706)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;
            return Flex(
              direction: isNarrow ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isNarrow
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWholesale
                            ? Icons.local_offer
                            : Icons.workspace_premium,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isNarrow) const SizedBox(height: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: TextButton(
                    onPressed: () {
                      context.read<AppChangesValues>().setPriceType(null);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'العودة للرسمي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
