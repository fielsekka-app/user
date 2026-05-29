import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:fielsekkia_user/core/domain/entities/user_entity.dart';
import 'package:fielsekkia_user/core/config/mock_data.dart';
import 'package:fielsekkia_user/core/error/failures.dart';
import 'package:fielsekkia_user/features/auth/data/datasources/auth_data_source.dart';
import 'package:fielsekkia_user/features/auth/data/models/user_model.dart';
import 'package:fielsekkia_user/features/booking/data/datasources/booking_data_source.dart';
import 'package:fielsekkia_user/features/booking/data/models/booking_model.dart';
import 'package:fielsekkia_user/features/booking/domain/entities/booking_entity.dart';
import 'package:fielsekkia_user/features/home/data/datasources/home_remote_data_source.dart';
import 'package:fielsekkia_user/features/home/data/models/arrival_station_model.dart';
import 'package:fielsekkia_user/features/home/data/models/boarding_station_model.dart';
import 'package:fielsekkia_user/features/home/data/models/city_model.dart';
import 'package:fielsekkia_user/features/home/data/models/route_model.dart';
import 'package:fielsekkia_user/features/home/data/models/schedule_model.dart';
import 'package:fielsekkia_user/features/home/data/models/university_arrival_point_model.dart';
import 'package:fielsekkia_user/features/home/data/models/university_boarding_point_model.dart';
import 'package:fielsekkia_user/features/home/data/models/university_model.dart';
import 'package:fielsekkia_user/features/profile/data/repositories/wallet_repository.dart';
import 'package:fielsekkia_user/features/subscription/data/datasources/subscription_data_source.dart';
import 'package:fielsekkia_user/features/subscription/domain/entities/subscription_entity.dart';

// ==========================================
// 1. Mock Auth Data Source
// ==========================================
class MockAuthDataSource implements AuthDataSource {
  @override
  Stream<UserModel?> authStateChanges() {
    // Emit initial user state
    Timer.run(() => MockData.authStreamController.add(MockData.currentUser));
    return MockData.authStreamController.stream;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return MockData.currentUser;
  }

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final mockUser = UserModel(
      id: 'mock_user_123',
      email: email,
      phone: '01012345678',
      fullName: email.split('@')[0],
      userType: UserType.student,
      isVerified: true,
      createdAt: DateTime.now(),
      subscriptionStatus: 'active',
      subscriptionType: 'monthly',
      subscriptionStartDate: DateTime.now().subtract(const Duration(days: 5)),
      subscriptionEndDate: DateTime.now().add(const Duration(days: 25)),
      city: 'منوف',
      cityId: 'c1',
    );
    MockData.currentUser = mockUser;
    MockData.authStreamController.add(mockUser);
    return mockUser;
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? studentId,
    String? universityId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final mockUser = UserModel(
      id: 'mock_user_123',
      email: email,
      phone: phone,
      fullName: fullName,
      userType: UserType.student,
      isVerified: true,
      createdAt: DateTime.now(),
      studentId: studentId,
      universityId: universityId,
      city: 'منوف',
      cityId: 'c1',
    );
    MockData.currentUser = mockUser;
    MockData.authStreamController.add(mockUser);
    return mockUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockData.currentUser = null;
    MockData.authStreamController.add(null);
  }

  @override
  Future<UserModel> verifyOtp({required String email, required String otp}) async {
    if (MockData.currentUser != null) {
      return MockData.currentUser!;
    }
    throw Exception('No pending authentication session found');
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (MockData.currentUser == null) throw Exception('User not logged in');
    
    final updated = UserModel(
      id: MockData.currentUser!.id,
      email: MockData.currentUser!.email,
      phone: phone,
      fullName: fullName,
      userType: MockData.currentUser!.userType,
      isVerified: MockData.currentUser!.isVerified,
      createdAt: MockData.currentUser!.createdAt,
      avatarUrl: avatarUrl ?? MockData.currentUser!.avatarUrl,
      subscriptionStatus: MockData.currentUser!.subscriptionStatus,
      subscriptionType: MockData.currentUser!.subscriptionType,
      subscriptionStartDate: MockData.currentUser!.subscriptionStartDate,
      subscriptionEndDate: MockData.currentUser!.subscriptionEndDate,
      city: MockData.currentUser!.city,
      cityId: MockData.currentUser!.cityId,
    );
    
    MockData.currentUser = updated;
    MockData.authStreamController.add(updated);
    return updated;
  }

  @override
  Future<String> uploadProfileImage({required File image, required String userId}) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'https://api.dicebear.com/7.x/bottts/svg?seed=fielsekka';
  }
}

