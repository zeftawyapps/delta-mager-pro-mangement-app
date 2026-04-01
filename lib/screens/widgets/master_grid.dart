import 'dart:async';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:JoDija_tamplites/util/view_data_model/base_data_model.dart';
import 'package:JoDija_tamplites/util/widgits/collections_widgets/grid_view_model.dart';

class MasterGrid<T extends BaseViewDataModel,
    B extends Cubit<FeaturDataSourceState<T>>> extends StatefulWidget {
  final String title;
  final String? searchHint;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onAdd;
  final void Function(B bloc) onLoad;
  final void Function(B bloc, String query)? onSearch;
  final Widget? filterToolbar;
  final double childAspectRatio;
  final int crossAxisCountSmall;
  final int crossAxisCountMedium;
  final int crossAxisCountLarge;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets padding;
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

  const MasterGrid({
    super.key,
    required this.title,
    required this.itemBuilder,
    required this.onAdd,
    required this.onLoad,
    this.onSearch,
    this.searchHint,
    this.filterToolbar,
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
  });

  @override
  State<MasterGrid<T, B>> createState() => _MasterGridState<T, B>();
}

class _MasterGridState<T extends BaseViewDataModel,
    B extends Cubit<FeaturDataSourceState<T>>> extends State<MasterGrid<T, B>> {
  late TextEditingController _searchController;
  Timer? _debounce;

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
        if (widget.onSearch != null || (widget.canAdd && !widget.showAddInGrid))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        fillColor:
                            isDark ? DarkColors.surface : LightColors.surface,
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
                          backgroundColor:
                              isDark ? DarkColors.primary : LightColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        if (widget.filterToolbar != null) widget.filterToolbar!,
        Expanded(
          child: BlocBuilder<B, FeaturDataSourceState<T>>(
            builder: (context, state) {
              return state.listState.when(
                init: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onLoad(bloc);
                  });
                  return const Center(child: CircularProgressIndicator());
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                success: (items) {
                  var list = items ?? [];
                  
                  // Apply UI side filter if provided
                  if (widget.where != null) {
                    list = list.where(widget.where!).toList();
                  }

                  if (list.isEmpty && !widget.showAddInGrid) {
                    return Center(
                      child: Text(
                        widget.noDataMessage,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossCount = width < 650
                          ? widget.crossAxisCountSmall
                          : width < 950
                              ? widget.crossAxisCountMedium
                              : widget.crossAxisCountLarge;

                      final bool showAddCard = widget.showAddInGrid && widget.canAdd;

                      return Padding(
                        padding: widget.padding,
                        child: GridViewModel<T>(
                          data: list,
                          canAdd: showAddCard,
                          onAdd: widget.onAdd,
                          addWidget: _buildAddCard(context, isDark),
                          listItem: (index, item) => widget.itemBuilder(context, item),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossCount,
                            crossAxisSpacing: widget.crossAxisSpacing,
                            mainAxisSpacing: widget.mainAxisSpacing,
                            childAspectRatio: widget.childAspectRatio,
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
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
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
      ],
    );
  }

  Widget _buildAddCard(BuildContext context, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (isDark ? DarkColors.primary : LightColors.primary).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      color: (isDark ? DarkColors.primary : LightColors.primary).withValues(alpha: 0.05),
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
            const SizedBox(height: 12),
            Text(
              'إضافة ${widget.title}',
              style: TextStyle(
                fontSize: 16,
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
