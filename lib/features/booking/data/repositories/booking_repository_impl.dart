import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingDataSource _dataSource;
  final String Function() _getUserId;

  BookingRepositoryImpl(this._dataSource, this._getUserId);

  @override
  Future<Either<Failure, BookingEntity>> createUniversityRequest({
    required DateTime bookingDate,
    required String universityId,
    String? cityId,
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
    try {
      final userId = _getUserId();
      final booking = await _dataSource.createUniversityRequest(
        userId: userId,
        cityId: cityId,
        bookingDate: bookingDate,
        universityId: universityId,
        routeId: routeId,
        uniBoardingPointId: uniBoardingPointId,
        uniArrivalPointId: uniArrivalPointId,
        isCustomUniversity: isCustomUniversity,
        customUniversityName: customUniversityName,
        departureTime: departureTime,
        returnTime: returnTime,
        selectionType: selectionType,
        passengerCount: passengerCount,
        splitPreference: splitPreference,
        totalPrice: totalPrice,
        isLadies: isLadies,
      );
      return Right(booking);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> createBooking({
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
    try {
      final userId = _getUserId();
      final booking = await _dataSource.createBooking(
        userId: userId,
        cityId: cityId,
        scheduleId: scheduleId,
        bookingDate: bookingDate,
        tripType: tripType,
        pickupStationId: pickupStationId,
        dropoffStationId: dropoffStationId,
        departureTime: departureTime,
        returnTime: returnTime,
        paymentProofImage: paymentProofImage,
        transferNumber: transferNumber,
        totalPrice: totalPrice,
        selectionType: selectionType,
        passengerCount: passengerCount,
        splitPreference: splitPreference,
        isLadies: isLadies,
      );
      return Right(booking);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getUserBookings() async {
    try {
      final userId = _getUserId();
      final bookings = await _dataSource.getUserBookings(userId);
      return Right(bookings);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BookingEntity?>> getUpcomingBooking() async {
    try {
      final userId = _getUserId();
      final booking = await _dataSource.getUpcomingBooking(userId);
      return Right(booking);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingById(String id) async {
    try {
      final booking = await _dataSource.getBookingById(id);
      return Right(booking);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> updateBooking({
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
    try {
      final booking = await _dataSource.updateBooking(
        bookingId: bookingId,
        cityId: cityId,
        bookingDate: bookingDate,
        tripType: tripType,
        pickupStationId: pickupStationId,
        dropoffStationId: dropoffStationId,
        departureTime: departureTime,
        returnTime: returnTime,
        totalPrice: totalPrice,
        selectionType: selectionType,
        passengerCount: passengerCount,
        splitPreference: splitPreference,
        isLadies: isLadies,
      );
      return Right(booking);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> transferBooking({
    required String bookingId,
    String? targetUserId,
    String? targetPhoneNumber,
  }) async {
    try {
      final booking = await _dataSource.transferBooking(
        bookingId: bookingId,
        targetUserId: targetUserId,
        targetPhoneNumber: targetPhoneNumber,
      );
      return Right(booking);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, String>> generateInviteLink({
    required String bookingId,
  }) async {
    try {
      // In a real app, this would use a deep linking service like Firebase Dynamic Links
      // For now, we'll generate a simple URL with the booking ID
      final inviteLink = 'https://fielsekka.app/invite?bookingId=$bookingId';
      return Right(inviteLink);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> cancelBooking(String bookingId) async {
    try {
      final booking = await _dataSource.cancelBooking(bookingId);
      return Right(booking);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> updatePaymentStatus({
    required String bookingId,
    required PaymentStatus paymentStatus,
  }) async {
    try {
      final booking = await _dataSource.updatePaymentStatus(
        bookingId: bookingId,
        paymentStatus: paymentStatus.name,
      );
      return Right(booking);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleEntity>>> getSchedules({
    required String universityId,
    required DateTime date,
  }) async {
    return const Left(
      ServerFailure(message: 'getSchedules via booking is not yet implemented'),
    );
  }

  @override
  Stream<List<BookingEntity>> watchUserBookings() {
    return Stream.error(
      const ServerFailure(message: 'Real-time booking updates are not yet implemented'),
    );
  }

  @override
  Future<Either<Failure, void>> createRouteRequest({
    String? cityId,
    String? cityName,
    required String boardingStationName,
    required String universityName,
  }) async {
    try {
      final userId = _getUserId();
      await _dataSource.createRouteRequest(
        userId: userId,
        cityId: cityId,
        cityName: cityName,
        boardingStationName: boardingStationName,
        universityName: universityName,
      );
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(Object error) {
    if (error.toString().contains('Database error')) {
      return ServerFailure(message: error.toString());
    }
    return ServerFailure(message: 'An unexpected error occurred: $error');
  }
}
