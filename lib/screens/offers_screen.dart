import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:delta_mager_pro_mangement_app/configs/grid_configs.dart';
import 'package:delta_mager_pro_mangement_app/configs/product_input_config.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/offer.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/offers_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'inputs/offer_input_form.dart';

class OffersScreen extends StatefulWidget with AppShellRouterMixin {
  final double childAspectRatio;
  final int crossAxisCountSmall;
  final int crossAxisCountMedium;
  final int crossAxisCountLarge;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets padding;
  final String? noDataMessage;
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
  final int debounceMs;
  final String? searchHint;

  OffersScreen({
    super.key,
    this.childAspectRatio = OfferGridConfigs.childAspectRatio,
    this.crossAxisCountSmall = OfferGridConfigs.crossAxisCountSmall,
    this.crossAxisCountMedium = OfferGridConfigs.crossAxisCountMedium,
    this.crossAxisCountLarge = OfferGridConfigs.crossAxisCountLarge,
    this.crossAxisSpacing = OfferGridConfigs.crossAxisSpacing,
    this.mainAxisSpacing = OfferGridConfigs.mainAxisSpacing,
    this.padding = OfferGridConfigs.padding,
    this.noDataMessage = OfferGridConfigs.noDataMessage,
    this.physics = OfferGridConfigs.physics,
    this.shrinkWrap = OfferGridConfigs.shrinkWrap,
    this.scrollController,
    this.canAdd = OfferGridConfigs.canAdd,
    this.addAutomaticKeepAlives = OfferGridConfigs.addAutomaticKeepAlives,
    this.addRepaintBoundaries = OfferGridConfigs.addRepaintBoundaries,
    this.addSemanticIndexes = OfferGridConfigs.addSemanticIndexes,
    this.cacheExtent = OfferGridConfigs.cacheExtent,
    this.restorationId = OfferGridConfigs.restorationId,
    this.clipBehavior = OfferGridConfigs.clipBehavior,
    this.scrollDirection = OfferGridConfigs.scrollDirection,
    this.reverse = OfferGridConfigs.reverse,
    this.primary = OfferGridConfigs.primary,
    this.debounceMs = OfferGridConfigs.debounceMs,
    this.searchHint = OfferGridConfigs.searchHint,
  });

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with SystemManager {
  String get organizationId {
    final params = widget.getPrams();
    final orgName = params?['orgName'];
    if (orgName != null && orgName != "" && orgName != ":orgName") {
      return orgName;
    }
    final user = context.read<AppChangesValues>().user;
    return user?.organizationId ?? 'shop1';
  }

  void _addOffer() {
    showCustomInputDialog(
      context: context,
      content: const OfferInputForm(),
      height: 600,
      width: 500,
      onResult: (result) {
        context.read<OffersBloc>().loadOffers(organizationId: organizationId);
      },
    );
  }

  void _editOffer(OfferModel offer) {
    showCustomInputDialog(
      context: context,
      content: OfferInputForm(offer: offer),
      height: 600,
      width: 500,
      onResult: (result) {
        context.read<OffersBloc>().loadOffers(organizationId: organizationId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sys = getSystemConfig(
      context,
      feature: SystemFeatures.offer,
      mainPath: widget.getMainPath(),
      widgetCanAdd: widget.canAdd,
    );
    if (sys.authWidget != null) return sys.authWidget!;
    final canAdd = sys.canAdd;
    final canUpdate = sys.canUpdate;
    final canDelete = sys.canDelete;
    final featureConfig = sys.featureConfig;
    final isDark = sys.isDark;
    final appBarConfig = sys.appBarConfig;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: appBarConfig.buildAppBar(
        context: context,
        isAppBar: true,
        currentTilte: AppStrings.offers,
        isDesplayTitle: true,
      ),
      body: MasterGrid<OfferModel, OffersBloc>(
        title: AppStrings.offers,
        onItemTap: _editOffer,
        onAdd: _addOffer,
        onLoad: (bloc) => bloc.loadOffers(organizationId: organizationId),
        onSearch: (bloc, query) =>
            bloc.searchOffers(query: query, organizationId: organizationId),
        canAdd: canAdd,
        canMultiSelect: true,
        itemBuilder: (context, offer, isSelected) =>
            _buildOfferCard(offer, isDark, canUpdate, canDelete),
        showAddInGrid:
            featureConfig?.showAddInGrid ??
            ProductInputConfig.showAddOfferInGrid,
        childAspectRatio:
            featureConfig?.childAspectRatio ?? widget.childAspectRatio,
        crossAxisCountSmall:
            featureConfig?.crossAxisCountSmall ?? widget.crossAxisCountSmall,
        crossAxisCountMedium:
            featureConfig?.crossAxisCountMedium ?? widget.crossAxisCountMedium,
        crossAxisCountLarge:
            featureConfig?.crossAxisCountLarge ?? widget.crossAxisCountLarge,
        crossAxisSpacing:
            featureConfig?.crossAxisSpacing ?? widget.crossAxisSpacing,
        mainAxisSpacing:
            featureConfig?.mainAxisSpacing ?? widget.mainAxisSpacing,
        padding: widget.padding,
        noDataMessage: widget.noDataMessage ?? OfferGridConfigs.noDataMessage!,
        debounceMs: widget.debounceMs,
      ),
    );
  }

  Widget _buildOfferCard(
    OfferModel offer,
    bool isDark,
    bool canUpdate,
    bool canDelete,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                offer.imageUrl != null
                    ? Image.network(
                        offer.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 30),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.local_offer, size: 40),
                      ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${offer.discountPercentage.toInt()}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.name.ar,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      offer.targetType == OfferTargetType.product
                          ? Icons.production_quantity_limits
                          : Icons.category,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        offer.targetName ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
