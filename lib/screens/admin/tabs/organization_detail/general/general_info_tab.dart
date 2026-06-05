import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_model.dart';

class GeneralInfoTab extends StatelessWidget {
  final OrganizationModel organization;
  final bool isDark;

  const GeneralInfoTab({
    super.key,
    required this.organization,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(context, isDark),
          const SizedBox(height: 16),
          // Additional info cards can be added here
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isDark) {
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? DarkColors.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.store, size: 36, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organization.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildIconText(
                    Icons.email_outlined,
                    organization.email,
                    isDark,
                  ),
                  _buildIconText(
                    Icons.phone_android_outlined,
                    organization.phone,
                    isDark,
                  ),
                  _buildIconText(
                    Icons.location_on_outlined,
                    organization.address,
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
