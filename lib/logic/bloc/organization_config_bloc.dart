import 'package:delta_mager_pro_mangement_app/logic/services/json_config_service.dart';
import 'package:JoDija_tamplites/util/conslol-logs/conslot-log.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:bloc/bloc.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:matger_pro_core_logic/core/orgnization/repo/organization_repo.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/organization_config_model.dart';

class OrganizationConfigBloc
    extends Cubit<FeaturDataSourceState<OrganizationConfigModel>> {
  final OrganizationRepo repo;
  OrganizationConfigModel? organizationConfig;

  OrganizationConfigBloc({required this.repo})
    : super(FeaturDataSourceState<OrganizationConfigModel>.defaultState());

  Future<void> loadConfig(String organizationId) async {
    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.getOrganizationConfig(organizationId);

    if (result.status == StatusModel.success && result.data != null) {
      final configModel = OrganizationConfigModel.fromData(result.data!);
      organizationConfig = configModel; // ✅ التخزين عند النجاح فقط
      JsonConfigService().updateProductInput(configModel.productInput);
      emit(state.copyWith(itemState: DataSourceBaseState.success(configModel)));
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء تحميل الإعدادات",
            ),
            () => loadConfig(organizationId),
          ),
        ),
      );
    }
  }

  Future<void> getOrganizationConfigByName(String orgName) async {
    if (organizationConfig != null) {
      return;
    }

    // التحقق من الحالة الحالية لمنع الطلبات المتكررة أثناء التحميل
    bool alreadyLoading = false;
    state.itemState.maybeWhen(
      loading: () => alreadyLoading = true,
      orElse: () {},
    );
    if (alreadyLoading) return;

    emit(state.copyWith(itemState: const DataSourceBaseState.loading()));
    final result = await repo.getOrganizationConfigByName(orgName);

    if (result.status == StatusModel.success && result.data != null) {
      final configModel = OrganizationConfigModel.fromData(result.data!);
      organizationConfig = configModel;
      _updateTheme(configModel);
      JsonConfigService().updateProductInput(configModel.productInput);
      emit(state.copyWith(itemState: DataSourceBaseState.success(configModel)));
    } else {
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "حدث خطأ أثناء تحميل الإعدادات",
            ),
            () => getOrganizationConfigByName(orgName),
          ),
        ),
      );
    }
  }

  Future<void> updateConfigSection({
    required String organizationId,
    required String section,
    required Map<String, dynamic> sectionData,
  }) async {
    final result = await repo.updateOrganizationConfigSection(
      organizationId: organizationId,
      section: section,
      sectionData: sectionData,
    );

    if (result.status == StatusModel.success && result.data != null) {
      final updatedConfigModel = OrganizationConfigModel.fromData(result.data!);
      JsonConfigService().updateProductInput(updatedConfigModel.productInput);
      emit(
        state.copyWith(
          itemState: DataSourceBaseState.success(updatedConfigModel),
        ),
      );
    } else {
      // Optional: Add failure handling if needed for updates
    }
  }

  void _updateTheme(OrganizationConfigModel config) {
    if (config.themes == null) return;
    final themes = config.themes!;
    final Map<String, Color> lightColors = {};
    final Map<String, Color> darkColors = {};

    if (themes.light != null) {
      final l = themes.light!;
      if (l.primary != null) {
        lightColors['primary'] = ColorUtils.fromHex(
          l.primary,
          LightColors.primary,
        );
      }
      if (l.secondary != null) {
        lightColors['secondary'] = ColorUtils.fromHex(
          l.secondary,
          LightColors.secondary,
        );
      }
    }

    if (themes.dark != null) {
      final d = themes.dark!;
      if (d.primary != null) {
        darkColors['primary'] = ColorUtils.fromHex(
          d.primary,
          DarkColors.primary,
        );
      }
      if (d.secondary != null) {
        darkColors['secondary'] = ColorUtils.fromHex(
          d.secondary,
          DarkColors.secondary,
        );
      }
    }

    AppColors.setDynamicColors(light: lightColors, dark: darkColors);
  }
}
