import 'dart:async';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:JoDija_tamplites/util/widgits/collections_widgets/grid_view_model.dart';
import 'empty_state_widget.dart';

enum ViewMode { grid, list }

class MasterGrid<
  T extends BaseViewDataModel,
  B extends Cubit<FeaturDataSourceState<T>>
>
    extends StatefulWidget {
  final String title;
  final String? searchHint;
  final Widget Function(
    BuildContext context,
    T item,
    bool isSelected,
  )
  itemBuilder;
  final Widget Function(
    BuildContext context,
    T item,
    bool isSelected,
  )?
  listBuilder;
  final void Function(T item)? onItemTap;
  final ViewMode viewMode;
  final VoidCallback onAdd;
  final void Function(B bloc) onLoad;
  final void Function(B bloc, String query)? onSearch;
  final Widget? filterToolbar;
  final List<Widget> Function(List<T> selectedItems)?
  multiSelectActions; // أزرار العمليات الجماعية
  final void Function(List<T> selectedItems)? onMultiSelectChanged;
  final bool canMultiSelect;
  final double childAspectRatio;
  final int crossAxisCountSmall;
  final int crossAxisCountMedium;
  final int crossAxisCountLarge;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry padding;
  final String noDataMessage;
  final int debounceMs;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final bool canAdd;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final String? restorationId;
  final Clip clipBehavior;
  final Axis scrollDirection;
  final bool reverse;
  final bool? primary;
  final bool showAddInGrid;
  final bool Function(T item)? where;
  final Widget? addButton;
  final Widget? emptyWidget;
  final List<Widget>? extraActions; // 👈 الأزرار الإضافية بجانب زر الإضافة

  const MasterGrid({
    super.key,
    required this.title,
    required this.itemBuilder,
    this.listBuilder,
    this.onItemTap,
    this.viewMode = ViewMode.grid,
    required this.onAdd,
    required this.onLoad,
    this.onSearch,
    this.searchHint,
    this.filterToolbar,
    this.multiSelectActions,
    this.onMultiSelectChanged,
    this.canMultiSelect = false,
    this.childAspectRatio = 1.0,
    this.crossAxisCountSmall = 2,
    this.crossAxisCountMedium = 3,
    this.crossAxisCountLarge = 4,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.noDataMessage = "لا توجد بيانات متاحة حالياً",
    this.debounceMs = 500,
    this.physics,
    this.shrinkWrap = false,
    this.scrollController,
    this.canAdd = true,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.showAddInGrid = false,
    this.where,
    this.addButton,
    this.emptyWidget,
    this.extraActions,
  });

  @override
  State<MasterGrid<T, B>> createState() => _MasterGridState<T, B>();
}

class _MasterGridState<
  T extends BaseViewDataModel,
  B extends Cubit<FeaturDataSourceState<T>>
