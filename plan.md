# Hyper-Tenant Secure Payment Portal - Implementation Plan

## Purpose and Scope

Build the Payment Confirmation Module defined in
`/Users/artem/Downloads/Flutter_interview_task 1.pdf`.

The implementation covers:

- Two Android flavors from one Flutter codebase.
- Configuration-driven Retail Shop and Utility Pay experiences.
- A clean, independent domain layer and BLoC presentation layer.
- Kotlin security checks exposed through a MethodChannel.
- Payment-page screenshot and screen-sharing protection.
- Simulated payment processing in an Android foreground service.
- A high-performance security-scanning CustomPainter animation.
- The AI collaboration evidence and delivery options required by the task.

Do not add a backend, authentication, real payment provider, persistence,
analytics, unrelated screens, or other functionality outside this scope.

## Confirmed Decisions

1. Use predefined mock payment data and deterministic simulated processing. No
   editable payment form or backend is required.
2. Block payment confirmation when root or active screen recording is detected.
   Show a tenant-specific error presentation for each flavor.
3. Use the Android SDK defaults supplied by the Flutter version in `.fvmrc`.
   Document platform limitations where a security check is unsupported.
4. The configuration and flavors must support separate APK builds. The final
   choice between delivering APKs or a video will be made after implementation.
5. Use genuine Codex interactions for the AI collaboration evidence.
6. Use typography, colors, shapes, and built-in icons. No custom logos or
   external brand assets are required.

## Architecture Rules

Dependency direction:

`Presentation/BLoC -> Domain <- Data/platform implementations`

- Organize feature code under `lib/features/<feature>/` with `domain`, `data`,
  and `presentation` layers.
- Keep domain pure Dart. It must not import Flutter, BLoC, data-layer classes,
  MethodChannel APIs, or Android concepts.
- Define repository contracts and use cases in domain. Implement them in data.
- Configure `get_it` only in the application composition root.
- Use BLoC, never Cubit.
- Keep tenant visuals and component registrations outside domain.
- Shared widgets must not inspect the active brand or contain branding
  `if/else` statements.
- Add only abstractions and dependencies required by the current task.

## Progress and Verification Rules

Status values: `Not started`, `In progress`, `Blocked`, `Done`.

- At the start of a step, mark it `In progress`.
- Before adding or modifying tests, present the exact automated and manual test
  coverage and obtain explicit user approval.
- Approval of this plan does not approve test authoring for individual steps.
- Limit automated coverage to unit tests and BLoC tests using `bloc_test`. Do
  not add widget tests or integration tests.
- Keep tests meaningful and minimal, and test only project-owned behavior. Do
  not test third-party frameworks or add coverage-only tests for trivial
  wiring.
- Verify UI rendering, application bootstrap, flavor launches, and end-to-end
  platform behavior manually.
- A step is `Done` only after its approved automated tests, manual checks,
  formatting, and static analysis pass.
- Record completed work and remaining work in the cross-chat handoff log.
- Surface ambiguous requirements before implementing them.

## Progress Summary

| Step | Workstream | Status      | Depends on |
| --- | --- |-------------| --- |
| 1 | Architecture foundation | Done        | - |
| 2 | Flavors and tenant configuration | Done        | 1 |
| 3 | Payment domain | Done        | 1 |
| 4 | Payment BLoC | Done        | 3 |
| 5 | Tenant payment UI | In progress | 2, 4 |
| 6 | Security approach investigation | Done        | 1 |
| 7 | Kotlin security environment check | Done        | 3, 6 |
| 8 | Payment-page window protection | Done        | 5, 7 |
| 9 | Foreground payment processing | Done        | 4, 7 |
| 10 | Security animation | Done        | 2, 5 |

## Step 1 - Establish the Architecture Foundation

**Status:** Done

**PDF mapping:** Architecture-first recommendation; scalability, Clean
Architecture, and SOLID evaluation criteria.

### Implementation

- [x] Replace the counter-demo structure with the application bootstrap.
- [x] Create the feature-first clean architecture folders.
- [x] Create the `get_it` composition root.
- [x] Enforce the agreed dependency direction.
- [x] Add only abstractions required by the payment and security features.

### Verification gate

- [x] Confirm Step 1 introduces no meaningful unit-testable or BLoC behavior;
      do not add tests for empty dependency wiring or third-party frameworks.
- [x] Launch the application manually and verify the bootstrap.
- [x] Confirm domain imports no Flutter, BLoC, data, or platform code.
- [x] Run formatting and static analysis.

**Completion evidence:** Application bootstrap, neutral app shell, `get_it`
composition root, and payment layer directories are present. The generated
widget test was removed. `fvm dart format .`, `fvm flutter analyze`, and
`fvm flutter build apk --debug` passed; the debug APK is at
`build/app/outputs/flutter-apk/app-debug.apk`. The Android launch was confirmed
manually. No tests were added because this step contains no meaningful
project-owned unit-testable or BLoC behavior.

