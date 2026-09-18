import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retail_test_task/core/tenant/tenant_config.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/flavors/flavor_catalog.dart';
import 'package:retail_test_task/flavors/retail/retail_payment_components.dart';
import 'package:retail_test_task/flavors/utility/utility_payment_components.dart';

void main() {
  group('FlavorCatalog', () {
    test('selects the matching configuration for each tenant', () {
      final retail = flavorCatalog.forTenant(TenantId.retail);
      final utility = flavorCatalog.forTenant(TenantId.utility);

      expect(retail.tenant.id, TenantId.retail);
      expect(retail.tenant.appName, 'Retail Shop');
      expect(utility.tenant.id, TenantId.utility);
      expect(utility.tenant.appName, 'Utility Pay');
      expect(retail, isNot(same(utility)));
    });

    test('provides distinct semantic design tokens for each tenant', () {
      final retail = flavorCatalog.forTenant(TenantId.retail).tenant;
      final utility = flavorCatalog.forTenant(TenantId.utility).tenant;
      final retailTokens = retail.theme.extension<TenantDesignTokens>()!;
      final utilityTokens = utility.theme.extension<TenantDesignTokens>()!;

      expect(
        retail.theme.colorScheme.primary,
        isNot(utility.theme.colorScheme.primary),
      );
      expect(retail.theme.visualDensity, VisualDensity.standard);
      expect(utility.theme.visualDensity, VisualDensity.compact);
      expect(retailTokens.contentDensity, TenantContentDensity.comfortable);
      expect(utilityTokens.contentDensity, TenantContentDensity.compact);
      expect(retailTokens.cardRadius, greaterThan(utilityTokens.cardRadius));
      expect(
        retailTokens.screenPadding,
        greaterThan(utilityTokens.screenPadding),
      );
      expect(
        retailTokens.pageTransitionDuration,
        greaterThan(utilityTokens.pageTransitionDuration),
      );
      expect(retailTokens.motionCurve, Curves.easeInOutCubic);
      expect(utilityTokens.motionCurve, Curves.easeOut);
    });

    test('registers the matching component strategies for each tenant', () {
      final retail = flavorCatalog.forTenant(TenantId.retail);
      final utility = flavorCatalog.forTenant(TenantId.utility);

      expect(
        retail.paymentComponents.paymentSupplement,
        isA<RetailPromoBannerStrategy>(),
      );
      expect(
        retail.paymentComponents.securityError,
        isA<RetailSecurityErrorStrategy>(),
      );
      expect(
        utility.paymentComponents.paymentSupplement,
        isA<UtilityBillBreakdownStrategy>(),
      );
      expect(
        utility.paymentComponents.securityError,
        isA<UtilitySecurityErrorStrategy>(),
      );
    });
  });
}
