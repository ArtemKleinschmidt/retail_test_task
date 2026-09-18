# Project Guidelines

## Toolchain

- Use the Flutter version specified in `.fvmrc` through FVM. Treat `.fvmrc`
  as the single source of truth; do not hardcode the version elsewhere.
- Prefix Flutter and Dart commands with `fvm`, for example:
  - `fvm flutter pub get`
  - `fvm flutter analyze`
  - `fvm flutter test`
  - `fvm dart format .`

## Communication

- Be concise and keep answers digestible without omitting assumptions,
  tradeoffs, risks, or information needed to make a decision.
- Do not over-explain routine work. Do not oversimplify technical decisions.

## Working Approach

These rules favor caution over speed. Use judgment for trivial tasks.

### Think Before Coding

- State assumptions explicitly. If something is uncertain or unclear, stop,
  name the ambiguity, and ask before implementation.
- When multiple interpretations exist, present them instead of choosing one
  silently.
- Point out a simpler approach or a relevant tradeoff when one exists. Push
  back when a request would create unnecessary complexity.

### Simplicity First

- Write the minimum code that solves the requested problem.
- Do not add speculative features, single-use abstractions, unrequested
  configurability, or handling for impossible scenarios.
- If an implementation is substantially longer than necessary, simplify it.
- Ask whether a senior engineer would consider the solution overcomplicated;
  if so, reduce it.

### Surgical Changes

- Touch only files and lines required by the request.
- Do not refactor, reformat, or clean up adjacent code that is unrelated.
- Match the existing project style.
- Mention unrelated dead code instead of deleting it.
- Remove imports, variables, and functions made unused by the current change,
  but do not remove pre-existing unused code unless requested.
- Every changed line must trace directly to the user's request.

### Version Control

- Never create a commit or push changes without the user's explicit approval.
  Approval applies only to the commit and push requested at that time; do not
  treat it as standing permission for later changes.
- When the user asks to commit changes, propose the exact commit message and
  obtain explicit confirmation before running `git commit`.

### Goal-Driven Execution

- Turn requests into verifiable goals and define success before coding.
- For multi-step work, state a brief sequence in the form
  `step -> verification`.
- Continue until the agreed success criteria are verified. Do not treat
  "make it work" as sufficient validation.

## Architecture

- Organize product code by feature under `lib/features/<feature>/`.
- Split each feature into `domain`, `data`, and `presentation` layers.
- Keep the domain layer pure Dart. It must not import Flutter, BLoC, data-layer
  implementations, or platform packages.
- Define repository contracts and use cases in `domain`; implement those
  contracts in `data`.
- Keep dependency wiring in the application composition root with `get_it`.
  Do not access the service locator from domain objects.
- Always use BLoC in the presentation layer. Do not use Cubit. Widgets render
  state and dispatch events; business rules belong in use cases or domain
  objects.
- Shared, feature-independent code belongs in `lib/core/`. Avoid moving
  feature-specific abstractions into `core`.

## Quality

- Prefer immutable states, events, entities, and value objects. Use
  `Equatable` where value equality is useful.
- Limit automated tests in this test task to unit tests and BLoC tests using
  `bloc_test`. Do not add widget tests or integration tests.
- Keep tests meaningful and minimal. Test project-owned behavior, not
  third-party frameworks or libraries.
- Do not add coverage-only tests for trivial wiring, empty registrations, or
  behavior already guaranteed by a dependency. If a step introduces no
  meaningful unit-testable or BLoC behavior, document that and rely on static
  analysis and the agreed manual checks.
- For every implementation step, propose the relevant automated tests and
  manual checks before writing tests.
- Do not add or modify tests until the user explicitly approves the proposed
  test coverage. After approval, a step is not complete until its approved
  tests and manual checks pass.
- Cover project-owned domain, data, and independently testable platform
  behavior with unit tests. Cover BLoCs with `bloc_test` and use `mocktail`
  only at dependency boundaries.
- Verify UI rendering, application bootstrap, flavor launches, and end-to-end
  platform behavior manually.
- Do not complicate production code solely to make framework startup or UI
  behavior unit-testable.
- Mirror the `lib/` structure under `test/` where practical.
- Before finishing a change, run formatting, analysis, and relevant tests.
- Keep dependencies minimal and justify new packages at their layer boundary.
- These guidelines are working when diffs contain fewer unnecessary changes,
  solutions need fewer complexity-driven rewrites, and ambiguities are raised
  before implementation rather than after mistakes.