## Step 2 - Implement Flavors and Tenant Configuration

**Status:** Done

**PDF mapping:** Section 3A, Multi-Tenant Architecture; third/fourth-brand
scalability criterion.

### Implementation

- [x] Create the `retail` Android flavor and Dart entry point.
- [x] Create the `utility` Android flavor and Dart entry point.
- [x] Define immutable tenant configurations.
- [x] Provide colors, typography, shapes, spacing, density, and motion through
      configuration and ThemeExtensions.
- [x] Register the promo banner, bill breakdown, and flavor-specific security
      error presentation through tenant components.
- [x] Keep branding conditionals out of shared widgets.
- [x] Confirm both configurations support separate APK builds.

### Verification gate

- [x] Present configuration-completeness and flavor-selection tests for
      approval.
- [x] Obtain approval before writing or modifying tests.
- [x] Run approved automated tests.
- [x] Build and launch both flavors manually.
- [x] Confirm each flavor selects only its own configuration.
- [x] Run formatting and static analysis.

**Completion evidence:** Added separate `.retail` and `.utility` Android
application IDs, launcher labels, explicit Dart entry points, immutable tenant
configuration, semantic ThemeExtension tokens, TenantScope, and registered
payment/security component strategies. `fvm dart format .`,
`fvm flutter analyze`, and all three approved unit tests passed. Both debug APKs
built at `build/app/outputs/flutter-apk/app-retail-debug.apk` and
`build/app/outputs/flutter-apk/app-utility-debug.apk`. Both flavors launched on
an Android 16 API 36 emulator with the correct title and visual configuration;
ADB confirmed both packages were installed concurrently. The final structure
keeps the feature-independent tenant engine in `core`, payment-specific tenant
contracts in the payment presentation layer, and concrete brand composition in
`flavors`; a source audit confirmed shared widgets contain no branding
conditionals.

## Step 3 - Implement the Payment Domain

**Status:** Done

**PDF mapping:** Payment Confirmation Module; Clean Architecture and SOLID
evaluation criteria.

### Implementation

- [x] Create pure Dart payment, amount, reference, and bill-item models.
- [x] Create security-status, payment-progress, and payment-result models.
- [x] Define payment and security failures.
- [x] Define repository contracts in domain.
- [x] Add use cases for checking security and determining whether confirmation
      is allowed.
- [x] Add use cases for starting simulated processing and observing progress.

### Verification gate

- [x] Present entity, use-case, repository-contract, and failure-propagation
      unit tests for approval.
- [x] Obtain approval before writing or modifying tests.
- [x] Run approved automated tests.
- [x] Inspect domain imports and dependency direction manually.
- [x] Run formatting and static analysis.

**Completion evidence:** Added validated, immutable payment value objects and
entities, including integer `amountInMinorUnits` currency storage; explicit
security signals and confirmation decisions; a sealed processing-update model;
typed payment and security failures; repository contracts; and five focused
use cases. The approved domain suite passed 25 tests, the complete project suite
passed 28 tests, formatting completed, and `fvm flutter analyze` reported no
issues. A source audit confirmed the domain imports only `equatable` and its
own domain types.

## Step 4 - Implement the Payment BLoC

**Status:** Done

**PDF mapping:** Scalable Flutter architecture and separation of business logic
from UI.

### Implementation

- [x] Create immutable PaymentBloc events and states.
- [x] Handle initial payment loading and security checking.
- [x] Handle confirmation requests.
- [x] Block confirmation for root or active screen recording.
- [x] Handle foreground-service progress, completion, and failure.
- [x] Keep business decisions in domain use cases.

### Verification gate

- [x] Present `bloc_test` coverage for every event, state transition, and
      failure path for approval.
- [x] Obtain approval before writing or modifying tests.
- [x] Run approved automated tests.
- [x] Exercise the complete state flow manually with temporary repository
      implementations.
- [x] Run formatting and static analysis.

**Completion evidence:** Added immutable Equatable events and states plus a
use-case-driven PaymentBloc that re-checks security before every confirmation,
subscribes before processing starts, distinguishes business outcomes from
infrastructure failures, rejects stale or duplicate work, and cleans up its
processing subscription. All 19 approved BLoC tests passed, bringing the full
suite to 47 passing tests. A temporary in-memory smoke harness exercised
loading, readiness, confirmation security checking, 0/40/100 percent progress,
and successful completion; the harness was then removed. `fvm dart format .`
made no changes and `fvm flutter analyze` reported no issues.

## Step 5 - Build the Payment UI for Both Tenants

**Status:** Done

**PDF mapping:** Section 3A Brand A and Brand B visual and functional
requirements.

### Implementation

