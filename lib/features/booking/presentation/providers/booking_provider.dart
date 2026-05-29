import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/trip_type.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/university_entity.dart';
import '../../domain/entities/boarding_station_entity.dart';
import '../../domain/entities/arrival_station_entity.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart'; // needed by bookingRepositoryProvider
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/university_boarding_point_entity.dart';
import '../../domain/entities/university_arrival_point_entity.dart';
import '../../domain/usecases/get_user_bookings_use_case.dart';
import '../../domain/usecases/get_upcoming_booking_use_case.dart';
import '../../domain/usecases/create_booking_use_case.dart';
import '../../domain/usecases/create_university_request_use_case.dart';
import '../../domain/usecases/create_route_request_use_case.dart';
import '../../domain/usecases/transfer_booking_use_case.dart';
import '../../domain/constants/trip_type_pricing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'booking_providers.dart';

part 'booking_provider.g.dart';

// Booking Repository Provider
@riverpod
BookingRepository bookingRepository(Ref ref) {
  final dataSource = ref.watch(bookingDataSourceProvider);
  // Watch auth provider to ensure repository is rebuilt when auth state changes
  final userAsync = ref.watch(authProvider);
  final user = userAsync.value;

  return BookingRepositoryImpl(dataSource, () {
    if (user == null) throw Exception('User not authenticated');
    return user.id;
  });
}

// User Bookings Provider
@riverpod
Future<List<BookingEntity>> userBookings(Ref ref) async {
  final useCase = ref.watch(getUserBookingsUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (bookings) => bookings,
  );
}

// Upcoming Booking Provider
@riverpod
Future<BookingEntity?> upcomingBooking(Ref ref) async {
  final useCase = ref.watch(getUpcomingBookingUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (booking) => booking,
  );
}

// Derived selectors — keep filtering/sorting logic out of the UI layer

