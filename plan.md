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
- A step is `Done` only after its approved automated tests, manual checks,
  formatting, and static analysis pass.
- Record completed work and remaining work in the cross-chat handoff log.
- Surface ambiguous requirements before implementing them.

## Progress Summary

| Step | Workstream | Status | Depends on |
| --- | --- | --- | --- |
| 1 | Architecture foundation | Not started | - |
| 2 | Flavors and tenant configuration | Not started | 1 |
| 3 | Payment domain | Not started | 1 |
| 4 | Payment BLoC | Not started | 3 |
| 5 | Tenant payment UI | Not started | 2, 4 |
| 6 | Security approach investigation | Not started | 1 |
| 7 | Kotlin security environment check | Not started | 3, 6 |
| 8 | Payment-page window protection | Not started | 5, 7 |
| 9 | Foreground payment processing | Not started | 4, 7 |
| 10 | Security animation | Not started | 2, 5 |

## Step 1 - Establish the Architecture Foundation

**Status:** Not started

**PDF mapping:** Architecture-first recommendation; scalability, Clean
Architecture, and SOLID evaluation criteria.

### Implementation

- [ ] Replace the counter-demo structure with the application bootstrap.
- [ ] Create the feature-first clean architecture folders.
- [ ] Create the `get_it` composition root.
- [ ] Enforce the agreed dependency direction.
- [ ] Add only abstractions required by the payment and security features.

### Verification gate

- [ ] Present bootstrap and dependency-registration unit tests for approval.
- [ ] Obtain approval before writing or modifying tests.
- [ ] Run approved automated tests.
- [ ] Launch the application manually.
- [ ] Confirm domain imports no Flutter, BLoC, data, or platform code.
- [ ] Run formatting and static analysis.

**Completion evidence:** _Pending_

## Step 2 - Implement Flavors and Tenant Configuration

**Status:** Not started

**PDF mapping:** Section 3A, Multi-Tenant Architecture; third/fourth-brand
scalability criterion.

### Implementation

- [ ] Create the `retail` Android flavor and Dart entry point.
- [ ] Create the `utility` Android flavor and Dart entry point.
- [ ] Define immutable tenant configurations.
- [ ] Provide colors, typography, shapes, spacing, density, and motion through
      configuration and ThemeExtensions.
- [ ] Register the promo banner, bill breakdown, and flavor-specific security
      error presentation through tenant components.
- [ ] Keep branding conditionals out of shared widgets.
- [ ] Confirm both configurations support separate APK builds.

### Verification gate

- [ ] Present configuration-completeness and flavor-selection tests for
      approval.
- [ ] Obtain approval before writing or modifying tests.
- [ ] Run approved automated tests.
- [ ] Build and launch both flavors manually.
- [ ] Confirm each flavor selects only its own configuration.
- [ ] Run formatting and static analysis.

**Completion evidence:** _Pending_

## Step 3 - Implement the Payment Domain

**Status:** Not started

**PDF mapping:** Payment Confirmation Module; Clean Architecture and SOLID
evaluation criteria.

### Implementation

- [ ] Create pure Dart payment, amount, reference, and bill-item models.
- [ ] Create security-status, payment-progress, and payment-result models.
- [ ] Define payment and security failures.
- [ ] Define repository contracts in domain.
- [ ] Add use cases for checking security and determining whether confirmation
      is allowed.
- [ ] Add use cases for starting simulated processing and observing progress.

### Verification gate

- [ ] Present entity, use-case, repository-contract, and failure-propagation
      unit tests for approval.
- [ ] Obtain approval before writing or modifying tests.
- [ ] Run approved automated tests.
- [ ] Inspect domain imports and dependency direction manually.
- [ ] Run formatting and static analysis.

**Completion evidence:** _Pending_

## Step 4 - Implement the Payment BLoC

**Status:** Not started

**PDF mapping:** Scalable Flutter architecture and separation of business logic
from UI.

### Implementation

- [ ] Create immutable PaymentBloc events and states.
- [ ] Handle initial payment loading and security checking.
- [ ] Handle confirmation requests.
- [ ] Block confirmation for root or active screen recording.
- [ ] Handle foreground-service progress, completion, and failure.
- [ ] Keep business decisions in domain use cases.

### Verification gate

- [ ] Present `bloc_test` coverage for every event, state transition, and
      failure path for approval.
- [ ] Obtain approval before writing or modifying tests.
- [ ] Run approved automated tests.
- [ ] Exercise the complete state flow manually with temporary repository
      implementations.
- [ ] Run formatting and static analysis.

**Completion evidence:** _Pending_

## Step 5 - Build the Payment UI for Both Tenants

**Status:** Not started

**PDF mapping:** Section 3A Brand A and Brand B visual and functional
requirements.

### Implementation

- [ ] Build the shared payment-page shell.
- [ ] Add the payment summary, security state, animation area, tenant content,
      confirmation action, progress, and result presentation.
- [ ] Implement the Retail Shop orange/gold palette, rounded components, fluid
      transitions, and promo banner.
- [ ] Implement the Utility Pay navy/slate palette, sharp components,
      high-density layout, and detailed bill breakdown.
- [ ] Implement a distinct security error presentation for each flavor.
- [ ] Keep both variants on the same domain and PaymentBloc.

### Verification gate

- [ ] Present widget tests for shared states, tenant components, and security
      errors for approval.
- [ ] Obtain approval before writing or modifying tests.
- [ ] Run approved automated tests.
- [ ] Compare both flavors manually on small and standard Android screens.
- [ ] Run formatting and static analysis.

**Completion evidence:** _Pending_

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
| 1 | _Pending_ | _Pending_ | _Pending_ | _Pending_ |
| 2 | _Pending_ | _Pending_ | _Pending_ | _Pending_ |
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

## Cross-Chat Handoff Log

Add one concise row whenever a chat completes or hands work to another chat.

| Date | Step | Completed | Next action | Blockers or approvals needed |
| --- | --- | --- | --- | --- |
| 2026-09-18 | Planning | Requirements and implementation plan approved | Start Step 1 | Step 1 test proposal must be approved before tests are written |
