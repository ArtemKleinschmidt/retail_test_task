import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retail_test_task/core/tenant/tenant_config.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/presentation/widgets/payment_page_sections.dart';
import 'package:retail_test_task/flavors/flavor_catalog.dart';
import 'package:retail_test_task/flavors/retail/retail_promo_banner.dart';
import 'package:retail_test_task/flavors/retail/retail_security_error.dart';
import 'package:retail_test_task/flavors/utility/utility_bill_breakdown.dart';
import 'package:retail_test_task/flavors/utility/utility_security_error.dart';

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

    test('registers each tenant payment section in display order', () {
      final retail = flavorCatalog.forTenant(TenantId.retail);
      final utility = flavorCatalog.forTenant(TenantId.utility);

      expect(retail.paymentComponents.sectionKeys, [
        PaymentPageHeadingSection.sectionKey,
        RetailPromoBanner.sectionKey,
        PaymentSummarySection.sectionKey,
        PaymentSecurityOverviewSection.sectionKey,
        RetailSecurityError.sectionKey,
        PaymentProgressSection.sectionKey,
        PaymentResultSection.sectionKey,
        PaymentActionSection.sectionKey,
      ]);
      expect(utility.paymentComponents.sectionKeys, [
        PaymentPageHeadingSection.sectionKey,
        PaymentSummarySection.sectionKey,
        PaymentSecurityOverviewSection.sectionKey,
        UtilityBillBreakdown.sectionKey,
        UtilitySecurityError.sectionKey,
        PaymentProgressSection.sectionKey,
        PaymentResultSection.sectionKey,
        PaymentActionSection.sectionKey,
      ]);
    });
  });
}
