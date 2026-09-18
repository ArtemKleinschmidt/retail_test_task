import 'package:retail_test_task/app/bootstrap.dart';
import 'package:retail_test_task/core/tenant/tenant_config.dart';
import 'package:retail_test_task/flavors/flavor_catalog.dart';

void main() {
  bootstrap(flavorCatalog.forTenant(TenantId.utility));
}