/// Active bookings sorted by nearest date first.
final upcomingBookingsListProvider = Provider<List<BookingEntity>>((ref) {
  final bookings = ref.watch(userBookingsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final upcoming = bookings
      .where(
        (b) =>
            !b.isCancelled &&
            !b.isCompleted &&
            (b.bookingDate.isAfter(now.subtract(const Duration(days: 1))) ||
                b.bookingDate.day == now.day),
      )
      .toList()
    ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
  return upcoming;
});

/// Past/completed bookings sorted by most recent first.
final pastBookingsListProvider = Provider<List<BookingEntity>>((ref) {
  final bookings = ref.watch(userBookingsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  return bookings
      .where(
        (b) =>
            b.isCancelled ||
            b.isCompleted ||
            b.bookingDate.isBefore(now.subtract(const Duration(days: 1))),
      )
      .toList()
    ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
});

// Use Case Providers
final getUserBookingsUseCaseProvider = Provider<GetUserBookingsUseCase>((ref) {
  return GetUserBookingsUseCase(ref.watch(bookingRepositoryProvider));
});

final getUpcomingBookingUseCaseProvider =
    Provider<GetUpcomingBookingUseCase>((ref) {
  return GetUpcomingBookingUseCase(ref.watch(bookingRepositoryProvider));
});

final createBookingUseCaseProvider = Provider<CreateBookingUseCase>((ref) {
  return CreateBookingUseCase(ref.watch(bookingRepositoryProvider));
});

final createUniversityRequestUseCaseProvider =
    Provider<CreateUniversityRequestUseCase>((ref) {
  return CreateUniversityRequestUseCase(ref.watch(bookingRepositoryProvider));
});

final createRouteRequestUseCaseProvider =
    Provider<CreateRouteRequestUseCase>((ref) {
  return CreateRouteRequestUseCase(ref.watch(bookingRepositoryProvider));
});

final transferBookingUseCaseProvider = Provider<TransferBookingUseCase>((ref) {
  return TransferBookingUseCase(ref.watch(bookingRepositoryProvider));
});

@Riverpod(keepAlive: true)
class BookingState extends _$BookingState {
  @override
  BookingStateModel build() {
    final now = DateTime.now();
    final initialDate = now.hour >= 7
        ? DateTime(now.year, now.month, now.day + 1)
        : now;

    return BookingStateModel(
      tripType: TripType.departureOnly, // Default to single trip
      isToUniversity: false, // Default to Mawkaf trip
      selectedPlanIndex: 1, // Default to Monthly
      selectedDate: initialDate,
      selectedDepartureTime: null,
      selectedReturnTime: null,
      selectionType: BookingSelectionType.seat,
      passengerCount: 1,
      splitPreference: true,
      isLadiesOnly: false,
    );
  }

  void setSelectionType(BookingSelectionType value) {
    state = state.copyWith(selectionType: value);
  }

  void setPassengerCount(int value) {
    state = state.copyWith(passengerCount: value);
  }

  void setSplitPreference(bool value) {
    state = state.copyWith(splitPreference: value);
  }

  void setIsLadiesOnly(bool value) {
    state = state.copyWith(isLadiesOnly: value);
  }

  void setIsToUniversity(bool value) {
    state = state.copyWith(isToUniversity: value);
  }

  void selectTripType(TripType tripType) {
    state = state.copyWith(tripType: tripType);
  }

  void selectPlan(int index) {
    state = state.copyWith(selectedPlanIndex: index);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      selectedDepartureSchedule: null,
      selectedReturnSchedule: null,
      selectedDepartureTime: null,
      selectedReturnTime: null,
    );
  }

  void selectDepartureSchedule(ScheduleEntity? schedule) {
    state = state.copyWith(
      selectedDepartureSchedule: schedule,
      selectedDepartureTime: schedule?.departureTime,
    );
  }

  void selectReturnSchedule(ScheduleEntity? schedule) {
    state = state.copyWith(
      selectedReturnSchedule: schedule,
      selectedReturnTime: schedule?.departureTime,
    );
  }

  void selectDepartureTime(String? time) {
    state = state.copyWith(selectedDepartureTime: time);
  }

  void selectReturnTime(String? time) {
    state = state.copyWith(selectedReturnTime: time);
  }

  void setLocationData({
    required CityEntity city,
    UniversityEntity? university,
    BoardingStationEntity? pickupStation,
    ArrivalStationEntity? arrivalStation,
    UniversityBoardingPointEntity? uniBoardingPoint,
    UniversityArrivalPointEntity? uniArrivalPoint,
    bool? isToUniversity,
  }) {
    state = state.copyWith(
      selectedCity: city,
      selectedUniversity: university,
      selectedStation: pickupStation,
      selectedArrivalStation: arrivalStation,
      selectedUniBoardingPoint: uniBoardingPoint,
      selectedUniArrivalPoint: uniArrivalPoint,
      isToUniversity: isToUniversity ?? state.isToUniversity,
    );

  }

  bool get isSameDayBookingAllowed {
    final now = DateTime.now();
    if (isSameDay(now, state.selectedDate)) {
      return now.hour < 7;
    }
    return true;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get isBookingComplete {
    if (state.isToUniversity) {
      // For University: Must have city, university, boarding point, and arrival point
      return state.selectedCity != null &&
          state.selectedUniversity != null &&
          state.selectedUniBoardingPoint != null &&
          state.selectedUniArrivalPoint != null;
    } else {
      // For Point-to-Point: Must have selected a pickup and arrival station, and a time
      return state.selectedStation != null &&
          state.selectedArrivalStation != null &&
          (state.selectedDepartureTime != null || state.selectedReturnTime != null);
    }
  }

  double get totalPrice {
    if (state.isToUniversity) {
      return TripTypePricing.priceOf(state.tripType);
    } else {
      // For Point-to-Point: Use the price from the arrival station
      final basePrice = state.selectedArrivalStation?.price ?? 0.0;
      return basePrice * state.passengerCount;
    }
  }

  void selectUniBoardingPoint(UniversityBoardingPointEntity? point) {
    state = state.copyWith(selectedUniBoardingPoint: point);
  }

  void selectUniArrivalPoint(UniversityArrivalPointEntity? point) {
    state = state.copyWith(selectedUniArrivalPoint: point);
  }

  Future<String?> createBooking({
    String? paymentProofImage,
    String? transferNumber,
  }) async {
    if (!isBookingComplete) {
      return 'يرجى إكمال جميع بيانات الحجز';
    }

    try {
      final scheduleId =
          state.selectedDepartureSchedule?.id ??
          state.selectedReturnSchedule?.id;

      final result = await ref.read(createBookingUseCaseProvider)(
        cityId: state.selectedCity?.id,
        scheduleId: scheduleId,
        bookingDate: state.selectedDate,
        tripType: state.tripType.toDbValue(),
        pickupStationId: state.selectedStation?.id,
        dropoffStationId: state.selectedArrivalStation?.id,
        departureTime: state.selectedDepartureTime,
        returnTime: state.selectedReturnTime,
        paymentProofImage: paymentProofImage,
        transferNumber: transferNumber,
        totalPrice: totalPrice,
        selectionType: state.selectionType,
        passengerCount: state.passengerCount,
        splitPreference: state.splitPreference,
        isLadies: state.isLadiesOnly,
      );

      return result.fold(
        (failure) => failure.message,
        (_) => null,
      );
    } catch (e) {
      return 'حدث خطأ أثناء الحجز: $e';
    }
  }

  Future<String?> createUniversityRequestBooking() async {
    if (!isBookingComplete) {
      return 'يرجى إكمال جميع بيانات طلب حجز الجامعة';
    }

    try {
      final university = state.selectedUniversity!;
      final isCustom = university.id.startsWith('custom_');

      final result = await ref
          .read(createUniversityRequestUseCaseProvider)(
        cityId: state.selectedCity?.id,
        bookingDate: state.selectedDate,
        universityId: university.id,
        routeId: state.selectedDepartureSchedule?.routeId ??
            state.selectedReturnSchedule?.routeId,
        uniBoardingPointId: state.selectedUniBoardingPoint?.id,
        uniArrivalPointId: state.selectedUniArrivalPoint?.id,
        isCustomUniversity: isCustom,
        customUniversityName: isCustom ? university.nameAr : null,
        departureTime: state.selectedDepartureTime,
        returnTime: state.selectedReturnTime,
        selectionType: state.selectionType,
        passengerCount: state.passengerCount,
        splitPreference: state.splitPreference,
        totalPrice: 0,
        isLadies: state.isLadiesOnly,
      );

      return result.fold(
        (failure) => failure.message,
        (_) => null,
      );
    } catch (e) {
      return 'حدث خطأ أثناء إرسال طلب الجامعة: $e';
    }
  }

  Future<String?> submitRouteRequest({
    String? cityName,
    required String boardingStationName,
    required String universityName,
  }) async {
    try {
      final result =
          await ref.read(createRouteRequestUseCaseProvider)(
        cityId: state.selectedCity?.id,
        cityName: cityName,
        boardingStationName: boardingStationName,
        universityName: universityName,
      );

      return result.fold(
        (failure) => failure.message,
        (_) => null,
      );
    } catch (e) {
      return 'حدث خطأ أثناء إرسال طلب المسار: $e';
    }
  }

  Future<String?> updateBooking({required String bookingId}) async {
    if (!isBookingComplete) {
      return 'يرجى إكمال جميع بيانات الحجز';
    }

    try {
      final result = await ref.read(bookingRepositoryProvider).updateBooking(
        bookingId: bookingId,
        cityId: state.selectedCity?.id,
        bookingDate: state.selectedDate,
        tripType: state.tripType.toDbValue(),
        pickupStationId: state.selectedStation?.id,
        dropoffStationId: state.selectedArrivalStation?.id,
        departureTime: state.selectedDepartureTime,
        returnTime: state.selectedReturnTime,
        totalPrice: totalPrice,
        selectionType: state.selectionType,
        passengerCount: state.passengerCount,
        splitPreference: state.splitPreference,
        isLadies: state.isLadiesOnly,
      );

      return result.fold(
        (failure) => failure.message,
        (_) => null,
      );
    } catch (e) {
      return 'حدث خطأ أثناء تعديل الحجز: $e';
    }
  }
}

class BookingStateModel {
  final TripType tripType;
  final bool isToUniversity;
  final int selectedPlanIndex;
  final DateTime selectedDate;
  final String? selectedDepartureTime;
  final String? selectedReturnTime;
  final ScheduleEntity? selectedDepartureSchedule;
  final ScheduleEntity? selectedReturnSchedule;
  final CityEntity? selectedCity;
  final UniversityEntity? selectedUniversity;
  final BoardingStationEntity? selectedStation;
  final ArrivalStationEntity? selectedArrivalStation;
  final UniversityBoardingPointEntity? selectedUniBoardingPoint;
  final UniversityArrivalPointEntity? selectedUniArrivalPoint;
  final BookingSelectionType selectionType;
  final int passengerCount;
  final bool splitPreference;
  final bool isLadiesOnly;

  BookingStateModel({
    required this.tripType,
    required this.isToUniversity,
    required this.selectedPlanIndex,
    required this.selectedDate,
    this.selectedDepartureTime,
    this.selectedReturnTime,
    this.selectedDepartureSchedule,
    this.selectedReturnSchedule,
    this.selectedCity,
    this.selectedUniversity,
    this.selectedStation,
    this.selectedArrivalStation,
    this.selectedUniBoardingPoint,
    this.selectedUniArrivalPoint,
    this.selectionType = BookingSelectionType.seat,
    this.passengerCount = 1,
    this.splitPreference = true,
    this.isLadiesOnly = false,
  });

  BookingStateModel copyWith({
    TripType? tripType,
    bool? isToUniversity,
    int? selectedPlanIndex,
    DateTime? selectedDate,
    String? selectedDepartureTime,
    String? selectedReturnTime,
    ScheduleEntity? selectedDepartureSchedule,
    ScheduleEntity? selectedReturnSchedule,
    CityEntity? selectedCity,
    UniversityEntity? selectedUniversity,
    BoardingStationEntity? selectedStation,
    ArrivalStationEntity? selectedArrivalStation,
    UniversityBoardingPointEntity? selectedUniBoardingPoint,
    UniversityArrivalPointEntity? selectedUniArrivalPoint,
    BookingSelectionType? selectionType,
    int? passengerCount,
    bool? splitPreference,
    bool? isLadiesOnly,
  }) {
    return BookingStateModel(
      tripType: tripType ?? this.tripType,
      isToUniversity: isToUniversity ?? this.isToUniversity,
      selectedPlanIndex: selectedPlanIndex ?? this.selectedPlanIndex,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDepartureTime:
          selectedDepartureTime ?? this.selectedDepartureTime,
      selectedReturnTime: selectedReturnTime ?? this.selectedReturnTime,
      selectedDepartureSchedule:
          selectedDepartureSchedule ?? this.selectedDepartureSchedule,
      selectedReturnSchedule:
          selectedReturnSchedule ?? this.selectedReturnSchedule,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedUniversity: selectedUniversity ?? this.selectedUniversity,
      selectedStation: selectedStation ?? this.selectedStation,
      selectedArrivalStation:
          selectedArrivalStation ?? this.selectedArrivalStation,
      selectedUniBoardingPoint:
          selectedUniBoardingPoint ?? this.selectedUniBoardingPoint,
      selectedUniArrivalPoint:
          selectedUniArrivalPoint ?? this.selectedUniArrivalPoint,
      selectionType: selectionType ?? this.selectionType,
      passengerCount: passengerCount ?? this.passengerCount,
      splitPreference: splitPreference ?? this.splitPreference,
      isLadiesOnly: isLadiesOnly ?? this.isLadiesOnly,
    );
  }
}