// ==========================================
// 2. Mock Home Remote Data Source
// ==========================================
class MockHomeRemoteDataSource implements HomeRemoteDataSource {
  @override
  Future<List<CityModel>> getCities() async => MockData.cities;

  @override
  Future<List<UniversityModel>> getUniversities(String cityId) async {
    return MockData.universities.where((u) => u.cityId == cityId).toList();
  }

  @override
  Future<List<BoardingStationModel>> getBoardingStations(String cityId) async {
    return MockData.boardingStations.where((b) => b.cityId == cityId).toList();
  }

  @override
  Future<List<ArrivalStationModel>> getArrivalStations(String pickupStationId) async {
    return MockData.arrivalStations.where((a) => a.pickupStationId == pickupStationId).toList();
  }

  @override
  Future<List<RouteModel>> getRoutes(String universityId) async {
    return MockData.routes.where((r) => r.universityId == universityId).toList();
  }

  @override
  Future<List<BoardingStationModel>> getAllBoardingStations() async => MockData.boardingStations;

  @override
  Future<List<ArrivalStationModel>> getAllArrivalStations() async => MockData.arrivalStations;

  @override
  Future<List<UniversityModel>> getAllUniversities() async => MockData.universities;

  @override
  Future<List<ScheduleModel>> getSchedules(String routeId) async {
    return MockData.schedules.where((s) => s.routeId == routeId).toList();
  }

  @override
  Future<List<UniversityBoardingPointModel>> getUniversityBoardingPoints(String cityId) async {
    return MockData.universityBoardingPoints.where((p) => p.cityId == cityId).toList();
  }

  @override
  Future<List<UniversityArrivalPointModel>> getUniversityArrivalPoints(String universityId) async {
    return MockData.universityArrivalPoints.where((p) => p.universityId == universityId).toList();
  }

  @override
  Future<List<String>> getUniqueOrigins(String cityId) async {
    return ['منوف', 'أشمون', 'شبين الكوم'];
  }

  @override
  Future<List<String>> getAvailableDestinations(String originName, {String? cityId}) async {
    return ['كلية الهندسة بشبين', 'المجمع الطبي بشبين', 'جامعة مدينة السادات'];
  }
}

