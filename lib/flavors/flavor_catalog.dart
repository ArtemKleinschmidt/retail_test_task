import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_catalog.dart';
import 'package:retail_test_task/core/tenant/tenant_config.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_tenant_components.dart';
import 'package:retail_test_task/flavors/app_flavor.dart';
import 'package:retail_test_task/flavors/retail/retail_payment_components.dart';
import 'package:retail_test_task/flavors/utility/utility_payment_components.dart';

part 'retail/retail_tenant.dart';
part 'utility/utility_tenant.dart';

final TenantCatalog<AppFlavor> flavorCatalog = TenantCatalog({
  TenantId.retail: _retailFlavor,
  TenantId.utility: _utilityFlavor,
});
