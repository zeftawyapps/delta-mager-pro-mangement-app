import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/workflow_config_model.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';

class WorkflowStepCard extends StatelessWidget {
  final WorkflowConfigModel config;
  final WorkflowStep step;
  final Color primaryColor;
  final bool isLast;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddAction;
  final VoidCallback onConfigureTriggers;

  const WorkflowStepCard({
    super.key,
    required this.config,
    required this.step,
    required this.primaryColor,
    required this.isLast,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onAddAction,
    required this.onConfigureTriggers,
  });

  Color _getStepColor(WorkflowStep step) {
    // 1. If API color is provided and it's NOT the default black, use it
    if (step.stepColor != null &&
        step.stepColor!.isNotEmpty &&
        step.stepColor != '#000000' &&
        step.stepColor != '0x000000') {
      try {
        String hex = step.stepColor!.replaceAll('#', '').replaceAll('0x', '');
        if (hex.length == 6) hex = 'FF$hex';
        return Color(int.parse(hex, radix: 16));
      } catch (_) {}
    }

    // 2. Semantic Fallbacks based on stepKey
    final key = step.stepKey.toLowerCase();
    if (key.contains('start')) return Colors.blue;
    if (key.contains('processing') || key.contains('prepare')) {
      return Colors.orange;
    }
    if (key.contains('ship') || key.contains('delivery')) {
      return Colors.deepPurple;
    }
    if (key.contains('complete') ||
        key.contains('success') ||
        key.contains('done')) {
      return Colors.green;
    }
    if (key.contains('cancel') || key.contains('reject')) return Colors.red;
    if (key.contains('claim') || key.contains('accept')) return Colors.teal;

    // 3. Fallback based on step number if no key matches
    final List<Color> palette = [
      Colors.blue,
      Colors.orange,
      Colors.deepPurple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return palette[(step.stepNumber - 1) % palette.length];
  }

  String _getSelectionModeArabic(String mode) {
    switch (mode) {
      case 'claim':
        return 'استلام المهمة (Claim)';
      case 'direct':
        return 'إسناد مباشر لـ مستخدم معين';
      case 'consensus':
        return 'موافقة جماعية (إجماع)';
      case 'broadcast':
        return 'بث داخلي للمؤسسة';
      case 'market':
        return 'سوق عمل خارجي (مفتوح)';
      default:
        return mode;
    }
  }

  String _getTargetTypeArabic(String target) {
    switch (target) {
      case 'user':
        return 'مستخدم (user)';
      case 'org':
        return 'مؤسسة (org)';
      case 'both':
        return 'كلاهما (both)';
      default:
        return target;
    }
  }

  Widget _buildStepRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(WorkflowAction action) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.herbGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.herbGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flash_on, size: 14, color: AppColors.herbGreen),
              const SizedBox(width: 6),
              Text(
                action.actionName.ar,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.herbGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.subdirectory_arrow_right,
                size: 12,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                "الوجهة: ",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  action.actionReturnToStepKey,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stepColor = _getStepColor(step);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: stepColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: stepColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    step.stepNumber.toString(),
                    style: TextStyle(
                      color: stepColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? DarkColors.surface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: stepColor.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          step.stepName.ar,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: stepColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                step.statusTag,
                                style: TextStyle(
                                  color: stepColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                              onPressed: onEdit,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              tooltip: "تعديل الخطوة",
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                              onPressed: onDelete,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              tooltip: "حذف الخطوة",
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStepRow(Icons.security, "الدور", step.stepRole),
                    _buildStepRow(
                      Icons.touch_app,
                      "الإسناد",
                      _getSelectionModeArabic(step.selectionMode),
                    ),
                    _buildStepRow(Icons.group, "الهدف", _getTargetTypeArabic(step.targetType)),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "الإجراءات المتاحة (${step.actions.length}):",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: onAddAction,
                          icon: const Icon(Icons.add_circle_outline, size: 14),
                          label: const Text(
                            "إضافة إجراء",
                            style: TextStyle(fontSize: 11),
                          ),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (step.actions.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: step.actions
                            .map((action) => _buildActionChip(action))
                            .toList(),
                      )
                    else
                      Text(
                        "لا توجد إجراءات مضافة لهذه الخطوة من الـ API حالياً",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "المحفزات التلقائية (${step.stepTriggers.length}):",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: onConfigureTriggers,
                          icon: const Icon(Icons.settings_suggest, size: 14, color: Colors.blue),
                          label: const Text(
                            "إدارة المحفزات",
                            style: TextStyle(fontSize: 11, color: Colors.blue),
                          ),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (step.stepTriggers.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: step.stepTriggers.map((trigger) {
                          String friendlyName = trigger;
                          if (trigger == 'POST_SALES') {
                            friendlyName = "ترحيل للمبيعات (POST_SALES)";
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.settings_suggest_outlined, size: 12, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  friendlyName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Text(
                        "لا توجد محفزات تلقائية مضافة لهذه الخطوة حالياً",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontStyle: FontStyle.italic,
                        ),
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
}