>
    extends State<MasterGrid<T, B>> {
  late TextEditingController _searchController;
  Timer? _debounce;
  final List<T> _selectedItems = []; // قائمة العناصر المختارة

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _toggleSelection(T item) {
    if (!widget.canMultiSelect) return;
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
    if (widget.onMultiSelectChanged != null) {
      widget.onMultiSelectChanged!(_selectedItems);
    }
  }

  void _selectAll(List<T> allItems) {
    setState(() {
      if (_selectedItems.length == allItems.length) {
        _selectedItems.clear();
      } else {
        _selectedItems.clear();
        _selectedItems.addAll(allItems);
      }
    });
    if (widget.onMultiSelectChanged != null) {
      widget.onMultiSelectChanged!(_selectedItems);
    }
  }

  void _onSearchChanged(B bloc, String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      if (widget.onSearch != null) {
        widget.onSearch!(bloc, query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bloc = context.read<B>();

    return Column(
      children: [
        // شريط العمليات الجماعية
        if (_selectedItems.isNotEmpty) _buildMultiSelectToolbar(isDark),

        if (widget.onSearch != null || (widget.canAdd && !widget.showAddInGrid))
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                if (widget.onSearch != null)
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {});
                        _onSearchChanged(bloc, val);
                      },
                      decoration: InputDecoration(
                        hintText: widget.searchHint ?? "بحث...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                  _onSearchChanged(bloc, '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark
                            ? DarkColors.surface
                            : LightColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                if (widget.canAdd && !widget.showAddInGrid) ...[
                  const SizedBox(width: 12),
                  widget.addButton ??
                      ElevatedButton.icon(
                        onPressed: widget.onAdd,
                        icon: const Icon(Icons.add),
                        label: Text('إضافة ${widget.title}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                ],
                if (widget.extraActions != null) ...[
                  const SizedBox(width: 8),
                  ...widget.extraActions!,
                ],
              ],
            ),
          ),
        if (widget.filterToolbar != null) widget.filterToolbar!,
        Expanded(
          child: BlocListener<B, FeaturDataSourceState<T>>(
            listener: (context, state) {
              state.listState.maybeWhen(
                loading: () => setState(() => _selectedItems.clear()),
                init: () => setState(() => _selectedItems.clear()),
                orElse: () {},
              );
            },
            child: BlocBuilder<B, FeaturDataSourceState<T>>(
              builder: (context, state) {
                return state.listState.when(
                  init: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.onLoad(bloc);
                    });
                    return const Center(child: CircularProgressIndicator());
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  success: (items) {
                    var list = items ?? [];

                    // Apply UI side filter if provided
                    if (widget.where != null) {
                      list = list.where(widget.where!).toList();
                    }

                    if (list.isEmpty && !widget.showAddInGrid) {
                      return widget.emptyWidget ??
                          EmptyStateWidget(
                            title: widget.noDataMessage,
                            icon: Icons.search_off,
                            onAction: widget.canAdd ? widget.onAdd : null,
                            actionLabel: widget.canAdd ? "إضافة جديد" : null,
                          );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final bool isList = widget.viewMode == ViewMode.list;

                        final crossCount = isList
                            ? 1
                            : width < 650
                            ? widget.crossAxisCountSmall
                            : width < 950
                            ? widget.crossAxisCountMedium
                            : widget.crossAxisCountLarge;

                        final bool showAddCard =
                            widget.showAddInGrid && widget.canAdd;

                        // استخدام نسبة عرض إلى ارتفاع مختلفة للقائمة إذا كانت القيمة الافتراضية 1.0
                        final double ratio =
                            isList && widget.childAspectRatio == 1.0
                            ? 4.0
                            : widget.childAspectRatio;

                        // اختيار البناء المناسب (List أو Grid)
                        final builder = (isList && widget.listBuilder != null)
                            ? widget.listBuilder!
                            : widget.itemBuilder;

                        return Padding(
                          padding: widget.padding,
                          child: GridViewModel<T>(
                            data: list,
                            canAdd: showAddCard,
                            onAdd: widget.onAdd,
                            addWidget: _buildAddCard(context, isDark),
                            listItem: (index, item) {
                              final isSelected = _selectedItems.contains(item);
                              final isSelectionModeActive = _selectedItems.isNotEmpty;
                              return MasterGridItemWrapper(
                                isSelected: isSelected,
                                isSelectionModeActive: isSelectionModeActive,
                                onSelect: () => _toggleSelection(item),
                                onTap: widget.onItemTap != null
                                    ? () => widget.onItemTap!(item)
                                    : null,
                                child: builder(context, item, isSelected),
                              );
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossCount,
                                  crossAxisSpacing: widget.crossAxisSpacing,
                                  mainAxisSpacing: widget.mainAxisSpacing,
                                  childAspectRatio: ratio,
                                ),
                            physics: widget.physics,
                            shrinkWrap: widget.shrinkWrap,
                            scrollController: widget.scrollController,
                          ),
                        );
                      },
                    );
                  },
                  failure: (error, callback) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(error.message ?? "حدث خطأ غير متوقع"),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => widget.onLoad(bloc),
                          icon: const Icon(Icons.refresh),
                          label: const Text(AppStrings.retry),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectToolbar(bool isDark) {
    final primaryColor = isDark ? DarkColors.primary : LightColors.primary;
    final bloc = context.read<B>();

    // محاولة الحصول على كل العناصر من حالة الـ Bloc لتمكين "اختيار الكل"
    final allItems = bloc.state.listState.maybeWhen(
      success: (items) => items ?? [],
      orElse: () => <T>[],
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _selectedItems.clear()),
            tooltip: "إلغاء الاختيار",
          ),
          const SizedBox(width: 8),
          Text(
            "تم اختيار ${_selectedItems.length} عنصر",
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
          ),
          const Spacer(),
          if (allItems.isNotEmpty)
            TextButton.icon(
              onPressed: () => _selectAll(allItems),
              icon: Icon(
                _selectedItems.length == allItems.length
                    ? Icons.deselect
                    : Icons.select_all,
                size: 20,
              ),
              label: Text(
                _selectedItems.length == allItems.length
                    ? "إلغاء الكل"
                    : "اختيار الكل",
              ),
            ),
          const SizedBox(width: 8),
          if (widget.multiSelectActions != null)
            ...widget.multiSelectActions!(_selectedItems),
        ],
      ),
    );
  }

  Widget _buildAddCard(BuildContext context, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (isDark ? DarkColors.primary : LightColors.primary).withValues(
            alpha: 0.5,
          ),
          width: 2,
        ),
      ),
      color: (isDark ? DarkColors.primary : LightColors.primary).withValues(
        alpha: 0.05,
      ),
      child: InkWell(
        onTap: widget.onAdd,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: isDark ? DarkColors.primary : LightColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'إضافة ${widget.title}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? DarkColors.primary : LightColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ويدجت موحد لتغليف عناصر الشبكة والتعامل مع التحديد والسلوك المشترك
class MasterGridItemWrapper extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final bool isSelectionModeActive;
  final VoidCallback onSelect;
  final VoidCallback? onTap;

  const MasterGridItemWrapper({
    super.key,
    required this.child,
    required this.isSelected,
    required this.isSelectionModeActive,
    required this.onSelect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // البطاقة الأساسية
        Positioned.fill(
          child: InkWell(
            onTap: (isSelectionModeActive || isSelected) ? onSelect : onTap,
            onLongPress: onSelect,
            child: child,
          ),
        ),
        
        // غطاء التحديد (Selection Overlay)
        if (isSelected)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