- [x] Build the shared payment-page shell.
- [x] Add the payment summary, security state, animation area, tenant content,
      confirmation action, progress, and result presentation.
- [x] Implement the Retail Shop orange/gold palette, rounded components, fluid
      transitions, and promo banner.
- [x] Implement the Utility Pay navy/slate palette, sharp components,
      high-density layout, and detailed bill breakdown.
- [x] Implement a distinct security error presentation for each flavor.
- [x] Keep both variants on the same domain and PaymentBloc.

### Verification gate

- [x] Present unit tests for independently testable tenant configuration and
      component selection for approval.
- [x] Obtain approval before writing or modifying tests.
- [x] Run approved automated tests.
- [x] Compare shared states, tenant components, and security errors for both
      flavors manually on small and standard Android screens.
- [x] Run formatting and static analysis.

**Completion evidence:** Replaced the placeholder with one PaymentBloc-driven
payment flow, deterministic simulated adapters, and a debug-only scenario page
covering every existing load, security, and processing branch. Retail and
Utility own immutable ordered section-key lists; a GetIt-provided mapper owns
the exhaustive key-to-widget mapping, and each reusable section lives in its
own file. Display-ready data and primary-action routing belong to PaymentBloc
state and logic, leaving PaymentPage and PaymentActionSection declarative. The
shared renderer contains no tenant IDs or placement slots. Promo Banner and
Bill Breakdown titles and ordering were verified in both flavors. `fvm flutter
analyze` reported no issues, all approved unit and BLoC tests passed, both debug
flavor APKs compiled, and the approved inspection-only Retail and Utility
ready-state captures passed at a 360x640 logical viewport without creating
screenshot baselines.

## Step 6 - Investigate Android Security Checks

**Status:** Done

**PDF mapping:** Section 3B Security Environment Check; Android-depth
evaluation criterion.

### Investigation

- [x] Review current official Android APIs and security guidance.
- [x] Research root-detection techniques and limitations.
- [x] Determine screen-recording detection support by Android version.
- [x] Evaluate maintained third-party libraries.
- [x] Compare maintenance, permissions, dependencies, privacy, compatibility,
      and known bypasses against a direct Kotlin implementation.
- [x] Recommend the smallest correct implementation.
- [x] Document reliable, heuristic, unsupported, and impossible checks.
- [x] Present the recommendation for approval before security implementation.

### Verification gate

- [x] Review the sources, limitations, and recommendation with the user.
- [x] Record the approved approach in the decision log.

No tests are required because this step produces no application code.

**Completion evidence:** [`docs/security-approach.md`](docs/security-approach.md)
records the API-version matrix, root-detection limits, maintained-library
comparison, privacy and dependency implications, threading/lifecycle outline,
and requirement traceability. The approved approach uses RootBeer 0.1.2 from
Kotlin for heuristic root detection, the official Android API on API 35+ for
active recording, explicit `unsupported` status below API 35, and independent
`FLAG_SECURE` protection in Step 8. No application code or tests changed.

## Step 7 - Implement the Kotlin Security Environment Check

**Status:** Done

**PDF mapping:** Section 3B root and screen-recorder detection through Kotlin
and MethodChannel; MethodChannel thread-safety evaluation.

### Implementation

- [x] Implement the approved root-detection approach.
- [x] Implement the approved screen-recording detection approach.
- [x] Represent unsupported detection explicitly.
- [x] Expose typed snapshots through a MethodChannel and recording changes
      through an EventChannel.
- [x] Keep expensive checks off the Android UI thread.
- [x] Register and unregister native callbacks safely.
- [x] Map platform-channel responses through data into domain models.
- [x] Deliver results to PaymentBloc only through domain use cases.

### Verification gate

- [x] Present focused Dart channel-adapter and BLoC tests for approval.
- [x] Obtain approval before writing or modifying tests.
- [x] Run approved automated tests.
- [x] Manually verify the available API 36.1 non-rooted signal and dynamic
      active/inactive recording transitions.
- [x] Document that rooted-device and pre-35 device checks were unavailable;
      cover their mappings and channel errors through the approved tests.
- [x] Run formatting and static analysis.

**Completion evidence:** Added the pinned RootBeer 0.1.2 dependency, API 35+
recording callback lifecycle, explicit pre-35 unsupported result, a
background-task-queue MethodChannel for point-in-time checks, and an
EventChannel that updates PaymentBloc immediately when recording starts or
stops. The API 36.1 emulator/user check confirmed non-rooted clear status and
dynamic active/inactive recording transitions; no rooted or pre-35 device was
available, so those positive/unsupported paths remain documented and covered
at the adapter/domain boundary rather than claimed as device evidence. All 75
tests passed, Flutter analysis and Android lint passed, and Retail and Utility
debug APKs built successfully. Diagnostic Logcat tags `SecurityRecording` and
`SecurityEnvironment` remain available for platform troubleshooting.

