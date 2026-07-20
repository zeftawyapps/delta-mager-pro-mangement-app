import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../configs/home_header_config.dart';
import '../delegate/home_screen_delegate.dart';

/// الـ Header الثابت في أعلى الشاشة
class HomeHeaderWidget extends StatelessWidget {
  final HomeHeaderConfig config;
  final bool isDark;
  final bool isMobile;
  final HomeAuthState authState;
  final int cartItemCount;

  final VoidCallback? onLogoTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onMenuTap; // فتح الـ drawer في الـ mobile

  const HomeHeaderWidget({
    super.key,
    required this.config,
    required this.isDark,
    required this.isMobile,
    required this.authState,
    this.cartItemCount = 0,
    this.onLogoTap,
    this.onCartTap,
    this.onLoginTap,
    this.onLogoutTap,
    this.onProfileTap,
    this.onOrdersTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = isMobile
        ? config.mobileHorizontalPadding
        : config.desktopHorizontalPadding;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]!.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.06,
            ),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Mobile hamburger
            if (isMobile && onMenuTap != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: onMenuTap,
                ),
              ),

            // Logo + Title
            Flexible(child: _buildLogo(context)),
            const Spacer(),

            // Desktop nav links
            if (!isMobile && config.showNavLinks) ..._buildNavLinks(context),

            // Price Type Selector
            _buildPriceTypeSelector(context),
            const SizedBox(width: 12),

            // Cart
            if (config.showCartButton) ...[
              _buildCart(context),
              const SizedBox(width: 12),
            ],

            // Auth
            _buildAuth(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final logoAssetPath = config.logoAssetPath;
    final logoNetworkUrl = config.logoNetworkUrl?.trim();
    final hasNetworkLogo = logoNetworkUrl != null && logoNetworkUrl.isNotEmpty;
    final hasAssetLogo = logoAssetPath != null && logoAssetPath.isNotEmpty;
    final safeAssetPath = logoAssetPath ?? '';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onLogoTap,
        child: Row(
          children: [
            // Logo image
            if (hasNetworkLogo)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  logoNetworkUrl,
                  width: isMobile ? 32 : 38,
                  height: isMobile ? 32 : 38,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => hasAssetLogo
                      ? Image.asset(
                          safeAssetPath,
                          width: isMobile ? 32 : 38,
                          height: isMobile ? 32 : 38,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.storefront, size: isMobile ? 32 : 38),
                        )
                      : Icon(Icons.storefront, size: isMobile ? 32 : 38),
                ),
              )
            else if (hasAssetLogo)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  logoAssetPath,
                  width: isMobile ? 32 : 38,
                  height: isMobile ? 32 : 38,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.storefront, size: isMobile ? 32 : 38),
                ),
              ),

            const SizedBox(width: 8),

            // Title
            Flexible(
              child: Text(
                config.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNavLinks(BuildContext context) {
    final links = <Widget>[];
    for (final link in config.navLinks) {
      links.add(
        _NavLink(
          label: link.label,
          onTap: link.onTap,
          isDark: isDark,
          textColor: link.textColor,
          fontWeight: link.fontWeight,
          isUnderlined: link.isUnderlined,
        ),
      );
      links.add(const SizedBox(width: 20));
    }
    if (links.isNotEmpty) links.add(const Spacer());
    return links;
  }

  Widget _buildCart(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(icon: const Icon(Icons.shopping_cart), onPressed: onCartTap),
        if (cartItemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$cartItemCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAuth(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (authState.isLoggedIn && authState.userName != null) {
      return PopupMenuButton<String>(
        icon: CircleAvatar(
          radius: 16,
          backgroundColor: primaryColor.withValues(alpha: 0.15),
          child: Text(
            authState.userName!.isNotEmpty
                ? authState.userName!.substring(0, 1).toUpperCase()
                : 'U',
            style: TextStyle(
              color: primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onSelected: (value) {
          if (value == 'logout') onLogoutTap?.call();
          if (value == 'profile') onProfileTap?.call();
          if (value == 'orders') onOrdersTap?.call();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 20),
                const SizedBox(width: 10),
                Text('الملف الشخصي (${authState.userName})'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'orders',
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 20),
                const SizedBox(width: 10),
                const Text('طلباتي'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout_outlined, size: 20, color: Colors.red),
                SizedBox(width: 10),
                Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      );
    }

    if (isMobile) {
      return Container(
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.login_outlined, size: 18),
          onPressed: onLoginTap,
          color: primaryColor,
          tooltip: 'دخول',
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onLoginTap,
      icon: const Icon(Icons.login_outlined, size: 14),
      label: const Text('دخول'),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPriceTypeSelector(BuildContext context) {
    final priceType = context.watch<AppChangesValues>().priceType;
    final primaryColor = Theme.of(context).colorScheme.primary;

    String text = 'السعر الرسمي';
    IconData icon = Icons.storefront;
    Color buttonColor = isDark ? Colors.white70 : Colors.black87;

    if (priceType == 'wholesale') {
      text = 'سعر الجملة';
      icon = Icons.local_offer;
      buttonColor = const Color(0xFF3B82F6);
    } else if (priceType == 'distributor') {
      text = 'سعر الموزع';
      icon = Icons.workspace_premium;
      buttonColor = const Color(0xFFD97706);
    }

    return PopupMenuButton<String?>(
      tooltip: 'اختر فئة السعر',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: buttonColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: buttonColor),
            if (!isMobile) ...[
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: buttonColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: buttonColor),
          ],
        ),
      ),
      onSelected: (value) {
        context.read<AppChangesValues>().setPriceType(value);
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String?>(
          value: null,
          child: Row(
            children: [
              Icon(Icons.storefront, size: 18),
              SizedBox(width: 10),
              Text(
                'السعر الرسمي (قطاعي)',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String?>(
          value: 'wholesale',
          child: Row(
            children: [
              Icon(Icons.local_offer, size: 18, color: Color(0xFF3B82F6)),
              SizedBox(width: 10),
              Text(
                'سعر الجملة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String?>(
          value: 'distributor',
          child: Row(
            children: [
              Icon(Icons.workspace_premium, size: 18, color: Color(0xFFD97706)),
              SizedBox(width: 10),
              Text(
                'سعر الموزع (وكلاء)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isDark;
  final Color? textColor;
  final FontWeight? fontWeight;
  final bool isUnderlined;

  const _NavLink({
    required this.label,
    this.onTap,
    required this.isDark,
    this.textColor,
    this.fontWeight,
    this.isUnderlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: fontWeight ?? FontWeight.w600,
            color: textColor ?? (isDark ? Colors.white70 : Colors.black87),
            decoration: isUnderlined ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }
}
