import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../models/user_model.dart';
import 'auth_data_source.dart';

/// Supabase implementation of [AuthDataSource].
/// Handles all direct communication with Supabase Auth.
class SupabaseAuthDataSource implements AuthDataSource {
  final SupabaseClient _client;

  SupabaseAuthDataSource(this._client);

  /// Sign up a new user with email and password
  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? studentId,
    String? universityId,
    String userType = 'student',
    String? city,
    String? cityId,
  }) async {
    try {
      LoggerService.info('Auth: Starting signup for $email as $userType');

      // 1. Pre-check for phone uniqueness to provide better UX
      final phoneCheck = await _client
          .from('users')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();

      if (phoneCheck != null) {
        throw Exception('رقم الهاتف مسجل بالفعل. الرجاء استخدام رقم آخر أو تسجيل الدخول.');
      }

      // 2. Sign up with Supabase Auth
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'student_id': studentId,
          'university_id': universityId,
          'user_type': userType,
          'city': city,
          'city_id': cityId,
        },
      );

      if (authResponse.user == null) {
        throw Exception('فشل إنشاء الحساب. الرجاء المحاولة مرة أخرى.');
      }

      final userId = authResponse.user!.id;
      final isVerified = authResponse.session != null;

      // 2. Prepare user data for the database
      final userData = {
        'id': userId,
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'student_id': studentId,
        'university_id': universityId,
        'user_type': userType,
        'is_verified': isVerified,
        'created_at': DateTime.now().toIso8601String(),
        'city': city,
        'city_id': cityId,
      };

      try {
        // 3. Attempt manual insert (upsert handles triggers already having inserted the row)
        await _client.from('users').upsert(userData);
        LoggerService.info('Auth: User profile created/synced for $userId');
        return UserModel.fromJson(userData);
      } catch (e) {
        LoggerService.warning(
            'Auth: Manual upsert failed, fetching existing profile: $e');
        final existing = await _client
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (existing != null) {
          return UserModel.fromJson(existing);
        }

        // Final fallback: use the local data if DB fetch fails but Auth succeeded
        return UserModel.fromJson(userData);
      }
    } on AuthException catch (e) {
      LoggerService.error('Auth Exception during signup', error: e);
      final message = e.message.toLowerCase();
      if (message.contains('user already registered')) {
        throw Exception('هذا البريد الإلكتروني مسجل بالفعل. يمكنك تسجيل الدخول بدلاً من ذلك.');
      }
      if (message.contains('database error saving new user')) {
        throw Exception('عذراً، يبدو أن رقم الهاتف أو البريد الإلكتروني مستخدم بالفعل في حساب آخر. يرجى التأكد من بياناتك.');
      }
      throw Exception('عذراً، حدث خطأ أثناء إنشاء الحساب: ${e.message}');
    } on PostgrestException catch (e) {
      LoggerService.error('Database Exception during signup', error: e);
      if (e.message.contains('users_phone_key') || e.code == '23505') {
        throw Exception('رقم الهاتف هذا مسجل بالفعل. يرجى استخدام رقم آخر.');
      }
      if (e.message.contains('users_email_key')) {
        throw Exception('البريد الإلكتروني مسجل بالفعل. يمكنك تسجيل الدخول بدلاً من ذلك.');
      }
      throw Exception('عذراً، حدث خطأ في قاعدة البيانات. يرجى المحاولة لاحقاً.');
    } catch (e) {
      LoggerService.error('Unexpected Exception during signup', error: e);
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('database error saving new user')) {
        throw Exception('عذراً، هذا الحساب أو رقم الهاتف مسجل لدينا بالفعل. يرجى تسجيل الدخول.');
      }
      throw Exception('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.');
    }
  }

  /// Sign in an existing user with email and password
  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to sign in');
      }

      final userId = authResponse.user!.id;

      // Fetch user data from users table - MUST exist
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        LoggerService.warning(
            'User $userId not found in database during sign in.');
        await signOut();
        throw Exception(
            'هذا الحساب غير موجود في النظام. الرجاء التواصل مع الإدارة.');
      }
      return UserModel.fromJson(response);
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw Exception(
          'بيانات الدخول غير صحيحة، أو لم يتم تفعيل البريد الإلكتروني.',
        );
      }
      throw Exception('Authentication error: ${e.message}');
    } on PostgrestException catch (e) {
      LoggerService.error(
        'Database error in signIn: ${e.message}. Code: ${e.code}, Details: ${e.details}',
        error: e,
      );
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      LoggerService.error('Unexpected error in signIn', error: e);
      throw Exception('Unexpected error during sign in: $e');
    }
  }

  /// Sign out the current user
  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Sign out error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during sign out: $e');
    }
  }

  /// Get the currently authenticated user
  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        return null;
      }

      final userId = session.user.id;

      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle(); // Use maybeSingle() instead of single() to handle 0 or 1 results

      if (response == null) {
        LoggerService.warning('User $userId has auth session but no database record. Logging out.');
        await signOut();
        return null;
      }

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error(
        'Database error in getCurrentUser: ${e.message}. Code: ${e.code}, Details: ${e.details}',
        error: e,
      );
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      LoggerService.error('Unexpected error in getCurrentUser', error: e);
      // No user authenticated
      return null;
    }
  }

  /// Stream of authentication state changes
  @override
  Stream<UserModel?> authStateChanges() {
    return _client.auth.onAuthStateChange.asyncExpand((data) async* {
      final session = data.session;
      if (session == null) {
        yield null;
        return;
      }

      try {
        final authUser = session.user;
        final metadata = authUser.userMetadata ?? {};

        // 1. Emit initial user data from Auth metadata immediately to avoid blocking the UI
        LoggerService.info(
          'Auth: Emitting initial user from metadata for ${authUser.id}',
        );
        yield UserModel(
          id: authUser.id,
          email: authUser.email ?? '',
          phone: metadata['phone'] ?? '',
          fullName: metadata['full_name'] ?? 'مستخدم',
          userType: UserType.fromJson(metadata['user_type'] ?? 'student'),
          studentId: metadata['student_id'],
          universityId: metadata['university_id'],
          avatarUrl: metadata['avatar_url'],
          isVerified: true,
          createdAt: DateTime.tryParse(authUser.createdAt) ?? DateTime.now(),
          officeName: metadata['office_name'],
          stationName: metadata['station_name'],
          businessName: metadata['business_name'],
          city: metadata['city'],
          cityId: metadata['city_id'],
        );

        // 2. Fetch full profile from DB in background
        final userId = authUser.id;
        final response = await _client
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (response != null) {
          LoggerService.info('Auth: Full profile loaded for $userId');
          yield UserModel.fromJson(response);
        } else {
          LoggerService.warning('Auth: No database record found for $userId. Triggering logout.');
          await signOut();
          yield null;
        }
      } catch (e) {
        LoggerService.error('Error in authStateChanges', error: e);
        // We already yielded the metadata version, so the app is at least usable
      }
    });
  }

  /// Verify OTP code
  @override
  Future<UserModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final authResponse = await _client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.signup,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to verify OTP');
      }

      final userId = authResponse.user!.id;

      // Update user verification status
      await _client
          .from('users')
          .update({'is_verified': true})
          .eq('id', userId);

      // Fetch updated user data
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle(); // Use maybeSingle() to handle 0 or 1 results

      if (response == null) {
        throw Exception('فشل في جلب بيانات المستخدم بعد التحقق.');
      }

      return UserModel.fromJson(response);
    } on AuthException catch (e) {
      throw Exception('OTP verification error: ${e.message}');
    } on PostgrestException catch (e) {
      LoggerService.error('Database error in verifyOtp: ${e.message}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      LoggerService.error('Unexpected error in verifyOtp', error: e);
      throw Exception('Unexpected error during OTP verification: $e');
    }
  }

  /// Resend OTP code
  @override
  Future<void> resendOtp({required String email}) async {
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);
    } on AuthException catch (e) {
      throw Exception('Failed to resend OTP: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while resending OTP: $e');
    }
  }

  /// Send password reset email
  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Failed to send reset password email: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during password reset: $e');
    }
  }

  /// Update user profile
  @override
  Future<UserModel> updateProfile({
    required String userId,
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    try {
      final updates = {
        'full_name': fullName,
        'phone': phone,
        'avatar_url': avatarUrl, // Always include, even if null
      };

      // Update user data in users table
      final response = await _client
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .maybeSingle(); // Use maybeSingle() to handle 0 or 1 results

      if (response == null) {
        throw Exception('فشل في تحديث بيانات المستخدم.');
      }

      // Also update Supabase Auth metadata if needed
      await _client.auth.updateUser(UserAttributes(data: updates));

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error(
        'Database error in updateProfile: ${e.message}. Code: ${e.code}, Details: ${e.details}',
        error: e,
      );
      throw Exception('Database error: ${e.message}');
    } on AuthException catch (e) {
      throw Exception('Auth update error: ${e.message}');
    } catch (e) {
      LoggerService.error('Unexpected error in updateProfile', error: e);
      throw Exception('Unexpected error during profile update: $e');
    }
  }

  /// Upload profile image
  @override
  Future<String> uploadProfileImage({
    required File image,
    required String userId,
  }) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName =
          '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;

      await _client.storage
          .from('avatars')
          .upload(
            filePath,
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = _client.storage.from('avatars').getPublicUrl(filePath);
      return imageUrl;
    } on StorageException catch (e) {
      throw Exception('Storage error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during image upload: $e');
    }
  }
}