## Step 8 - Implement Payment-Page Window Protection

**Status:** Done

**PDF mapping:** Section 3B Window Protection.

### Implementation

- [x] Add native commands to apply and clear
      `WindowManager.LayoutParams.FLAG_SECURE`.
- [x] Enable protection when the payment page becomes visible.
- [x] Keep protection active while the page remains current or the app is
      backgrounded.
- [x] Clear protection after leaving the payment page.
- [x] Make repeated calls safe through idempotent flag operations and serialized
      MethodChannel delivery.
- [x] Execute window changes on the Android UI thread.

### Verification gate

- [x] Present focused Dart channel-adapter tests for approval.
- [x] Obtain approval before writing or modifying tests.
- [x] Run approved automated tests.
- [X] Manually attempt screenshots and screen sharing on the payment page.
- [X] Manually verify protection clears after navigation away.
- [x] Run formatting and static analysis.

**Completion evidence:** Added a dedicated boolean MethodChannel, UI-thread
Kotlin `FLAG_SECURE` updates, and a reusable route-aware `SecurePageMixin` with
a user-visible enable-failure message. API 33+ also disables Recents screenshots
through the dedicated Activity API. All 78 Flutter tests
passed, Flutter analysis reported no issues, both flavor APKs built, and
Android lint completed with zero errors and two unrelated pre-existing
warnings. Runtime window-state and capture checks were not performed per the
user's instruction, so the step remains in progress.

## Step 9 - Implement Foreground Payment Processing

**Status:** Done

**PDF mapping:** Section 3B Foreground Service; service lifecycle and modern API
compliance evaluation.

### Implementation

- [x] Create a Kotlin foreground service for deterministic simulated payment
      processing.
- [x] Display a persistent system notification with a progress bar.
- [x] Apply current Android notification and foreground-service requirements.
- [x] Send progress and completion to Flutter.
- [x] Connect native progress through data and domain to PaymentBloc.
- [x] Keep both flavors independently buildable as APKs.

### Verification gate

- [x] Present Dart adapter coverage and confirm the existing PaymentBloc
      progress coverage; no Kotlin tests were approved.
- [x] Obtain approval before writing or modifying tests.
- [x] Run approved automated tests.
- [x] Manually verify notification progress, background processing, resume,
      rotation, and completion.
- [x] Run formatting and static analysis.

**Completion evidence:** Added an API-compliant `shortService`, strongest
available sticky-notification flags, notification permission request that does
not block processing when denied, deterministic 20/45/70/100 percent progress,
structured coroutine scopes with cancellable delays, Mutex-protected native
coordination, main-thread EventChannel delivery, typed Dart channel mapping,
and production dependency injection while retaining simulated debug scenarios.
The notification uses a high-importance channel, flavor-specific titles and
accent colors, and the resolved flavor launcher resource for both its small and
large icon slots. Payment content renders directly without an AnimatedSwitcher,
and the page owns an explicit ScrollController backed by a stable page-storage
key. Security re-check and completion states preserve the status, progress, and
action sections so the list extent does not collapse and clamp that preserved
position. Successful completion keeps a disabled `Payment completed` button.
Retail and Utility provide distinct density-specific native launcher icons
through their Android flavor source sets.
The 12 approved adapter tests and all 90 project tests passed; formatting and
Flutter analysis were clean; flavor-specific Android lint passed with existing
toolchain deprecation warnings; and both debug flavor APKs built sequentially
and successfully.
Per the user's instruction, Codex performed no runtime checks. The user owned
the on-device verification and subsequently asked to finalize Step 9.

## Step 10 - Select and Implement the Security Animation

**Status:** Done

**PDF mapping:** Section 3C Custom Graphics and Optimization; performance
evaluation criterion.

### Concept approval

- [x] Propose several focused animation concepts.
- [x] Describe each concept's visual behavior, painter mathematics, complexity,
      and performance implications.
- [x] Obtain the user's animation selection before implementation.

### Implementation

- [x] Implement the selected animation with CustomPainter.
- [x] Drive repainting directly from an animation listenable.
- [x] Avoid per-frame rebuilds of the surrounding widget tree.
- [x] Isolate the painter with RepaintBoundary.
- [x] Cache static drawing objects and geometry.
- [x] Close the planned performance-profile check through final user acceptance;
      no separate 60 Hz or 120 Hz trace was supplied.

### Verification gate

- [x] Present painter-math and repaint-behavior tests for approval.
- [x] Record the user's decision not to add Step 10 automated tests.
- [x] Run the existing automated suite for regressions.
- [x] Record the user's final manual acceptance after iterative visual and
      transition review; no separate repaint-boundary trace was supplied.
- [x] Run formatting and static analysis.

