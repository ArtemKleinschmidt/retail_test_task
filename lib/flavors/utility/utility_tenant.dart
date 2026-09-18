part of '../flavor_catalog.dart';

/// Utility Pay's complete tenant registration.
final TenantConfig _utilityTenant = TenantConfig(
  id: TenantId.utility,
  appName: 'Utility Pay',
  theme: _buildUtilityTheme(),
);

final AppFlavor _utilityFlavor = AppFlavor(
  tenant: _utilityTenant,
  paymentComponents: PaymentTenantComponents(
    sections: const [
      PaymentPageHeadingSection(),
      PaymentSummarySection(),
      PaymentSecurityOverviewSection(),
      UtilityBillBreakdown(),
      UtilitySecurityError(),
      PaymentProgressSection(),
      PaymentResultSection(),
      PaymentActionSection(),
    ],
  ),
);

ThemeData _buildUtilityTheme() {
  const tokens = TenantDesignTokens(
    accent: Color(0xFF123A63),
    accentContainer: Color(0xFFDCE6F1),
    securityErrorBackground: Color(0xFFF4E3E3),
    securityErrorForeground: Color(0xFF7C2020),
    cardRadius: 4,
    controlRadius: 2,
    screenPadding: 16,
    sectionSpacing: 12,
    itemSpacing: 8,
    dataRowHeight: 36,
    contentDensity: TenantContentDensity.compact,
    shortDuration: Duration(milliseconds: 120),
    pageTransitionDuration: Duration(milliseconds: 180),
    motionCurve: Curves.easeOut,
  );
  final colorScheme = ColorScheme.fromSeed(
    seedColor: tokens.accent,
    brightness: Brightness.light,
    surface: const Color(0xFFF4F6F8),
  ).copyWith(secondary: const Color(0xFF5F6F82));
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    visualDensity: VisualDensity.compact,
    extensions: const [tokens],
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()},
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.25),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(tokens.cardRadius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.controlRadius),
          ),
        ),
      ),
    ),
  );
}
