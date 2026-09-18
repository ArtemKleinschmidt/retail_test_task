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

| Step | Workstream | Status | Depends on |
| --- | --- | --- | --- |
| 1 | Architecture foundation | Done | - |
| 2 | Flavors and tenant configuration | Done | 1 |
| 3 | Payment domain | Done | 1 |
| 4 | Payment BLoC | Done | 3 |
| 5 | Tenant payment UI | In progress | 2, 4 |
| 6 | Security approach investigation | Not started | 1 |
| 7 | Kotlin security environment check | Not started | 3, 6 |
| 8 | Payment-page window protection | Not started | 5, 7 |
| 9 | Foreground payment processing | Not started | 4, 7 |
| 10 | Security animation | Not started | 2, 5 |

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
Utility now own immutable ordered lists of reusable payment-section widgets;
the shared renderer contains no flavor branches, tenant IDs, placement enums,
or predefined slots. Promo Banner and Bill Breakdown titles and ordering were
verified in both flavors. `fvm flutter analyze` reported no issues, all 59
approved unit and BLoC tests passed, both debug flavor APKs compiled, and the
approved inspection-only Retail and Utility ready-state captures passed at a
360x640 logical viewport without creating screenshot baselines.

## Step 6 - Investigate Android Security Checks

**Status:** Not started

**PDF mapping:** Section 3B Security Environment Check; Android-depth
evaluation criterion.

### Investigation

- [ ] Review current official Android APIs and security guidance.
- [ ] Research root-detection techniques and limitations.
- [ ] Determine screen-recording detection support by Android version.
- [ ] Evaluate maintained third-party libraries.
- [ ] Compare maintenance, permissions, dependencies, privacy, compatibility,
      and known bypasses against a direct Kotlin implementation.
- [ ] Recommend the smallest correct implementation.
- [ ] Document reliable, heuristic, unsupported, and impossible checks.
- [ ] Present the recommendation for approval before security implementation.

### Verification gate

- [ ] Review the sources, limitations, and recommendation with the user.
- [ ] Record the approved approach in the decision log.

No tests are required because this step produces no application code.

**Completion evidence:** _Pending_

## Step 7 - Implement the Kotlin Security Environment Check

**Status:** Not started

**PDF mapping:** Section 3B root and screen-recorder detection through Kotlin
and MethodChannel; MethodChannel thread-safety evaluation.

### Implementation

- [ ] Implement the approved root-detection approach.
- [ ] Implement the approved screen-recording detection approach.
- [ ] Represent unsupported detection explicitly.
- [ ] Expose typed results through a MethodChannel.
- [ ] Keep expensive checks off the Android UI thread.
- [ ] Register and unregister native callbacks safely.
- [ ] Map MethodChannel responses through data into domain models.
- [ ] Deliver results to PaymentBloc only through domain use cases.

### Verification gate

- [ ] Present Kotlin detector and Dart channel-adapter unit tests for approval.
- [ ] Obtain approval before writing or modifying tests.
- [ ] Run approved automated tests.
- [ ] Manually verify available rooted/non-rooted signals, active/inactive
      recording, unsupported versions, and channel errors.
- [ ] Run formatting and static analysis.

**Completion evidence:** _Pending_

## Step 8 - Implement Payment-Page Window Protection

**Status:** Not started

**PDF mapping:** Section 3B Window Protection.

### Implementation

- [ ] Add native commands to apply and clear
      `WindowManager.LayoutParams.FLAG_SECURE`.
- [ ] Enable protection when the payment page becomes visible.
- [ ] Keep protection active while the page remains current or the app is
      backgrounded.
- [ ] Clear protection after leaving the payment page.
- [ ] Make repeated and out-of-order calls safe.
- [ ] Execute window changes on the Android UI thread.

### Verification gate

- [ ] Present page-lifecycle and native flag-controller unit tests for
      approval.
- [ ] Obtain approval before writing or modifying tests.
- [ ] Run approved automated tests.
- [ ] Manually attempt screenshots and screen sharing on the payment page.
- [ ] Manually verify protection clears after navigation away.
- [ ] Run formatting and static analysis.

**Completion evidence:** _Pending_