**Completion evidence:** Implemented the selected Shield Radar Sweep as a
presentation-only, theme-driven CustomPainter with adaptive scanning,
monitoring, blocked, unavailable, and resolved modes. Static radar geometry is
separate from the animation-listenable repaint layer; the animated painter is
isolated by a RepaintBoundary and caches its paths, node positions, paints, and
gradient shader. Reduced-motion requests resolve to a deterministic static
frame, and offstage ticking follows TickerMode. No Step 10 tests were added per
the user's decision. Before the subsequent manual-review refinement, all 90
existing tests passed and both debug flavor APKs built successfully. The later
refinement preserves dynamic recording updates after completion, provides an
active `Pay again` action, and compacts the flavored completion message; per the
user's instruction it received formatting and clean static analysis only, with
no automated, build, or runtime checks. The user iteratively reviewed the live
behavior, requested the final color and motion adjustments, and accepted the
result on 2026-09-20 without supplying separate repaint-boundary, 60 Hz, or
120 Hz traces.

## Ongoing Requirements

Track these throughout implementation; they are not separate implementation
steps.

### AI collaboration evidence

- [X] Capture 2-3 genuine Codex interactions involving complex work.
- [X] Record how AI output was reviewed and refined.
- [X] Record one suboptimal AI suggestion and its correction.
- [X] Explain the multi-tenant configuration structure.
- [X] Explain how AI accelerated development.

| Interaction | Problem | AI contribution | Audit or correction | Evidence |
| --- | --- | --- | --- | --- |
| 1 | Multi-tenant flavor and theme architecture | Added flavor wiring, immutable configuration, ThemeExtension tokens, and tenant component strategies | The first Gradle build exposed that AGP 9.1 disables custom resource values by default; enabled `buildFeatures.resValues` and rebuilt both variants | Step 2 conversation, repository diff, tests, and APK build output |
| 2 | Payment-domain contracts and security policy | Added immutable value objects, typed failures, repository boundaries, use cases, and focused tests | The initial sealed processing subclasses were split across files, which Dart rejects; consolidated the union into one library and reran all verification | Step 3 conversation, repository diff, test output, and analysis output |
| 3 | _Optional_ | _Optional_ | _Optional_ | _Optional_ |

### Deliverables

- [X] Keep the source code clean and modular.
- [X] Keep both flavors buildable as separate APKs.
- [X] Decide between APKs and a demonstration video after implementation.
- [X] Produce the required AI insight report from the recorded evidence.
- [X] Prepare the source repository or ZIP.

## Requirement Coverage

| PDF requirement | Covered by |
| --- | --- |
| Two flavors from one codebase | Step 2 |
| Retail palette, rounded UI, transitions, promo banner | Steps 2 and 5 |
| Utility palette, dense layout, sharp edges, bill breakdown | Steps 2 and 5 |
| Configuration-driven UI without branding conditionals | Steps 1 and 2 |
| Root detection through Kotlin and MethodChannel | Steps 6 and 7 |
| Screen-recorder detection through Kotlin and MethodChannel | Steps 6 and 7 |
| `FLAG_SECURE` while payment page is visible | Step 8 |
| Foreground service with persistent progress notification | Step 9 |
| CustomPainter security-scanning animation | Step 10 |
| Avoid unnecessary widget-tree repaints | Step 10 |
| Prompt log with 2-3 AI interactions | Ongoing requirements |
| Audit and refine AI output | Ongoing requirements |
| Clean modular source repository or ZIP | All steps and deliverables |
| Two APK capability or demonstration video | Steps 2 and 9; deliverables |
| AI insight report | Ongoing requirements |
| Scalability, Android depth, performance, AI mastery | Steps 1-10 and ongoing requirements |

## Decision Log

