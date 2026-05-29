import 'dart:async';
import 'package:fielsekkia_user/core/domain/entities/user_entity.dart';
import 'package:fielsekkia_user/features/auth/data/models/user_model.dart';
import 'package:fielsekkia_user/features/home/data/models/city_model.dart';
import 'package:fielsekkia_user/features/home/data/models/university_model.dart';
import 'package:fielsekkia_user/features/booking/domain/entities/university_entity.dart' as uni;
import 'package:fielsekkia_user/features/home/data/models/boarding_station_model.dart';
import 'package:fielsekkia_user/features/home/data/models/arrival_station_model.dart';
import 'package:fielsekkia_user/features/home/data/models/route_model.dart';
import 'package:fielsekkia_user/features/home/data/models/schedule_model.dart';
import 'package:fielsekkia_user/features/booking/domain/entities/schedule_entity.dart';
import 'package:fielsekkia_user/features/home/data/models/university_boarding_point_model.dart';
import 'package:fielsekkia_user/features/home/data/models/university_arrival_point_model.dart';

class MockData {
  // Current user state
  static UserModel? currentUser = UserModel(
    id: 'mock_user_123',
    email: 'user@fielsekka.app',
    phone: '01012345678',
    fullName: 'عبدالله العوضي',
    userType: UserType.student,
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    subscriptionStatus: 'active',
    subscriptionType: 'monthly',
    subscriptionStartDate: DateTime.now().subtract(const Duration(days: 5)),
    subscriptionEndDate: DateTime.now().add(const Duration(days: 25)),
    city: 'منوف',
    cityId: 'c1',
  );

  // Stream controller for auth changes
  static final StreamController<UserModel?> authStreamController = StreamController<UserModel?>.broadcast();

  // Wallet
  static double walletBalance = 350.0;
  static List<Map<String, dynamic>> walletTransactions = [
    {
      'id': 't1',
      'user_id': 'mock_user_123',
      'amount': 350.0,
      'reason': 'شحن المحفظة (فودافون كاش)',
      'type': 'topup',
      'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    },
    {
      'id': 't2',
      'user_id': 'mock_user_123',
      'amount': -80.0,
      'reason': 'حجز رحلة ذهاب وعودة',
      'type': 'payment',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    }
  ];

  // Subscriptions
  static List<Map<String, dynamic>> subscriptions = [
    {
      'id': 'sub_123',
      'user_id': 'mock_user_123',
      'plan_type': 'monthly',
      'total_price': 600.0,
      'payment_proof_url': 'https://dummy.url/proof.png',
      'transfer_number': '01012345678',
      'status': 'active',
      'start_date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'end_date': DateTime.now().add(const Duration(days: 25)).toIso8601String(),
      'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'allow_location_change': false,
      'is_installment': false,
      'trip_type': 'round_trip',
      'pickup_station_id': 'b1',
      'dropoff_station_id': 'a1',
    }
  ];

  // Bookings
  static List<Map<String, dynamic>> bookings = [
    // Pre-populate an upcoming booking for tomorrow
    {
      'id': 'book_tomorrow',
      'user_id': 'mock_user_123',
      'city_id': 'c1',
      'pickup_station_id': 'b1',
      'dropoff_station_id': 'a1',
      'booking_date': DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0],
      'trip_type': 'round_trip',
      'departure_time': '07:30:00',
      'return_time': '15:00:00',
      'status': 'confirmed',
      'payment_status': 'paid',
      'total_price': 80.0,
      'selection_type': 'seat',
      'passenger_count': 1,
      'split_preference': true,
      'is_ladies': false,
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'subscription_id': 'sub_123',
    },
    // Past booking
    {
      'id': 'book_past',
      'user_id': 'mock_user_123',
      'city_id': 'c1',
      'pickup_station_id': 'b1',
      'dropoff_station_id': 'a1',
      'booking_date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String().split('T')[0],
      'trip_type': 'round_trip',
      'departure_time': '07:30:00',
      'return_time': '15:00:00',
      'status': 'confirmed',
      'payment_status': 'paid',
      'total_price': 80.0,
      'selection_type': 'seat',
      'passenger_count': 1,
      'split_preference': true,
      'is_ladies': false,
      'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'subscription_id': 'sub_123',
    }
  ];

  // Static items for Home page Selection
  static final List<CityModel> cities = [
    const CityModel(id: 'c1', nameAr: 'منوف', nameEn: 'Menouf', isActive: true, hasPointToPoint: true, hasUniversityService: true),
    const CityModel(id: 'c2', nameAr: 'شبين الكوم', nameEn: 'Shebin El-Kom', isActive: true, hasPointToPoint: true, hasUniversityService: true),
    const CityModel(id: 'c3', nameAr: 'السادات', nameEn: 'Sadat City', isActive: true, hasPointToPoint: true, hasUniversityService: true),
    const CityModel(id: 'c4', nameAr: 'أشمون', nameEn: 'Ashmoun', isActive: true, hasPointToPoint: true, hasUniversityService: true),
  ];

