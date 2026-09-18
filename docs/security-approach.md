# Android Security Approach

Investigation date: 2026-09-18

## Recommendation

For this no-backend test task, implement the security check in Kotlin behind
the existing domain repository boundary:

1. Invoke RootBeer's standard `isRooted()` check from Kotlin on a Flutter
   background task queue.
2. On Android 15 / API 35 and newer, use
   `WindowManager.addScreenRecordingCallback` and retain its current state.
3. On API 24-34, return `unsupported` for screen-recording detection. Do not
   infer recording from screenshot callbacks, displays, processes, or app
   inventories.
4. Keep `FLAG_SECURE` as an independent protection in Step 8 on every supported
   Android version. On API 33+, also disable Recents screenshots while the
   payment route is current. Detection and prevention are separate controls.

RootBeer 0.1.2 is the approved version because its March 2026 release added
`/system_ext/bin` coverage and 16 KB native-library page-size support. Although
the maintainer initially reported a Maven Central publishing failure, the
artifact is now available there. Step 7 should therefore use the exact
`com.scottyab:rootbeer-lib:0.1.2` coordinate, record the published AAR checksum
`0980126fccc8343448d2989a49fc3a54357d43f7453b9182be30f4141c9f10c0`,
retain its Apache-2.0 license notice, and avoid JitPack or a vendored binary.

The screen-recording API adds one install-time normal permission,
`android.permission.DETECT_SCREEN_RECORDING`, with no runtime prompt. Neither
the app integration nor RootBeer requires network access. Do not request
`QUERY_ALL_PACKAGES`; RootBeer's package-name subchecks will consequently be
limited by Android package visibility, while its file, binary, property,
mount, test-key, `which su`, Magisk, and native checks remain available.

## Capability Matrix

| Signal | Support | Classification | Meaning and limitation |
| --- | --- | --- | --- |
| App visible in an active screen recording | API 35+ | Reliable within the public Android API contract | `WindowManager.addScreenRecordingCallback` returns the initial state and reports visibility changes for activities owned by the app UID. It requires the normal `DETECT_SCREEN_RECORDING` permission. |
| App visible in an active screen recording | API 24-34 | Unsupported | Android did not expose the recording-visibility callback before API 35. |
| Screenshot attempt | API 34+ | Reliable but irrelevant to this requirement | `Activity.ScreenCaptureCallback` reports a screenshot, not an ongoing recording, and is not invoked when `FLAG_SECURE` is set. It must not be relabeled as recorder detection. |
| RootBeer `isRooted()` result | API 24+ | Heuristic | RootBeer combines Java and native checks for root apps, `su`, dangerous properties, writable system paths, test keys, `which su`, and Magisk. A positive blocks confirmation. A negative only means its indicators were not visible to this app process. |
| BusyBox alone | API 24+ | Weak/ambiguous | RootBeer's standard `isRooted()` intentionally excludes BusyBox because some stock devices ship it. Do not use `isRootedWithBusyBoxCheck()`. |
| Definitive proof that a device is not rooted | All | Impossible locally | A privileged or hooked environment can hide files, alter API results, or patch the app/channel. “Clear” therefore means “no configured heuristic matched,” not “trusted device.” |
| Camera filming the display, external capture hardware, or a compromised OS falsifying callbacks | All | Impossible for the app to detect reliably | These are outside the Android app-process trust boundary. |

## RootBeer Integration Scope

The Kotlin adapter should:

- own a RootBeer instance created with the application context;
- call the standard `isRooted()`, not the BusyBox-inclusive variant;
- report `detected` when RootBeer returns `true`, otherwise `clear`;
- perform the check away from the Android UI thread, as RootBeer recommends;
- pin the Maven Central 0.1.2 artifact, record its checksum, and retain its
  license notice; and
- expose no indicator paths or device details to the presentation layer.

The integration should not:

- add custom root heuristics beside RootBeer;
- use RootBeer's BusyBox-inclusive check;
- request `QUERY_ALL_PACKAGES` solely to improve package-name subchecks;
- send RootBeer results or device details over the network; or
- claim that a `clear` heuristic result proves the device is trustworthy.

## Screen-Recording Lifecycle

On API 35+, the activity should register one callback while started, accept the
integer returned by registration as the initial state, update a thread-safe
cached state from subsequent callbacks, and unregister the same callback in
`onStop`. The callback should use the activity main executor, as required for
lifecycle/window work.

Recording-state changes are also published through an EventChannel so the
PaymentBloc can block and unblock the visible payment state immediately when
recording starts or stops. The MethodChannel remains the authoritative
point-in-time check used during loading and immediately before confirmation.

The MethodChannel check should run on a Flutter background task queue so root
filesystem work cannot block the platform/UI thread. The channel response can
then combine the root result with the cached recording state. Unsupported API
levels must map to the existing domain `unsupported` state; unexpected native
or channel failures must remain failures so the existing BLoC can fail closed.

## Alternatives Considered

