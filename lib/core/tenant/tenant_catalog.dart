import 'package:retail_test_task/core/tenant/tenant_config.dart';

final class TenantCatalog<T> {
  TenantCatalog(Map<TenantId, T> entries)
    : _entries = Map.unmodifiable(entries);

  final Map<TenantId, T> _entries;

  T forTenant(TenantId id) => _entries[id]!;
}