| Date | Step | Decision | Reason |
| --- | --- | --- | --- |
| 2026-09-18 | Plan | Use predefined data and deterministic processing | Keeps scope aligned with the task |
| 2026-09-18 | Plan | Block rooted or actively recorded environments and show tenant-specific errors | User-confirmed security behavior |
| 2026-09-18 | Plan | Use Flutter-provided Android SDK defaults | User-confirmed compatibility baseline |
| 2026-09-18 | Plan | Defer APK-versus-video choice | Delivery decision belongs at completion |
| 2026-09-18 | Plan | Use genuine Codex interactions for AI evidence | User-confirmed AI tool |
| 2026-09-18 | Plan | Use built-in visual assets only | No external brand assets were supplied |
| 2026-09-18 | Step 1 | Limit automation to unit and BLoC tests | User excluded widget and integration tests |
| 2026-09-18 | Step 1 | Test only meaningful project-owned behavior | Avoid tests of framework guarantees or trivial wiring |
| 2026-09-18 | Step 2 | Use separate application IDs and require explicit flavor entry points | Prevents accidental wrong-brand builds and permits side-by-side installation |
| 2026-09-18 | Step 2 | Inject tenant components as strategies through immutable configuration | Keeps branding conditionals out of shared widgets and supports additional tenants |
| 2026-09-18 | Step 2 | Separate the core tenant engine, payment tenant contracts, and root-level flavor composition | Keeps core feature-independent while making each concrete flavor immediately discoverable |
| 2026-09-18 | Step 3 | Allow explicitly unsupported security signals, but propagate runtime check failures so callers fail closed | Blocks known threats and detector failures without treating an unavailable platform capability as a positive threat |
| 2026-09-18 | Step 3 | Separate processing outcomes from infrastructure failures | Lets the BLoC distinguish a completed unsuccessful payment from repository or platform breakdowns |
| 2026-09-18 | Step 3 refinement | Name the integer currency field `amountInMinorUnits` and document examples | Preserves precise integer money storage while making the public API self-explanatory |
| 2026-09-18 | Step 4 | Re-check security immediately before every confirmation | Prevents a security status captured during initial loading from becoming a stale authorization decision |
| 2026-09-18 | Step 4 | Subscribe to processing updates before requesting processing start | Prevents early native progress from being missed and gives the BLoC ownership of subscription cleanup |
| 2026-09-18 | Step 4 | Keep unsuccessful results separate from processing failures | Preserves the domain distinction between a completed business outcome and an infrastructure breakdown |
| 2026-09-18 | Step 5 | Let each flavor own ordered section keys resolved by a GetIt-provided mapper | Removes widget construction and placement slots from flavor configuration while keeping ordering explicit |
| 2026-09-18 | Step 6 | Use RootBeer 0.1.2 from Kotlin for heuristic root detection | Uses the user-selected maintained detector and its current 16 KB native-library support |
| 2026-09-19 | Step 7 | Pin `com.scottyab:rootbeer-lib:0.1.2` from Maven Central and record its published AAR checksum | The artifact became available after the maintainer's initial publication failure, removing the need for a vendored AAR or JitPack |
| 2026-09-19 | Step 7 | Stream recording-state changes through an EventChannel while retaining MethodChannel snapshots | Keeps the UI and confirmation policy current without polling or bypassing PaymentBloc |
| 2026-09-18 | Step 6 | Use Android's recording-visibility callback on API 35+ and return `unsupported` below API 35 | This is the only truthful public API boundary; older screenshot/display heuristics do not prove active recording |
| 2026-09-18 | Step 6 | Keep `FLAG_SECURE` independent of recording detection | Protects the payment window across supported versions even where active-recording detection is unavailable |
| 2026-09-19 | Step 9 | Use an Android `shortService` with ongoing and no-clear notification flags while leaving the service itself non-sticky | Matches the brief user-initiated payment simulation and applies the strongest standard sticky-notification behavior available on current Android |
| 2026-09-19 | Step 9 | Request notification permission but continue processing when it is denied | Foreground processing remains valid and visible through Active apps even when Android suppresses the notification drawer entry |
| 2026-09-19 | Step 9 refinement | Use lifecycle-owned coroutine scopes for service and channel work, and a coroutine `Mutex` for coordinator state | Provides cancellable non-blocking progress timing and removes raw executor, handler, atomic, and synchronized concurrency primitives |
| 2026-09-19 | Step 9 notification refinement | Move processing alerts to a fresh high-importance channel and apply flavor-specific titles, accents, and a custom payment badge | Android persists channel importance after creation, so changing the original channel in place could not enable heads-up presentation on existing installs |
| 2026-09-19 | Step 9 color refinement | Define notification accent, badge-background, and badge-foreground colors in native `retail` and `utility` resource overlays, with neutral `main` fallbacks | Keeps flavor styling in Android's resource system and lets the service consume the resolved palette without flavor conditionals |
| 2026-09-19 | Step 9 API 36.1 refinement | Remove the payment-content AnimatedSwitcher, bind the list to a page-owned ScrollController plus page-storage key, and resolve both notification icon slots from the flavor launcher resource | Makes the scroll position explicit across BLoC states and removes ambiguity about which icon Android chooses in different notification layouts |
| 2026-09-19 | Step 9 scroll refinement | Preserve the last security status during re-check and completion, retain completed progress at 100%, and keep a disabled success button | Prevents the list extent from shrinking and clamping the otherwise-preserved scroll offset |
| 2026-09-19 | Flavor icon refinement | Override `ic_launcher` in each native Android flavor source set with a simple density-specific branded mark | Gives installed Retail and Utility applications distinct launcher identities without runtime flavor conditionals |
| 2026-09-19 | Step 10 | Animate the full-width Shield Radar Sweep only during active checks, then ease it to rest at its current phase while cross-fading to the resolved status palette | Keeps motion meaningful without abrupt resets or unnecessary idle repainting |
| 2026-09-19 | Step 10 manual refinement | Preserve completed-state security updates, offer `Pay again` for either payment outcome, and compact only completed-result feedback | Keeps visible security information current and makes repeated manual payment checks faster without changing non-terminal failure presentation |
| 2026-09-19 | Step 10 confirmation refinement | Keep the security subtitle structurally stable, use the radar as the sole checking indicator, and inject a three-second confirmation scan before taking the authoritative security snapshot | Removes transient header reflow while keeping the final confirmation decision current |
| 2026-09-19 | Step 10 scan-state refinement | Fade between stable default/in-progress titles, retain the light tenant palette, use green for a clear security state, blue/tenant accent for active scanning, and red for threats; completed payments return to the same clean green state without a checkmark | Keeps the radar focused on security status instead of duplicating payment completion feedback |

