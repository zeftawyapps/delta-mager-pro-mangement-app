import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_path_model.dart';

class OrderPathFilterBar extends StatefulWidget {
  final List<OrderPathModel> displayPaths;
  final String? selectedPathId;
  final ValueChanged<String?> onPathSelected;

  const OrderPathFilterBar({
    super.key,
    required this.displayPaths,
    required this.selectedPathId,
    required this.onPathSelected,
  });

  @override
  State<OrderPathFilterBar> createState() => _OrderPathFilterBarState();
}

class _OrderPathFilterBarState extends State<OrderPathFilterBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _animateToPathIndex(int index) {
    if (_scrollController.hasClients) {
      final double targetOffset = (index * 125.0) - 100.0;
      final double boundedOffset = targetOffset.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        boundedOffset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.displayPaths.isEmpty) return const SizedBox.shrink();

    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.displayPaths.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final pathObj = isAll ? null : widget.displayPaths[index - 1];
          final isSelected = isAll
              ? widget.selectedPathId == null
              : widget.selectedPathId == pathObj?.id;

          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: InkWell(
              onTap: () {
                final targetPathId = isAll ? null : pathObj?.id;
                widget.onPathSelected(targetPathId);
                _animateToPathIndex(index);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected ? primaryColor : primaryColor.withOpacity(0.08),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : primaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    isAll ? "كل خطوط السير" : pathObj!.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : primaryColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
