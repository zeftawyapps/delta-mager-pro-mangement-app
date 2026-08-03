import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_model.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderItemCard extends StatelessWidget {
  final OrderModel order;
  final Color stepColor;
  final VoidCallback onManageOrder;
  final bool showSenderInfo;
  final bool showRecipientInfo;

  const OrderItemCard({
    super.key,
    required this.order,
    required this.stepColor,
    required this.onManageOrder,
    this.showSenderInfo = true,
    this.showRecipientInfo = true,
  });

  Future<void> _openMap(double latitude, double longitude) async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch $url");
      }
    } catch (e) {
      debugPrint("Error launching map url: $e");
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) return;
    final Uri url = Uri.parse("tel:$cleanPhone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        debugPrint("Could not launch $url");
      }
    } catch (e) {
      debugPrint("Error launching tel url: $e");
    }
  }

  Widget _buildContactDetailsBlock(BuildContext context, String title, OrderContactDetails? details, Color color) {
    if (details == null) return const SizedBox.shrink();

    String locationText = "";
    if (details.governorateId != null && details.governorateId!.isNotEmpty) {
      locationText += details.governorateId!.replaceAll('_', ' ').toUpperCase();
    }
    if (details.cityId != null && details.cityId!.isNotEmpty) {
      if (locationText.isNotEmpty) locationText += " - ";
      locationText += details.cityId!.replaceAll('_', ' ').toUpperCase();
    }

    final hasCoordinates = details.latitude != null && details.longitude != null;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_circle_outlined, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person_outline, details.name ?? "غير متوفر"),
          const SizedBox(height: 4),
          _buildPhoneRow(details.phone),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.location_on_outlined, details.address ?? "غير متوفر"),
          if (locationText.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildInfoRow(Icons.map_outlined, locationText),
          ],
          if (hasCoordinates) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openMap(details.latitude!, details.longitude!),
                icon: const Icon(Icons.map, size: 14),
                label: const Text("فتح الموقع على الخريطة", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  backgroundColor: color.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhoneRow(String? phone) {
    final phoneText = phone ?? "غير متوفر";
    final hasValidPhone = phone != null && phone.trim().isNotEmpty && phone != "غير متوفر";

    return Row(
      children: [
        Icon(Icons.phone_outlined, size: 13, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            phoneText,
            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
        ),
        if (hasValidPhone)
          InkWell(
            onTap: () => _makeCall(phone),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_forwarded_rounded, size: 13, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    "اتصال",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "غير محدد";
    final localDt = dt.toLocal();
    final day = localDt.day.toString().padLeft(2, '0');
    final month = localDt.month.toString().padLeft(2, '0');
    final year = localDt.year;
    final hourInt = localDt.hour % 12 == 0 ? 12 : localDt.hour % 12;
    final hour = hourInt.toString().padLeft(2, '0');
    final minute = localDt.minute.toString().padLeft(2, '0');
    final period = localDt.hour >= 12 ? 'م' : 'ص';
    return '$year/$month/$day $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final sender = order.senderDetails;
    final items = order.items;

    // Determine subtitle based on configuration flags
    List<Widget> subtitleWidgets = [];
    if (showSenderInfo && sender != null) {
      final senderPhone = sender.phone;
      final hasPhone = senderPhone != null && senderPhone.trim().isNotEmpty && senderPhone != "غير متوفر";
      subtitleWidgets.add(
        Row(
          children: [
            const Icon(Icons.person_outline, size: 13, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                "من: ${sender.name ?? 'عميل غير معروف'}",
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasPhone) ...[
              const SizedBox(width: 6),
              InkWell(
                onTap: () => _makeCall(senderPhone),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, size: 12, color: Colors.green),
                      SizedBox(width: 3),
                      Text(
                        "اتصال",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Dates (Creation & Step Transition / Update)
    final createdAt = order.meta?.createdAt;
    final updatedAt = order.meta?.updatedAt ?? createdAt;

    if (createdAt != null) {
      subtitleWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_outlined, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "إنشاء: ${_formatDate(createdAt)}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (updatedAt != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_toggle_off_rounded,
                        size: 11,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "انتقال الخطوة / التعديل: ${_formatDate(updatedAt)}",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Claim State Badge (for steps with selectionMode == 'claim')
    final stepInfo = order.workFlow?.stepInfo;
    final isClaimStep = stepInfo?.selectionMode == 'claim';

    if (isClaimStep) {
      final handlerName = order.meta?.updatedBy?.userName ??
          order.meta?.createdBy?.userName ??
          order.handlerUserId;

      final isClaimed = (order.handlerUserId != null &&
              order.handlerUserId!.trim().isNotEmpty) ||
          (handlerName != null &&
              handlerName.trim().isNotEmpty &&
              order.status != 'pending');

      subtitleWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isClaimed
                  ? Colors.teal.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isClaimed
                    ? Colors.teal.withOpacity(0.4)
                    : Colors.orange.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isClaimed
                      ? Icons.check_circle_outline
                      : Icons.hourglass_top_rounded,
                  size: 13,
                  color: isClaimed ? Colors.teal[800] : Colors.orange[900],
                ),
                const SizedBox(width: 4),
                Text(
                  isClaimed
                      ? "تم أخذ الملكية بواسطة: ${handlerName ?? 'المستخدم'}"
                      : "لم يتم أخذ الملكية بعد ⏳",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isClaimed ? Colors.teal[900] : Colors.orange[900],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: stepColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.shopping_bag_outlined, color: stepColor),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "طلب #${order.id.substring(order.id.length - 5).toUpperCase()}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              "${order.totalOrderPrice} ج.م",
              style: TextStyle(
                color: stepColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        subtitle: subtitleWidgets.isEmpty 
            ? null 
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  ...subtitleWidgets,
                ],
              ),
        children: [
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSenderInfo && sender != null) ...[
                  _buildContactDetailsBlock(context, "بيانات المرسل (الاستلام)", sender, Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                ],
                
                const Text(
                  "المنتجات المطلوبة:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                ...items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name ?? "منتج",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (item.description != null &&
                                      item.description!.trim().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description!,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    "${item.quantity} × ${item.unitPrice} ج.م",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${item.totalPrice} ج.م",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onManageOrder,
                    icon: const Icon(Icons.settings_suggest_outlined, size: 20),
                    label: const Text("إدارة الطلب"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: stepColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "إجمالي الطلب النهائي",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        "${order.totalOrderPrice} ج.م",
                        style: TextStyle(
                          color: stepColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
