import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../booking/domain/entities/city_entity.dart';
import '../../../booking/domain/entities/university_entity.dart';
import '../../../booking/domain/entities/boarding_station_entity.dart';
import '../../../booking/domain/entities/arrival_station_entity.dart';
import '../../../booking/domain/entities/route_entity.dart';
import '../../../booking/domain/entities/schedule_entity.dart';
import '../../../booking/domain/entities/university_boarding_point_entity.dart';
import '../../../booking/domain/entities/university_arrival_point_entity.dart';

import '../../../../core/config/mock_data_sources.dart';

part 'home_provider.g.dart';

@riverpod
HomeRemoteDataSource homeRemoteDataSource(Ref ref) {
  return MockHomeRemoteDataSource();
}

@riverpod
HomeRepository homeRepository(Ref ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource: remoteDataSource);
}

@riverpod
Future<List<CityEntity>> cities(Ref ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getCities();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (cities) => cities,
  );
}

@riverpod
Future<List<UniversityEntity>> universities(Ref ref, String cityId) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getUniversities(cityId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (universities) => universities,
  );
}

@riverpod
Future<List<BoardingStationEntity>> boardingStations(
  Ref ref,
  String cityId,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getBoardingStations(cityId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stations) => stations,
  );
}

@riverpod
Future<List<ArrivalStationEntity>> arrivalStations(
  Ref ref,
  String pickupStationId,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getArrivalStations(pickupStationId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stations) => stations,
  );
}

@riverpod
Future<List<RouteEntity>> routes(Ref ref, String? universityId) async {
  if (universityId == null) return [];

  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getRoutes(universityId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (routes) => routes,
  );
}

@riverpod
Future<List<ScheduleEntity>> schedules(Ref ref, String routeId) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getSchedules(routeId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (schedules) => schedules,
  );
}
@riverpod
Future<List<BoardingStationEntity>> allBoardingStations(Ref ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getAllBoardingStations();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stations) => stations,
  );
}

@riverpod
Future<List<ArrivalStationEntity>> allArrivalStations(Ref ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getAllArrivalStations();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stations) => stations,
  );
}

@riverpod
Future<List<UniversityEntity>> allUniversities(Ref ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getAllUniversities();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (universities) => universities,
  );
}

@riverpod
Future<List<UniversityBoardingPointEntity>> universityBoardingPoints(
  Ref ref,
  String cityId,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getUniversityBoardingPoints(cityId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (points) => points,
  );
}

@riverpod
Future<List<UniversityArrivalPointEntity>> universityArrivalPoints(
  Ref ref,
  String universityId,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getUniversityArrivalPoints(universityId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (points) => points,
  );
}

final uniqueOriginsProvider = FutureProvider.family<List<String>, String>((ref, cityId) async {
  if (cityId.isEmpty) return [];
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getUniqueOrigins(cityId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (origins) => origins,
  );
});

final availableDestinationsProvider = FutureProvider.family<List<String>, ({String originName, String? cityId})>((ref, arg) async {
  if (arg.originName.isEmpty) return [];
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getAvailableDestinations(arg.originName, cityId: arg.cityId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (destinations) => destinations,
  );
});
