import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/side_bar_navigation_router.dart';
import 'package:delta_mager_pro_mangement_app/configs/dialog_configs.dart';
import 'package:delta_mager_pro_mangement_app/configs/grid_configs.dart';
import 'package:delta_mager_pro_mangement_app/configs/product_input_config.dart';
import 'package:delta_mager_pro_mangement_app/screens/widgets/master_grid.dart';
import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/org_lifecycle_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/offer.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/offers_bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/values/strings.dart';
import 'package:delta_mager_pro_mangement_app/logic/mixins/system_manager.dart';
import 'package:matger_pro_core_logic/core/auth/utils/permission_constants.dart';
import 'inputs/offer_input_form.dart';
import 'package:delta_mager_pro_mangement_app/catalog/offers/offer_card.dart';

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

class _OffersScreenState extends State<OffersScreen>
    with SystemManager, OrgLifecycleManager {
  @override
  void initState() {
    super.initState();
    initOrgListener(
      onOrgChanged: (orgId) {
        context.read<OffersBloc>().loadOffers(organizationId: orgId);
        setState(() {});
      },
    );
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
        itemBuilder: (context, offer, isSelected) => OfferCard(
          offer: offer,
          isDark: isDark,
          canUpdate: canUpdate,
          canDelete: canDelete,
        ),
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
}
