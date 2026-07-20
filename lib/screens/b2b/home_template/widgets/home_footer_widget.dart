import 'package:flutter/material.dart';
import '../configs/home_footer_config.dart';

/// الـ Footer — يُعرض في الـ desktop فقط
class HomeFooterWidget extends StatelessWidget {
  final HomeFooterConfig config;
  final bool isDark;
  final String storeTitle;

  const HomeFooterWidget({
    super.key,
    required this.config,
    required this.isDark,
    required this.storeTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (!config.isEnabled) return const SizedBox.shrink();

    final currentYear = DateTime.now().year;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final footerBg =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final footerText = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final headingColor = isDark ? Colors.white : Colors.black87;

    return Container(
      color: footerBg,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.spaceBetween,
            children: [
              // Column 1: Store Bio
              SizedBox(
                width: 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: headingColor,
                      ),
                    ),
                    if (config.storeDescription != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        config.storeDescription!,
                        style: TextStyle(
                          color: footerText,
                          height: 1.5,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (config.socialLinks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: config.socialLinks
                            .map((s) => Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: _SocialIcon(
                                    iconName: s.iconName,
                                    color: primaryColor,
                                    onTap: s.onTap,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Column 2: Quick Links
              if (config.quickLinks.isNotEmpty)
                SizedBox(
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'روابط سريعة',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: headingColor),
                      ),
                      const SizedBox(height: 16),
                      ...config.quickLinks.map(
                        (link) => _FooterLink(
                          text: link.label,
                          onTap: link.onTap,
                          textColor: footerText,
                          customTextColor: link.textColor,
                          fontWeight: link.fontWeight,
                          isUnderlined: link.isUnderlined,
                        ),
                      ),
                    ],
                  ),
                ),

              // Column 3: Contact
              if (config.contact != null)
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اتصل بنا',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: headingColor),
                      ),
                      const SizedBox(height: 16),
                      if (config.contact!.email != null)
                        _ContactItem(
                          icon: Icons.mail_outline,
                          text: config.contact!.email!,
                          textColor: footerText,
                        ),
                      if (config.contact!.phone != null)
                        _ContactItem(
                          icon: Icons.phone_android_outlined,
                          text: config.contact!.phone!,
                          textColor: footerText,
                        ),
                      if (config.contact!.address != null)
                        _ContactItem(
                          icon: Icons.location_on_outlined,
                          text: config.contact!.address!,
                          textColor: footerText,
                        ),
                    ],
                  ),
                ),

              // Column 4: Payment
              if (config.paymentBadges.isNotEmpty ||
                  config.paymentSectionBody != null)
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.paymentSectionTitle ?? 'الدفع والتوصيل',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: headingColor),
                      ),
                      const SizedBox(height: 16),
                      if (config.paymentSectionBody != null)
                        Text(
                          config.paymentSectionBody!,
                          style: TextStyle(
                              color: footerText, height: 1.4, fontSize: 12),
                        ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: config.paymentBadges
                            .map((b) => _PaymentBadge(
                                label: b.label, color: primaryColor))
                            .toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 32),
          Divider(
              color: (isDark ? Colors.white : Colors.black)
                  .withOpacity(0.06)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                config.copyrightText ??
                    '© $currentYear جميع الحقوق محفوظة لـ $storeTitle.',
                style: TextStyle(color: footerText, fontSize: 11),
              ),
              Text(
                'صنع بكل حب بواسطة zeftawyapps',
                style: TextStyle(color: footerText, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _SocialIcon extends StatelessWidget {
  final String iconName;
  final Color color;
  final VoidCallback? onTap;

  const _SocialIcon(
      {required this.iconName, required this.color, this.onTap});

  IconData get _icon {
    switch (iconName) {
      case 'facebook':
        return Icons.facebook_outlined;
      case 'instagram':
        return Icons.alternate_email_outlined;
      case 'whatsapp':
        return Icons.wechat_outlined;
      default:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(_icon, size: 16, color: color),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color textColor;
  final Color? customTextColor;
  final FontWeight? fontWeight;
  final bool isUnderlined;

  const _FooterLink({
    required this.text,
    this.onTap,
    required this.textColor,
    this.customTextColor,
    this.fontWeight,
    this.isUnderlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            text,
            style: TextStyle(
              color: customTextColor ?? textColor,
              fontSize: 12,
              fontWeight: fontWeight ?? FontWeight.w500,
              decoration: isUnderlined ? TextDecoration.underline : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color textColor;

  const _ContactItem(
      {required this.icon, required this.text, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  style: TextStyle(color: textColor, fontSize: 12))),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _PaymentBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
