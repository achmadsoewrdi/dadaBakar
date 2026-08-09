import 'package:flutter_test/flutter_test.dart';
import 'package:xploria_app/features/subscriptions/domain/models/subscription_tier.dart';
import 'package:xploria_app/features/subscriptions/data/models/subscription_model.dart';
import 'package:xploria_app/core/utils/media_url.dart';

void main() {
  // ---------------------------------------------------------------------------
  // SubscriptionTier enum
  // ---------------------------------------------------------------------------
  group('SubscriptionTier', () {
    test('fromValue("pro") returns yearly', () {
      expect(SubscriptionTier.fromValue('pro'), SubscriptionTier.yearly);
    });

    test('fromValue("premium") returns monthly', () {
      expect(SubscriptionTier.fromValue('premium'), SubscriptionTier.monthly);
    });

    test('fromValue unknown defaults to monthly', () {
      expect(SubscriptionTier.fromValue('free'), SubscriptionTier.monthly);
    });

    test('yearly.value == "pro"', () {
      expect(SubscriptionTier.yearly.value, 'pro');
    });

    test('monthly.value == "premium"', () {
      expect(SubscriptionTier.monthly.value, 'premium');
    });

    test('yearly.durationDays == 365', () {
      expect(SubscriptionTier.yearly.durationDays, 365);
    });

    test('monthly.durationDays == 30', () {
      expect(SubscriptionTier.monthly.durationDays, 30);
    });

    test('all tiers are premium', () {
      for (final tier in SubscriptionTier.values) {
        expect(tier.isPremium, isTrue);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // SubscriptionModel
  // ---------------------------------------------------------------------------
  group('SubscriptionModel', () {
    test('fromJson parses tier correctly', () {
      final model = SubscriptionModel.fromJson({
        'id': 'abc',
        'user_id': 'u1',
        'tier': 'pro',
        'status': 'active',
        'expires_at': null,
      });
      expect(model.tier, SubscriptionTier.yearly);
      expect(model.isActive, isTrue);
      expect(model.isPremium, isTrue);
    });

    test('isActive is false when status != active', () {
      final model = SubscriptionModel.fromJson({
        'id': 'abc',
        'user_id': 'u1',
        'tier': 'premium',
        'status': 'inactive',
        'expires_at': null,
      });
      expect(model.isActive, isFalse);
      expect(model.isPremium, isFalse);
    });

    test('toJson round-trips tier value', () {
      final model = SubscriptionModel.fromJson({
        'id': 'abc',
        'user_id': 'u1',
        'tier': 'pro',
        'status': 'active',
        'expires_at': null,
      });
      expect(model.toJson()['tier'], 'pro');
    });
  });

  // ---------------------------------------------------------------------------
  // resolveMediaUrl
  // ---------------------------------------------------------------------------
  group('resolveMediaUrl', () {
    test('absolute http URL is returned unchanged', () {
      const url = 'https://example.com/photo.jpg';
      expect(resolveMediaUrl(url), url);
    });

    test('relative URL is prepended with server base (no /api/v1)', () {
      const relative = '/uploads/avatars/test.jpg';
      final result = resolveMediaUrl(relative);
      expect(result, contains('/uploads/avatars/test.jpg'));
      expect(result, isNot(contains('/api/v1')));
    });

    test('http:// URL is returned unchanged', () {
      const url = 'http://192.168.1.1/photo.jpg';
      expect(resolveMediaUrl(url), url);
    });
  });
}