  static final List<UniversityModel> universities = [
    const UniversityModel(
      id: 'u1',
      cityId: 'c2',
      nameAr: 'جامعة المنوفية (شبين الكوم)',
      nameEn: 'Menoufia University (Shebin)',
      location: uni.Location(latitude: 30.5612, longitude: 31.0112, address: 'شبين الكوم، المنوفية'),
      isActive: true,
    ),
    const UniversityModel(
      id: 'u2',
      cityId: 'c3',
      nameAr: 'جامعة مدينة السادات',
      nameEn: 'Sadat City University',
      location: uni.Location(latitude: 30.3789, longitude: 30.5212, address: 'مدينة السادات، المنوفية'),
      isActive: true,
    ),
    const UniversityModel(
      id: 'u3',
      cityId: 'c2',
      nameAr: 'جامعة المنوفية الأهلية',
      nameEn: 'Menoufia National University',
      location: uni.Location(latitude: 30.5890, longitude: 31.0250, address: 'طريق طنطا شبين، المنوفية'),
      isActive: true,
    ),
  ];

  static final List<BoardingStationModel> boardingStations = [
    const BoardingStationModel(id: 'b1', cityId: 'c1', nameAr: 'موقف منوف العمومي', nameEn: 'Menouf Station'),
    const BoardingStationModel(id: 'b2', cityId: 'c2', nameAr: 'مكتب في السكة شبين الكوم', nameEn: 'Fi El Sekka Shebin'),
    const BoardingStationModel(id: 'b3', cityId: 'c3', nameAr: 'موقف مدينة السادات', nameEn: 'Sadat Station'),
    const BoardingStationModel(id: 'b4', cityId: 'c4', nameAr: 'موقف أشمون الرئيسي', nameEn: 'Ashmoun Station'),
  ];

  static final List<ArrivalStationModel> arrivalStations = [
    const ArrivalStationModel(
      id: 'a1',
      pickupStationId: 'b1',
      nameAr: 'مجمع الكليات بشبين الكوم',
      nameEn: 'Colleges Complex in Shebin',
      price: 15.0,
      schedules: ['07:30 AM', '08:30 AM', '09:30 AM'],
    ),
    const ArrivalStationModel(
      id: 'a2',
      pickupStationId: 'b1',
      nameAr: 'المجمع الطبي بشبين الكوم',
      nameEn: 'Medical Complex in Shebin',
      price: 15.0,
      schedules: ['07:30 AM', '08:30 AM'],
    ),
    const ArrivalStationModel(
      id: 'a3',
      pickupStationId: 'b4',
      nameAr: 'جامعة مدينة السادات (المجمع الأول)',
      nameEn: 'Sadat University (Complex 1)',
      price: 20.0,
      schedules: ['07:00 AM', '08:00 AM'],
    ),
  ];

  static final List<RouteModel> routes = [
    const RouteModel(
      id: 'r1',
      universityId: 'u1',
      routeNameAr: 'منوف - جامعة المنوفية بشبين',
      routeNameEn: 'Menouf - Menoufia University Shebin',
      routeCode: 'MNF-SHB-U',
      stationsOrder: ['b1', 'a1', 'a2'],
      isActive: true,
    ),
    const RouteModel(
      id: 'r2',
      universityId: 'u2',
      routeNameAr: 'أشمون - جامعة مدينة السادات',
      routeNameEn: 'Ashmoun - Sadat City University',
      routeCode: 'ASH-SDT-U',
      stationsOrder: ['b4', 'a3'],
      isActive: true,
    ),
  ];

  static final List<ScheduleModel> schedules = [
    const ScheduleModel(
      id: 's1',
      routeId: 'r1',
      direction: RouteDirection.toUniversity,
      departureTime: '07:30',
      daysOfWeek: [1, 2, 3, 4, 7], // Sun-Thu
      capacity: 14,
      pricePerTrip: 15.0,
      isActive: true,
    ),
    const ScheduleModel(
      id: 's2',
      routeId: 'r1',
      direction: RouteDirection.toUniversity,
      departureTime: '08:30',
      daysOfWeek: [1, 2, 3, 4, 7], // Sun-Thu
      capacity: 14,
      pricePerTrip: 15.0,
      isActive: true,
    ),
    const ScheduleModel(
      id: 's3',
      routeId: 'r1',
      direction: RouteDirection.fromUniversity,
      departureTime: '15:00',
      daysOfWeek: [1, 2, 3, 4, 7], // Sun-Thu
      capacity: 14,
      pricePerTrip: 15.0,
      isActive: true,
    ),
    const ScheduleModel(
      id: 's4',
      routeId: 'r1',
      direction: RouteDirection.fromUniversity,
      departureTime: '16:30',
      daysOfWeek: [1, 2, 3, 4, 7], // Sun-Thu
      capacity: 14,
      pricePerTrip: 15.0,
      isActive: true,
    ),
  ];

  static final List<UniversityBoardingPointModel> universityBoardingPoints = [
    const UniversityBoardingPointModel(id: 'ub1', cityId: 'c1', nameAr: 'نقطة تجمع منوف الرئيسي', nameEn: 'Menouf Main Point'),
    const UniversityBoardingPointModel(id: 'ub2', cityId: 'c2', nameAr: 'نقطة تجمع شبين الكوم', nameEn: 'Shebin Gathering Point'),
  ];

  static final List<UniversityArrivalPointModel> universityArrivalPoints = [
    const UniversityArrivalPointModel(id: 'ua1', universityId: 'u1', nameAr: 'مبنى إدارة الجامعة', nameEn: 'University Admin Building'),
    const UniversityArrivalPointModel(id: 'ua2', universityId: 'u1', nameAr: 'بوابة كلية الحاسبات', nameEn: 'Computers Faculty Gate'),
  ];
}