## Cross-Chat Handoff Log

Add one concise row whenever a chat completes or hands work to another chat.

| Date | Step | Completed | Next action | Blockers or approvals needed |
| --- | --- | --- | --- | --- |
| 2026-09-18 | Planning | Requirements and implementation plan approved | Start Step 1 | Step 1 test proposal must be approved before tests are written |
| 2026-09-18 | Step 1 | Bootstrap, architecture folders, DI root, test policy, formatting, analysis, debug compilation, and manual launch | Start Step 2 | None |
| 2026-09-18 | Step 2 | Android flavors, explicit entry points, tenant themes and components, approved tests, APK builds, and emulator launches | Start Step 3 | Step 3 test proposal must be approved before tests are written |
| 2026-09-18 | Step 2 refinement | Moved tenant identity, theme, scope, and catalog into `core`; kept payment contracts and ViewData in the payment feature; moved concrete brand composition into `flavors`; analysis, tests, and both APK builds passed | Start Step 3 | Step 3 test proposal must be approved before tests are written |
| 2026-09-18 | Step 3 | Pure-Dart payment and security models, failures, repository contracts, use cases, approved unit tests, dependency audit, formatting, and analysis | Start Step 4 | Step 4 `bloc_test` coverage must be proposed and approved before tests are written |
| 2026-09-18 | Step 4 | Immutable PaymentBloc events and states, security re-checks, processing orchestration and cleanup, 19 approved BLoC tests, temporary manual smoke flow, formatting, and analysis | Start Step 5 | Step 5 test coverage must be proposed and approved before tests are written |
| 2026-09-18 | Step 5 | Shared PaymentBloc UI, debug scenario page, simulated adapters, flavor-owned ordered section keys, mapper-owned widget construction, analysis, both debug APK builds, and approved 360x640 ready-state inspections | Start Step 6 | Step 6 investigation recommendation requires approval before security implementation |
| 2026-09-18 | Step 6 | Researched Android recording APIs and root-detection options; documented requirement traceability; approved RootBeer 0.1.2 plus the API 35 recording callback and cross-version `FLAG_SECURE` approach | Start Step 7 | Step 7 Kotlin detector and Dart channel-adapter tests must be proposed and approved before tests are written |
| 2026-09-19 | Step 7 | Added RootBeer-backed root checks, lifecycle-safe recording callbacks, MethodChannel snapshots, EventChannel updates, domain/BLoC integration, approved tests, diagnostics, lint, analysis, and both flavor builds | Start Step 8 | Step 8 test coverage must be proposed and approved before tests are written |
| 2026-09-19 | Step 8 | Added minimal route-aware payment-window protection, approved Dart adapter tests, analysis, Android lint, and both flavor builds | Perform runtime window-protection checks only if later authorized | Screenshot, recording, and Android system-state inspection were explicitly excluded |
| 2026-09-19 | Step 8 refinement | Extracted route observation, flag transitions, diagnostics, and failure messaging into reusable `SecurePageMixin`; analysis and adapter tests passed | Use the mixin on any additional sensitive screen | Runtime inspection remains excluded |
| 2026-09-19 | Step 8 Recents fix | Added API 33+ Recents-screenshot suppression alongside `FLAG_SECURE` after API 34 exposed payment content in Overview | Recheck API 34 Recents behavior | Runtime inspection remains excluded unless authorized |
| 2026-09-19 | Step 8 pre-commit | Preserved protection when popping between secure routes; full formatting, 78 tests, analysis, Android lint, and both flavor APK builds passed | Confirm the API 34 Recents fix, then mark Step 8 done and commit if approved | Runtime confirmation remains outstanding |
| 2026-09-19 | Step 9 automated implementation | Added the foreground payment service, sticky progress notification, native channels, production repository adapter, 12 approved adapter tests, clean analysis, flavor lint, and both debug APK builds | User performs the agreed manual notification and lifecycle checks | Manual confirmation is required before marking Step 9 done |
| 2026-09-19 | Step 9 coroutine refinement | Replaced raw concurrency primitives with service/channel coroutine scopes, cancellable delays, and Mutex-protected coordinator state; all 90 tests, analysis, flavor lint, and both builds passed | User performs the agreed manual notification and lifecycle checks | Manual confirmation is required before marking Step 9 done |
| 2026-09-19 | Step 9 notification refinement | Added a fresh high-importance channel, heads-up priority, Retail orange and Utility navy styling, flavor titles, and a custom payment badge; all 90 tests, analysis, flavor lint, and both APK builds passed | User verifies heads-up behavior and styling on-device | Manual confirmation is required before marking Step 9 done |
| 2026-09-19 | Step 9 color refinement | Moved notification styling into native flavor resource folders with three-color Retail and Utility palettes; all 90 tests, analysis, flavor lint, and both APK builds passed | User verifies each flavor's colors on-device | Manual confirmation is required before marking Step 9 done |
| 2026-09-19 | Step 9 API 36.1 and icon refinement | Bound payment content to a page-owned ScrollController, resolved both notification icon slots directly from the flavor launcher resource, verified the packaged icon hashes, and built both APKs sequentially; all 90 tests, analysis, and flavor lint passed | User verifies scroll retention and the notification icon on-device | Manual confirmation remains required |
| 2026-09-19 | Step 9 scroll-layout refinement | Kept security, 100% progress, and a disabled `Payment completed` action in the successful terminal layout so completion no longer shortens the list; all 90 tests, analysis, flavor lint, and both sequential APK builds passed | User verifies the completed layout and scroll position on-device | Manual confirmation remains required |
| 2026-09-19 | Step 9 finalization | Recorded the user's on-device verification ownership and finalized the foreground-processing implementation | Start Step 10 | None |
| 2026-09-19 | Step 10 implementation | Added the adaptive theme-driven Shield Radar Sweep, isolated animation repainting, cached painter geometry, clean analysis, 90 passing regression tests, and both debug flavor APKs | User performs the agreed visual, reduced-motion, repaint-boundary, and 60/120 Hz checks | Step 10 remains in progress until user-owned runtime verification is confirmed |
| 2026-09-19 | Step 10 manual refinement | Added completed-state recording updates, threat-aware completed radar state, a compact flavored result message, and an active `Pay again` action; formatting and analysis passed | User manually verifies the requested behavior | No tests, builds, or runtime checks were run per user instruction |
| 2026-09-19 | Step 10 color and motion refinement | Kept the radar rotating in every state, strengthened green/red status cues, and layered them over tenant-accented shield, rings, border, and background styling; formatting and analysis passed | User manually verifies both flavors and security states | No tests, builds, or runtime checks were run per user instruction |
| 2026-09-19 | Step 10 continuity refinement | Reduced status chips to flavor-themed surfaces with semantic-color icons and replaced mode-dependent controller restarts with one continuous three-second radar cadence; formatting and analysis passed | User manually verifies chip styling and the Confirm payment transition | No tests, builds, or runtime checks were run per user instruction |
| 2026-09-19 | Step 10 confirmation refinement | Stabilized the security heading, removed the redundant circular indicator, and added an injected three-second confirmation scan before the real security check; formatting and analysis passed | User manually verifies the Confirm payment transition and timing | No tests, builds, or runtime checks were run per user instruction |
| 2026-09-19 | Step 10 scan-state refinement | Added an in-place title cross-fade and a high-contrast inverted tenant palette for the active scan while retaining subdued green monitoring and red threat styling; formatting and analysis passed | User manually verifies state distinction in both flavors | No tests, builds, or runtime checks were run per user instruction |
| 2026-09-19 | Step 10 motion semantics refinement | Enabled scenario controls in profile builds, restored the light tenant radar palette, limited green to clear monitoring, changed completion to a tenant-colored check, and added cross-faded state changes with an eased stop at the current sweep phase; formatting and analysis passed | User manually verifies profile controls and radar transitions | No tests, builds, or runtime checks were run per user instruction |
| 2026-09-19 | Step 10 status semantics refinement | Unified ready and completed radar visuals as clean green states, kept tenant blue for active scanning and red for security errors, and removed the redundant completion checkmark; formatting and analysis passed | User manually verifies the Utility radar sequence | No tests, builds, or runtime checks were run per user instruction |
| 2026-09-19 | Step 10 scan-settle refinement | Preserved the sweep's exact phase across controller mode changes, replaced the 120 ms Utility stop with a matched 500 ms deceleration, and synchronized the blue-to-green crossfade with that settling motion; formatting and analysis passed | User manually verifies the Utility scanning-to-clear transition | No tests, builds, or runtime checks were run per user instruction |
| 2026-09-20 | Step 10 finalization | Recorded final user acceptance after iterative manual review of radar status semantics and transition continuity | Prepare the Step 10 commit | Dedicated repaint-boundary and 60/120 Hz traces were not supplied; later refinements intentionally received no tests or builds |