## Step 9 - Implement Foreground Payment Processing

**Status:** Not started

**PDF mapping:** Section 3B Foreground Service; service lifecycle and modern API
compliance evaluation.

### Implementation

- [ ] Create a Kotlin foreground service for deterministic simulated payment
      processing.
- [ ] Display a persistent system notification with a progress bar.
- [ ] Apply current Android notification and foreground-service requirements.
- [ ] Send progress and completion to Flutter.
- [ ] Connect native progress through data and domain to PaymentBloc.
- [ ] Keep both flavors independently buildable as APKs.

### Verification gate

- [ ] Present Kotlin service, Dart adapter, and PaymentBloc progress tests for
      approval.
- [ ] Obtain approval before writing or modifying tests.
- [ ] Run approved automated tests.
- [ ] Manually verify notification progress, background processing, resume,
      rotation, and completion.
- [ ] Run formatting and static analysis.

**Completion evidence:** _Pending_

## Step 10 - Select and Implement the Security Animation

**Status:** Not started

**PDF mapping:** Section 3C Custom Graphics and Optimization; performance
evaluation criterion.

### Concept approval

- [ ] Propose several focused animation concepts.
- [ ] Describe each concept's visual behavior, painter mathematics, complexity,
      and performance implications.
- [ ] Obtain the user's animation selection before implementation.

### Implementation

- [ ] Implement the selected animation with CustomPainter.
- [ ] Drive repainting directly from an animation listenable.
- [ ] Avoid per-frame rebuilds of the surrounding widget tree.
- [ ] Isolate the painter with RepaintBoundary.
- [ ] Cache static drawing objects and geometry.
- [ ] Profile the animation under payment-processing load at 60 Hz and, when
      supported by the available device, 120 Hz.

### Verification gate

- [ ] Present painter-math and repaint-behavior tests for approval.
- [ ] Obtain approval before writing or modifying tests.
- [ ] Run approved automated tests.
- [ ] Manually profile frame timing and inspect repaint boundaries for both
      flavors.
- [ ] Run formatting and static analysis.

**Completion evidence:** _Pending_

## Ongoing Requirements

Track these throughout implementation; they are not separate implementation
steps.

### AI collaboration evidence

- [ ] Capture 2-3 genuine Codex interactions involving complex work.
- [ ] Record how AI output was reviewed and refined.
- [ ] Record one suboptimal AI suggestion and its correction.
- [ ] Explain the multi-tenant configuration structure.
- [ ] Explain how AI accelerated development.

| Interaction | Problem | AI contribution | Audit or correction | Evidence |
| --- | --- | --- | --- | --- |
| 1 | Multi-tenant flavor and theme architecture | Added flavor wiring, immutable configuration, ThemeExtension tokens, and tenant component strategies | The first Gradle build exposed that AGP 9.1 disables custom resource values by default; enabled `buildFeatures.resValues` and rebuilt both variants | Step 2 conversation, repository diff, tests, and APK build output |
| 2 | Payment-domain contracts and security policy | Added immutable value objects, typed failures, repository boundaries, use cases, and focused tests | The initial sealed processing subclasses were split across files, which Dart rejects; consolidated the union into one library and reran all verification | Step 3 conversation, repository diff, test output, and analysis output |
| 3 | _Optional_ | _Optional_ | _Optional_ | _Optional_ |

### Deliverables

- [ ] Keep the source code clean and modular.
- [ ] Keep both flavors buildable as separate APKs.
- [ ] Decide between APKs and a demonstration video after implementation.
- [ ] Produce the required AI insight report from the recorded evidence.
- [ ] Prepare the source repository or ZIP.

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
| 2026-09-18 | Step 5 | Let each flavor own an ordered list of reusable payment-section widgets | Removes fragile placement slots while keeping shared payment rendering free of flavor conditionals |

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
| 2026-09-18 | Step 5 | Shared PaymentBloc UI, debug scenario page, simulated adapters, flavor-owned ordered payment sections, 59 passing tests, analysis, both debug APK builds, and approved 360x640 ready-state inspections | Start Step 6 | Step 6 investigation recommendation requires approval before security implementation |
