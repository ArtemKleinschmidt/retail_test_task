import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_catalog.dart';
import 'package:retail_test_task/core/tenant/tenant_config.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/presentation/widgets/payment_page_sections.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_tenant_components.dart';
import 'package:retail_test_task/flavors/app_flavor.dart';
import 'package:retail_test_task/flavors/retail/retail_promo_banner.dart';
import 'package:retail_test_task/flavors/retail/retail_security_error.dart';
import 'package:retail_test_task/flavors/utility/utility_bill_breakdown.dart';
import 'package:retail_test_task/flavors/utility/utility_security_error.dart';

part 'retail/retail_tenant.dart';
part 'utility/utility_tenant.dart';

final TenantCatalog<AppFlavor> flavorCatalog = TenantCatalog({
  TenantId.retail: _retailFlavor,
  TenantId.utility: _utilityFlavor,
});
