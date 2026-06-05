import 'package:delta_mager_pro_mangement_app/logic/model/language_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matger_pro_core_logic/features/locations/repo/location_repo.dart';
import 'package:matger_pro_core_logic/core/system/repo/system_repo.dart';
import 'package:JoDija_reposatory/utilis/models/staus_model.dart';
import '../model/location_models.dart';
import '../model/system_models.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_state.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';

class LocationsState {
  final DataSourceBaseState<List<CountryModel>> countriesState;
  final DataSourceBaseState<List<GovernorateModel>> governoratesState;
  final DataSourceBaseState<List<CityModel>> citiesState;
  final DataSourceBaseState<List<LanguageModel>> languagesState;
  final DataSourceBaseState<bool> operationState;
  final Map<String, CityModel> citiesCache; // Cache of all loaded cities by ID

  LocationsState({
    required this.countriesState,
    required this.governoratesState,
    required this.citiesState,
    required this.languagesState,
    required this.operationState,
    this.citiesCache = const {},
  });

  factory LocationsState.initial() => LocationsState(
    countriesState: const DataSourceBaseState.init(),
    governoratesState: const DataSourceBaseState.init(),
    citiesState: const DataSourceBaseState.init(),
    languagesState: const DataSourceBaseState.init(),
    operationState: const DataSourceBaseState.init(),
    citiesCache: const {},
  );

  LocationsState copyWith({
    DataSourceBaseState<List<CountryModel>>? countriesState,
    DataSourceBaseState<List<GovernorateModel>>? governoratesState,
    DataSourceBaseState<List<CityModel>>? citiesState,
    DataSourceBaseState<List<LanguageModel>>? languagesState,
    DataSourceBaseState<bool>? operationState,
    Map<String, CityModel>? citiesCache,
  }) {
    return LocationsState(
      countriesState: countriesState ?? this.countriesState,
      governoratesState: governoratesState ?? this.governoratesState,
      citiesState: citiesState ?? this.citiesState,
      languagesState: languagesState ?? this.languagesState,
      operationState: operationState ?? this.operationState,
      citiesCache: citiesCache ?? this.citiesCache,
    );
  }

  String getGovernorateName(String? id) {
    if (id == null) return "";
    return governoratesState.maybeWhen(
      success: (list) {
        if (list == null) return "";
        try {
          return list
              .firstWhere((g) => g.id.toString() == id.toString())
              .name
              .ar;
        } catch (_) {
          return "";
        }
      },
      orElse: () => "",
    );
  }

  String getCityName(String? id) {
    if (id == null) return "";
    if (citiesCache.containsKey(id.toString())) {
      return citiesCache[id.toString()]!.name.ar;
    }
    return citiesState.maybeWhen(
      success: (list) {
        if (list == null) return "";
        try {
          return list
              .firstWhere((c) => c.id.toString() == id.toString())
              .name
              .ar;
        } catch (_) {
          return "";
        }
      },
      orElse: () => "",
    );
  }
}

class LocationsBloc extends Cubit<LocationsState> {
  final LocationRepo repo;
  final SystemRepo systemRepo;

  LocationsBloc({required this.repo, required this.systemRepo})
    : super(LocationsState.initial());

  Future<void> loadCountries() async {
    emit(state.copyWith(countriesState: const DataSourceBaseState.loading()));
    final result = await repo.getCountries();
    if (result.status == StatusModel.success) {
      final list =
          result.data?.map((e) => CountryModel.fromData(e)).toList() ?? [];
      emit(state.copyWith(countriesState: DataSourceBaseState.success(list)));
    } else {
      emit(
        state.copyWith(
          countriesState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "Error loading countries",
            ),
            () => loadCountries(),
          ),
        ),
      );
    }
  }

  Future<void> loadGovernorates([String? countryId]) async {
    emit(
      state.copyWith(governoratesState: const DataSourceBaseState.loading()),
    );
    final result = countryId != null
        ? await repo.getGovernoratesOfCountry(countryId)
        : await repo.getGovernorates();
    if (result.status == StatusModel.success) {
      final list =
          result.data?.map((e) => GovernorateModel.fromData(e)).toList() ?? [];
      emit(
        state.copyWith(governoratesState: DataSourceBaseState.success(list)),
      );
    } else {
      emit(
        state.copyWith(
          governoratesState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "Error loading governorates",
            ),
            () => loadGovernorates(countryId),
          ),
        ),
      );
    }
  }

  Future<void> loadCities(String governorateId) async {
    emit(state.copyWith(citiesState: const DataSourceBaseState.loading()));
    final result = await repo.getCitiesOfGovernorate(governorateId);
    if (result.status == StatusModel.success) {
      final list =
          result.data?.map((e) => CityModel.fromData(e)).toList() ?? [];
      
      final newCache = Map<String, CityModel>.from(state.citiesCache);
      for (var city in list) {
        newCache[city.id.toString()] = city;
      }

      emit(state.copyWith(
        citiesState: DataSourceBaseState.success(list),
        citiesCache: newCache,
      ));
    } else {
      emit(
        state.copyWith(
          citiesState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error loading cities"),
            () => loadCities(governorateId),
          ),
        ),
      );
    }
  }

  Future<void> loadLanguages() async {
    emit(state.copyWith(languagesState: const DataSourceBaseState.loading()));
    final result = await systemRepo.getLanguages();
    if (result.status == StatusModel.success) {
      final list =
          result.data?.map((e) => LanguageModel.fromData(e)).toList() ?? [];
      emit(state.copyWith(languagesState: DataSourceBaseState.success(list)));
    } else {
      emit(
        state.copyWith(
          languagesState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "Error loading languages",
            ),
            () => loadLanguages(),
          ),
        ),
      );
    }
  }

  Future<void> addLanguage(Language language) async {
    emit(state.copyWith(operationState: const DataSourceBaseState.loading()));
    final result = await systemRepo.addLanguage(language);
    if (result.status == StatusModel.success) {
      emit(
        state.copyWith(operationState: const DataSourceBaseState.success(true)),
      );
      loadLanguages();
    } else {
      emit(
        state.copyWith(
          operationState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error adding language"),
            () => addLanguage(language),
          ),
        ),
      );
    }
  }

  Future<void> addGovernorate(Governorate governorate) async {
    emit(state.copyWith(operationState: const DataSourceBaseState.loading()));
    final result = await repo.addGovernorate(governorate);
    if (result.status == StatusModel.success) {
      emit(
        state.copyWith(operationState: const DataSourceBaseState.success(true)),
      );
      loadGovernorates(governorate.countryId);
    } else {
      emit(
        state.copyWith(
          operationState: DataSourceBaseState.failure(
            ErrorStateModel(
              message: result.message ?? "Error adding governorate",
            ),
            () => addGovernorate(governorate),
          ),
        ),
      );
    }
  }

  Future<void> addCity(City city) async {
    emit(state.copyWith(operationState: const DataSourceBaseState.loading()));
    final result = await repo.addCity(city);
    if (result.status == StatusModel.success) {
      emit(
        state.copyWith(operationState: const DataSourceBaseState.success(true)),
      );
      loadCities(city.governorateId);
    } else {
      emit(
        state.copyWith(
          operationState: DataSourceBaseState.failure(
            ErrorStateModel(message: result.message ?? "Error adding city"),
            () => addCity(city),
          ),
        ),
      );
    }
  }
}
