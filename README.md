# Hyper-Tenant Secure Payment Portal

A Flutter payment-confirmation module built for two Android tenants from one
codebase. It demonstrates configuration-driven white-label UI, Clean
Architecture with BLoC, Kotlin platform integration, and repaint-isolated custom
graphics.

## Requirement Coverage

- **Multi-tenant UI:** separate Retail Shop and Utility Pay builds with
  tenant-specific themes, layouts, components, launcher icons, and native
  resources. [`TenantDesignTokens`](lib/core/tenant/tenant_design_tokens.dart)
  and [`PaymentTenantComponents`](lib/features/payment/presentation/tenant/payment_tenant_components.dart)
  drive shared widgets without brand-selection conditionals.
- **Android security:** Kotlin MethodChannel integration for heuristic root
  detection and active screen-recording status, implemented by
  [`SecurityEnvironmentChannel`](android/app/src/main/kotlin/com/example/retail_test_task/security/SecurityEnvironmentChannel.kt)
  and [`ScreenRecordingMonitor`](android/app/src/main/kotlin/com/example/retail_test_task/security/ScreenRecordingMonitor.kt).
- **Window protection:** route-aware `FLAG_SECURE` while a payment page is
  visible, plus Recents screenshot protection through
  [`SecurePageMixin`](lib/core/platform/secure_page_mixin.dart) and
  [`WindowProtectionChannel`](android/app/src/main/kotlin/com/example/retail_test_task/security/WindowProtectionChannel.kt).
- **Foreground processing:** simulated payment work runs in an Android
  [`PaymentProcessingService`](android/app/src/main/kotlin/com/example/retail_test_task/payment/PaymentProcessingService.kt)
  with a persistent progress notification; Flutter communicates through
  [`MethodChannelPaymentRepository`](lib/features/payment/data/repositories/method_channel_payment_repository.dart).
- **High-performance graphics:** the security radar uses `CustomPainter`, an
  animation repaint listenable, cached geometry, and `RepaintBoundary` without
  rebuilding the surrounding widget tree per frame. See
  [`SecurityRadarSweep`](lib/features/payment/presentation/widgets/security_radar_sweep.dart).

## Architecture

```text
Presentation / BLoC  ->  Domain  <-  Data / Android platform adapters
```

Product code is organized by feature under `lib/features/`. The domain layer is
pure Dart and owns entities, repository contracts, and use cases. Data and
Kotlin adapters implement those contracts, while `get_it` wiring remains in the
[`application composition root`](lib/app/dependency_injection.dart). UI state
and payment orchestration are handled by
[`PaymentBloc`](lib/features/payment/presentation/bloc/payment_bloc.dart).

## Flavors

| Flavor | Flutter entry point | Main differences |
| --- | --- | --- |
| Retail Shop | [`main_retail.dart`](lib/main_retail.dart) | Orange/gold, rounded UI, fluid transitions, promo banner |
| Utility Pay | [`main_utility.dart`](lib/main_utility.dart) | Navy/slate, compact sharp UI, detailed bill breakdown |

Flutter selects an immutable tenant theme and ordered component configuration.
Android product flavors provide separate application IDs, names, launcher icons,
notification titles, and colors in
[`build.gradle.kts`](android/app/build.gradle.kts). Shared Flutter and Kotlin
logic stays unchanged.

## Android Security Notes

- Root detection uses RootBeer as a heuristic; a clear result is not proof that
  a device is trusted.
- Active screen-recording detection uses the official Android API on API 35+.
  It is reported as unsupported on API 24-34 because no equivalent public API
  exists there.
- `FLAG_SECURE` remains independent of detection and protects the payment window
  across all supported Android versions.

See [`docs/security-approach.md`](docs/security-approach.md) for the capability
matrix, limitations, and implementation decisions.

## Setup and Verification

Use the Flutter version declared in `.fvmrc`:

```sh
fvm install
fvm flutter pub get
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```

Run either flavor:

```sh
fvm flutter run --flavor retail --target lib/main_retail.dart
fvm flutter run --flavor utility --target lib/main_utility.dart
```

Build each APK explicitly with its matching Android flavor and Dart entry point:

```sh
fvm flutter build apk --debug --flavor retail --target lib/main_retail.dart
fvm flutter build apk --debug --flavor utility --target lib/main_utility.dart
```

Current verification: formatting and analysis pass, all 90 automated tests pass,
both flavor APKs build, and Android lint reports no errors.

## Project Notes

- [`plan.md`](plan.md) - requirement mapping, decisions, and implementation log.
- [`docs/security-approach.md`](docs/security-approach.md) - Android security
  research and limitations.
- [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) - third-party attribution.