// ==========================================
// 3. Mock Booking Data Source
// ==========================================
class MockBookingDataSource implements BookingDataSource {
  @override
  Future<BookingModel> createBooking({
    required String userId,
    String? cityId,
    String? scheduleId,
    required DateTime bookingDate,
    required String tripType,
    String? pickupStationId,
    String? dropoffStationId,
    String? departureTime,
    String? returnTime,
    String? paymentProofImage,
    String? transferNumber,
    required double totalPrice,
    BookingSelectionType selectionType = BookingSelectionType.seat,
    int passengerCount = 1,
    bool splitPreference = true,
    bool isLadies = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newJson = {
      'id': 'book_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'city_id': cityId,
      'schedule_id': scheduleId,
      'booking_date': bookingDate.toIso8601String(),
      'trip_type': tripType,
      'pickup_station_id': pickupStationId,
      'dropoff_station_id': dropoffStationId,
      'departure_time': departureTime,
      'return_time': returnTime,
      'payment_proof_image': paymentProofImage,
      'transfer_number': transferNumber,
      'status': 'confirmed',
      'payment_status': 'paid',
      'selection_type': selectionType.name,
      'passenger_count': passengerCount,
      'split_preference': splitPreference,
      'total_price': totalPrice,
      'is_ladies': isLadies,
      'is_university_request': false,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    MockData.bookings.add(newJson);
    return BookingModel.fromJson(newJson);
  }

  @override
  Future<BookingModel> createUniversityRequest({
    required String userId,
    String? cityId,
    required DateTime bookingDate,
    required String universityId,
    String? routeId,
    String? uniBoardingPointId,
    String? uniArrivalPointId,
    required bool isCustomUniversity,
    String? customUniversityName,
    String? departureTime,
    String? returnTime,
    required double totalPrice,
    BookingSelectionType selectionType = BookingSelectionType.seat,
    int passengerCount = 1,
    bool splitPreference = true,
    bool isLadies = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newJson = {
      'id': 'book_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'city_id': cityId,
      'booking_date': bookingDate.toIso8601String(),
      'trip_type': 'university_request',
      'university_id': universityId,
      'route_id': routeId,
      'uni_boarding_point_id': uniBoardingPointId,
      'uni_arrival_point_id': uniArrivalPointId,
      'is_university_request': true,
      'departure_time': departureTime,
      'return_time': returnTime,
      'status': 'pending',
      'payment_status': 'unpaid',
      'selection_type': selectionType.name,
      'passenger_count': passengerCount,
      'split_preference': splitPreference,
      'total_price': totalPrice,
      'is_ladies': isLadies,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    MockData.bookings.add(newJson);
    return BookingModel.fromJson(newJson);
  }

  @override
  Future<BookingModel> createSubscriptionBooking({
    required String userId,
    required String subscriptionId,
    required String scheduleId,
    required DateTime bookingDate,
    required String tripType,
    String? pickupStationId,
    String? dropoffStationId,
    String? departureTime,
    String? returnTime,
    required double totalPrice,
    bool isLadies = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newJson = {
      'id': 'book_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'subscription_id': subscriptionId,
      'schedule_id': scheduleId,
      'booking_date': bookingDate.toIso8601String(),
      'trip_type': tripType,
      'pickup_station_id': pickupStationId,
      'dropoff_station_id': dropoffStationId,
      'departure_time': departureTime,
      'return_time': returnTime,
      'status': 'confirmed',
      'payment_status': 'paid',
      'total_price': totalPrice,
      'is_ladies': isLadies,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    MockData.bookings.add(newJson);
    return BookingModel.fromJson(newJson);
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    return MockData.bookings.map((e) => BookingModel.fromJson(e)).toList();
  }

  @override
  Future<BookingModel?> getUpcomingBooking(String userId) async {
    final list = MockData.bookings
        .map((e) => BookingModel.fromJson(e))
        .where((b) => b.bookingDate.add(const Duration(days: 1)).isAfter(DateTime.now()))
        .toList();
    if (list.isEmpty) return null;
    list.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
    return list.first;
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    final data = MockData.bookings.firstWhere((element) => element['id'] == bookingId);
    return BookingModel.fromJson(data);
  }

  @override
  Future<BookingModel> updateBooking({
    required String bookingId,
    String? cityId,
    required DateTime bookingDate,
    required String tripType,
    String? pickupStationId,
    String? dropoffStationId,
    String? departureTime,
    String? returnTime,
    required double totalPrice,
    BookingSelectionType selectionType = BookingSelectionType.seat,
    int passengerCount = 1,
    bool splitPreference = true,
    bool isLadies = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = MockData.bookings.indexWhere((element) => element['id'] == bookingId);
    if (idx == -1) throw Exception('Booking not found');
    
    final updated = Map<String, dynamic>.from(MockData.bookings[idx]);
    updated['city_id'] = cityId;
    updated['booking_date'] = bookingDate.toIso8601String();
    updated['trip_type'] = tripType;
    updated['pickup_station_id'] = pickupStationId;
    updated['dropoff_station_id'] = dropoffStationId;
    updated['departure_time'] = departureTime;
    updated['return_time'] = returnTime;
    updated['total_price'] = totalPrice;
    updated['selection_type'] = selectionType.name;
    updated['passenger_count'] = passengerCount;
    updated['split_preference'] = splitPreference;
    updated['is_ladies'] = isLadies;
    updated['updated_at'] = DateTime.now().toIso8601String();

    MockData.bookings[idx] = updated;
    return BookingModel.fromJson(updated);
  }

  @override
  Future<BookingModel> transferBooking({
    required String bookingId,
    String? targetUserId,
    String? targetPhoneNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = MockData.bookings.indexWhere((element) => element['id'] == bookingId);
    if (idx == -1) throw Exception('Booking not found');
    
    final updated = Map<String, dynamic>.from(MockData.bookings[idx]);
    if (targetUserId != null) {
      updated['user_id'] = targetUserId;
    }
    updated['updated_at'] = DateTime.now().toIso8601String();
    MockData.bookings[idx] = updated;
    return BookingModel.fromJson(updated);
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = MockData.bookings.indexWhere((element) => element['id'] == bookingId);
    if (idx == -1) throw Exception('Booking not found');
    
    final updated = Map<String, dynamic>.from(MockData.bookings[idx]);
    updated['status'] = 'cancelled';
    updated['updated_at'] = DateTime.now().toIso8601String();
    MockData.bookings[idx] = updated;
    return BookingModel.fromJson(updated);
  }

  @override
  Future<BookingModel> updatePaymentStatus({required String bookingId, required String paymentStatus}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = MockData.bookings.indexWhere((element) => element['id'] == bookingId);
    if (idx == -1) throw Exception('Booking not found');
    
    final updated = Map<String, dynamic>.from(MockData.bookings[idx]);
    updated['payment_status'] = paymentStatus;
    updated['updated_at'] = DateTime.now().toIso8601String();
    MockData.bookings[idx] = updated;
    return BookingModel.fromJson(updated);
  }

  @override
  Future<void> createRouteRequest({
    required String userId,
    String? cityId,
    String? cityName,
    required String boardingStationName,
    required String universityName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// ==========================================
// 4. Mock Subscription Data Source
// ==========================================
class MockSubscriptionDataSource implements SubscriptionDataSource {
  @override
  Future<String> createSubscription({
    required String userId,
    required SubscriptionPlanType planType,
    required String? paymentProofUrl,
    required String? transferNumber,
    bool isInstallment = false,
    String? tripType,
    String? pickupStationId,
    String? dropoffStationId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final id = 'sub_${DateTime.now().millisecondsSinceEpoch}';
    final newSub = {
      'id': id,
      'user_id': userId,
      'plan_type': planType.name,
      'total_price': planType.price,
      'payment_proof_url': paymentProofUrl,
      'transfer_number': transferNumber,
      'status': 'pending',
      'start_date': DateTime.now().toIso8601String(),
      'end_date': DateTime.now().add(Duration(days: planType.durationDays)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'allow_location_change': planType == SubscriptionPlanType.semester,
      'is_installment': isInstallment,
      'trip_type': tripType ?? 'round_trip',
      'pickup_station_id': pickupStationId,
      'dropoff_station_id': dropoffStationId,
    };
    MockData.subscriptions.add(newSub);
    
    // Update user profile status
    if (MockData.currentUser != null && MockData.currentUser!.id == userId) {
      MockData.currentUser = UserModel(
        id: MockData.currentUser!.id,
        email: MockData.currentUser!.email,
        phone: MockData.currentUser!.phone,
        fullName: MockData.currentUser!.fullName,
        userType: MockData.currentUser!.userType,
        isVerified: MockData.currentUser!.isVerified,
        createdAt: MockData.currentUser!.createdAt,
        subscriptionStatus: 'pending',
        subscriptionType: planType.name,
        subscriptionStartDate: DateTime.now(),
        subscriptionEndDate: DateTime.now().add(Duration(days: planType.durationDays)),
        city: MockData.currentUser!.city,
        cityId: MockData.currentUser!.cityId,
      );
      MockData.authStreamController.add(MockData.currentUser);
    }

    return id;
  }

  @override
  Future<Map<String, dynamic>?> getUserSubscription(String userId) async {
    if (MockData.currentUser == null) return null;
    return {
      'subscription_type': MockData.currentUser!.subscriptionType,
      'subscription_start_date': MockData.currentUser!.subscriptionStartDate?.toIso8601String(),
      'subscription_end_date': MockData.currentUser!.subscriptionEndDate?.toIso8601String(),
      'subscription_status': MockData.currentUser!.subscriptionStatus,
      'trip_type': 'round_trip',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getUserSubscriptions(String userId) async {
    return MockData.subscriptions;
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = MockData.subscriptions.indexWhere((element) => element['id'] == subscriptionId);
    if (idx != -1) {
      MockData.subscriptions[idx]['status'] = 'expired';
    }
    
    if (MockData.currentUser != null) {
      MockData.currentUser = UserModel(
        id: MockData.currentUser!.id,
        email: MockData.currentUser!.email,
        phone: MockData.currentUser!.phone,
        fullName: MockData.currentUser!.fullName,
        userType: MockData.currentUser!.userType,
        isVerified: MockData.currentUser!.isVerified,
        createdAt: MockData.currentUser!.createdAt,
        subscriptionStatus: 'expired',
        subscriptionType: MockData.currentUser!.subscriptionType,
        subscriptionStartDate: MockData.currentUser!.subscriptionStartDate,
        subscriptionEndDate: MockData.currentUser!.subscriptionEndDate,
        city: MockData.currentUser!.city,
        cityId: MockData.currentUser!.cityId,
      );
      MockData.authStreamController.add(MockData.currentUser);
    }
  }
}

// ==========================================
// 5. Mock Wallet Repository
// ==========================================
class MockWalletRepository implements WalletRepository {
  @override
  Future<Either<Failure, double>> getBalance(String userId) async {
    return Right(MockData.walletBalance);
  }

  @override
  Future<Either<Failure, double>> deductAmount(String userId, double amount, String reason) async {
    if (MockData.walletBalance < amount) {
      return const Left(ServerFailure(message: 'رصيد غير كافي'));
    }
    MockData.walletBalance -= amount;
    MockData.walletTransactions.add({
      'id': 't_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'amount': -amount,
      'reason': reason,
      'type': 'payment',
      'created_at': DateTime.now().toIso8601String(),
    });
    return Right(MockData.walletBalance);
  }

  @override
  Future<Either<Failure, double>> addAmount(String userId, double amount, String reason) async {
    MockData.walletBalance += amount;
    MockData.walletTransactions.add({
      'id': 't_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'amount': amount,
      'reason': reason,
      'type': 'topup',
      'created_at': DateTime.now().toIso8601String(),
    });
    return Right(MockData.walletBalance);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTransactions(String userId) async {
    return Right(MockData.walletTransactions);
  }

  @override
  Future<Either<Failure, void>> createWalletRequest({
    required String userId,
    required double amount,
    required String method,
    File? imageFile,
    required String phoneNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Auto-approve topup in mock mode for best user experience!
    MockData.walletBalance += amount;
    MockData.walletTransactions.add({
      'id': 't_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'amount': amount,
      'reason': 'شحن المحفظة ($method)',
      'type': 'topup',
      'created_at': DateTime.now().toIso8601String(),
    });
    return const Right(null);
  }
}
