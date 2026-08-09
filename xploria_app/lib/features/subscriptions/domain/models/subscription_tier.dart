/// Domain enum untuk tier berlangganan.
/// Menggantikan penggunaan String raw ('pro', 'premium', 'yearly', 'monthly')
/// yang tersebar di berbagai layer. Sesuai plan.md §1 fitur #12.
enum SubscriptionTier {
  yearly('pro'),
  monthly('premium');

  /// Nilai string yang dikirim ke / diterima dari backend.
  final String value;
  const SubscriptionTier(this.value);

  static SubscriptionTier fromValue(String value) {
    return SubscriptionTier.values.firstWhere(
      (t) => t.value == value,
      orElse: () => SubscriptionTier.monthly,
    );
  }

  bool get isPremium => true;

  /// Durasi aktif tier dalam hari.
  int get durationDays => switch (this) {
        SubscriptionTier.yearly => 365,
        SubscriptionTier.monthly => 30,
      };
}
