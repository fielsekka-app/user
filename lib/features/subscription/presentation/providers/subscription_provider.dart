import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../data/datasources/subscription_data_source.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/logger_service.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../../booking/presentation/providers/booking_providers.dart';
import '../../domain/usecases/create_subscription_use_case.dart';
import '../../domain/usecases/get_active_subscription_use_case.dart';
import '../../domain/usecases/cancel_subscription_use_case.dart';

import '../../../../core/config/mock_data_sources.dart';

part 'subscription_provider.g.dart';

@riverpod
SubscriptionDataSource subscriptionDataSource(Ref ref) {
  return MockSubscriptionDataSource();
}

@riverpod
SubscriptionRepository subscriptionRepository(Ref ref) {
  final dataSource = ref.watch(subscriptionDataSourceProvider);
  final bookingDataSource = ref.watch(bookingDataSourceProvider);
  return SubscriptionRepositoryImpl(dataSource, bookingDataSource);
}

// Use Case Providers (non-generated, plain Riverpod)
final createSubscriptionUseCaseProvider =
    Provider<CreateSubscriptionUseCase>((ref) {
  return CreateSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

final getActiveSubscriptionUseCaseProvider =
    Provider<GetActiveSubscriptionUseCase>((ref) {
  return GetActiveSubscriptionUseCase(
    ref.watch(subscriptionRepositoryProvider),
  );
});

final cancelSubscriptionUseCaseProvider =
    Provider<CancelSubscriptionUseCase>((ref) {
  return CancelSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

// User Subscriptions Provider (all subscriptions)
@riverpod
Future<List<SubscriptionEntity>> userSubscriptions(Ref ref) async {
  final userAsync = ref.watch(authProvider);
  final user = userAsync.value;
  if (user == null) {
    return [];
  }

  final repository = ref.watch(subscriptionRepositoryProvider);
  final result = await repository.getUserSubscriptions(user.id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (subscriptions) => subscriptions,
  );
}

// Active Subscription Provider (current active subscription)
@riverpod
Future<SubscriptionEntity?> activeSubscription(Ref ref) async {
  final subscriptions = await ref.watch(userSubscriptionsProvider.future);

  // Find the first active or pending subscription
  try {
    LoggerService.info(
      'DEBUG: Filtering ${subscriptions.length} subscriptions for active/pending',
    );
    final activeSub = subscriptions.firstWhere((sub) {
      final isActiveOrPending =
          sub.status == SubscriptionStatus.active ||
          sub.status == SubscriptionStatus.pending;
      final isNotExpired = sub.endDate.isAfter(DateTime.now());
      LoggerService.info(
        'DEBUG: Sub ${sub.id}: Status=${sub.status}, End=${sub.endDate}, Active/Pending=$isActiveOrPending, NotExpired=$isNotExpired',
      );
      return isActiveOrPending && isNotExpired;
    });
    LoggerService.info('DEBUG: Found active subscription: ${activeSub.id}');
    return activeSub;
  } catch (e) {
    LoggerService.info('DEBUG: No active subscription found: $e');
    return null;
  }
}