| Option | Maintenance and compatibility | Dependencies / privacy | Decision |
| --- | --- | --- | --- |
| RootBeer | Active project; release 0.1.2 was published in March 2026 and added `/system_ext/bin` plus 16 KB native-library page-size work. Its own documentation describes results as indications and advises background execution. The artifact is now available from Maven Central despite the initial publication issue. | Adds Apache-2.0 Java/JNI code and packaged native libraries; no network access. Package-name checks are limited without explicit package visibility. | Approved for Step 7; pin `com.scottyab:rootbeer-lib:0.1.2` and record the published AAR checksum |
| Direct Kotlin heuristic | Fully owned and auditable, but would duplicate a narrower subset of RootBeer's checks and require ongoing maintenance | No dependency, network, package inventory, or collected data | Rejected in favor of the user-selected maintained library |
| Flutter root/jailbreak wrappers | Several are currently published, commonly wrapping RootBeer | Adds a second plugin/channel abstraction while this task explicitly evaluates our Kotlin MethodChannel; often includes unrelated iOS/emulator checks | Rejected |
| freeRASP | Actively maintained and much broader than root detection | Freemium binary SDK, configuration and lifecycle surface, unrelated RASP features, and anonymized security-diagnostic collection | Rejected as disproportionate to the task |
| Play Integrity API | Google's preferred high-resilience integrity signal, using hardware-backed signals where available | Requires Google Play setup, network calls, and trusted backend verification; expands scope beyond the confirmed no-backend decision | Best production direction if scope changes, not for Step 7 |

No client-only option prevents bypass by a determined attacker. OWASP likewise
treats local root detection as a resilience layer rather than proof and shows
that common Java/native checks can be hooked or hidden.

## Requirement Traceability

| Requirement | Coverage | Planned implementation |
| --- | --- | --- |
| Use Kotlin for Android system integration | Covered | Kotlin owns RootBeer invocation, screen-recording lifecycle, MethodChannel/EventChannel handling, and `FLAG_SECURE` window calls. RootBeer is an implementation dependency, not a replacement for the Kotlin bridge. |
| MethodChannel detects a rooted device | Covered heuristically on API 24+ | Step 7 calls RootBeer `isRooted()` off the UI thread, maps `true`/`false` to typed channel data, and preserves native failures. As with every local root detector, “clear” is not cryptographic proof. |
| MethodChannel detects an active screen recorder | Covered on API 35+; explicitly unsupported on API 24-34 | Step 7 caches the official `WindowManager` recording-visibility callback state and includes it in the same typed channel result. No truthful public equivalent exists on older versions. |
| Automatically apply `FLAG_SECURE` while the Payment Page is visible | Covered by Step 8 | Page visibility calls Kotlin through the native bridge; Kotlin sets the flag on the Android UI thread, keeps it while the page is current/backgrounded, and clears it only after leaving. API 33+ also disables the Activity screenshot used by Recents. |
| Prevent screenshots/screen-sharing | Covered as platform mitigation | `FLAG_SECURE` prevents the protected window from appearing in screenshots and non-secure displays. Android documents limitations on some older/OEM devices, so it is a mitigation rather than an absolute guarantee. |

## Sources

- [Android `WindowManager.addScreenRecordingCallback` API](https://developer.android.com/reference/android/view/WindowManager#addScreenRecordingCallback(java.util.concurrent.Executor,%20java.util.function.Consumer))
- [Android 15 screen-recording detection](https://developer.android.com/about/versions/15/features#screen-recording-detection)
- [Android permission reference](https://developer.android.com/reference/android/Manifest.permission#DETECT_SCREEN_RECORDING)
- [Android 14 screenshot callback](https://developer.android.com/reference/android/app/Activity.ScreenCaptureCallback)
- [Android guidance for securing sensitive activities](https://developer.android.com/security/fraud-prevention/activities)
- [Android `Activity.setRecentsScreenshotEnabled` API](https://developer.android.com/reference/android/app/Activity#setRecentsScreenshotEnabled(boolean))
- [Flutter platform-channel threading](https://docs.flutter.dev/platform-integration/platform-channels#channels-and-platform-threading)
- [Play Integrity overview](https://developer.android.com/google/play/integrity/overview)
- [Play Integrity standard request and server verification](https://developer.android.com/google/play/integrity/standard)
- [Android hardware-backed key attestation](https://developer.android.com/privacy-and-security/security-key-attestation)
- [Google Play package-visibility policy](https://support.google.com/googleplay/android-developer/answer/10158779)
- [RootBeer project and limitations](https://github.com/scottyab/rootbeer)
- [RootBeer 0.1.2 release](https://github.com/scottyab/rootbeer/releases/tag/0.1.2)
- [RootBeer 0.1.2 publication issue](https://github.com/scottyab/rootbeer/issues/257)
- [freeRASP Flutter project](https://github.com/talsec/Free-RASP-Flutter)
- [freeRASP user-data policy](https://docs.talsec.app/freerasp/user-data-policies)
- [OWASP root-detection guidance](https://mas.owasp.org/MASTG-KNOW-0027/)
- [OWASP root-detection bypass guidance](https://mas.owasp.org/MASTG-TECH-0144/)
