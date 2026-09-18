part of '../flavor_catalog.dart';

/// Retail Shop's complete tenant registration.
final TenantConfig _retailTenant = TenantConfig(
  id: TenantId.retail,
  appName: 'Retail Shop',
  theme: _buildRetailTheme(),
);

final AppFlavor _retailFlavor = AppFlavor(
  tenant: _retailTenant,
  paymentComponents: const PaymentTenantComponents(
    paymentSupplement: RetailPromoBannerStrategy(),
    securityError: RetailSecurityErrorStrategy(),
  ),
);

ThemeData _buildRetailTheme() {
  const tokens = TenantDesignTokens(
    accent: Color(0xFFE96B1A),
    accentContainer: Color(0xFFFFE8C2),
    securityErrorBackground: Color(0xFFFFE4DE),
    securityErrorForeground: Color(0xFF9C291A),
    cardRadius: 24,
    controlRadius: 18,
    screenPadding: 24,
    sectionSpacing: 20,
    itemSpacing: 12,
    dataRowHeight: 48,
    contentDensity: TenantContentDensity.comfortable,
    shortDuration: Duration(milliseconds: 250),
    pageTransitionDuration: Duration(milliseconds: 450),
    motionCurve: Curves.easeInOutCubic,
  );
  final colorScheme = ColorScheme.fromSeed(
    seedColor: tokens.accent,
    brightness: Brightness.light,
    surface: const Color(0xFFFFFBF5),
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    visualDensity: VisualDensity.standard,
    extensions: const [tokens],
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: ZoomPageTransitionsBuilder()},
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLowest,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.cardRadius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(56)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.controlRadius),
          ),
        ),
      ),
    ),
  );
}
