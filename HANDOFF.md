# Handoff — YMS_InfoConference / YealinkMeetingPlanner

**Created:** 2026-09-05
**Updated:** 2026-09-06 (Session 2: Phase 1 — DI & DIP fixes done. ✅ App compiles)
**Status:** 🟢 All planned phases (1-5) done + Phase 1 of next review cycle done. ✅ App compiles (build succeeded)

---

## Goal

Refactor the **YealinkMeetingPlanner** SwiftUI app to fix critical architecture violations identified in the code review (`code-review-yealink-meeting-planner.md`). The app is a conference room scheduler for Yealink devices with features including schedule display, weather forecast, QR-based API key scanning, and settings.

---

## Current Progress

- ✅ Code review completed — detailed report at `code-review-yealink-meeting-planner.md`
- ✅ **Phase 1 complete** (critical MVVM fixes):
  - 1.1 Removed `@Query` from `ConferenceRoomScreen` — View now uses `viewModel.confDataItems`
  - 1.2 Replaced `@StateObject` with `@ObservedObject` (VM ownership hoisted to `YealinkMeetingPlannerApp` via `@StateObject` — now a single stable instance)
  - 1.3 Added `deinit` Timer cancellation in `ConferenceViewModel` (clears `cancellables`) and `HeaderViewModel` (cancels `cancellable`)
  - 1.4 Replaced `try!` with `try?`/guard in previews of `ConferenceRoomScreen` and `SelectRoomView` (uses `AnyView` fallback)
- ✅ **Phase 2 complete** (business logic moved into ViewModels): `MeetingDisplayState`/`currentMeetingDisplay` + `busySlots` in `ConferenceViewModel`; date formatting moved into `WeatherViewModel`; icon mapping already centralised
- ✅ **Phase 3 complete** (SOLID):
  - 3.1.1 `KeychainService` protocol added (in `KeychainManager.swift`); `KeychainManager` conforms. Injected into `ScanViewModel`, `SettingsStore`, `APIConfig` (`static var keychain`, test-stubbable)
  - 3.1.2 `DataStorage` protocol added (`Helpers/DataStorage.swift`), `extension UserDefaults: DataStorage` (empty conformance). Injected into `AppState`, `SettingsStore`, `WeatherViewModel`
  - 3.1.3 `ConferenceRepository` protocol (@MainActor) + `SwiftDataConferenceRepository` (`Conference/ConferenceDatabaseService.swift`) — no direct `ModelContext` in the ViewModel
  - 3.2 SRP split: `ConferenceDataFetcher` (API + cache, `Conference/ConferenceDataFetcher.swift`), `ConferenceDatabaseService` (SwiftData CRUD + DTO mapping), `ConferenceTimeCalculator` (pure time/display logic, `Conference/ConferenceTimeCalculator.swift`). `ConferenceViewModel` now only coordinates (state + Timer lifecycle). `MeetingDisplayState`/`MeetingCardInfo` moved to `ConferenceTimeCalculator.swift`
  - 3.3.1 `weatherIconName` → `Dictionary<Int, String>` (default `questionmark.circle.fill`)
  - 3.3.2 `busyBlockColor` removed from View; `extension ScheduleBlockTone { var color: Color }` in `ScheduleView.swift`
  - Verified: `BUILD SUCCEEDED`, no new warnings
- ✅ **Phase 4 complete** (Clean Code):
  - 4.1 Typos fixed: `ConferenseSheduler` → `ConferenceScheduler` (file `Model/ConferenceScheduler.swift` + protocol/impl in `YmsApiResponse.swift`/`ConferenceDatabaseService.swift`); folder `WetherView` → `WeatherView` (PBX auto-sync, no pbxproj edits); asset `MettingImage.imageset` → `MeetingImage.imageset`, `Image(.metting)` → `Image(.meeting)` (CurrentMeetingView, HeaderView)
  - 4.2 Dead code removed: `LocalData/MockData.swift` (all-commented file + empty dir) deleted; `Model/CodeNDecode.swift` trimmed from 249 → ~40 lines — unused `JSONAny`/`JSONCodingKey` removed, only used `JSONNull` kept (DTOs) with deprecated `hashValue` → `hash(into:)`
  - 4.3 Deduplication: `Helpers/TimeUtils.swift` (single `minutes(of:)` source; `ScheduleSlotFormatter` delegates to it); `Helpers/DateFormatters.swift` (shared `ruFullDate`/`timeHM`/`isoDate`/`shortWeekdayDay` — used by HeaderViewModel, ScheduleView, WeatherViewModel); `Helpers/ModelContext+DeleteAll.swift` (`ModelContext.deleteAll(of:)` generic replaces `SwiftDataConferenceRepository.clearAll()` body and `SelectRoomViewModel.clearRoomsInternal`)
  - 4.4 `Helpers/LayoutDimensions.swift` enum for magic numbers in `ConferenceRoomScreen` (paddings/spacings/card factors/settings button), `CurrentMeetingView` (circle/icon/row padding), `WeatherForecastView` (icon/column widths)
  - Bugfix with Phase 4: `WeatherData.longitude`/`elevation` were `Int` but Open-Meteo returns fractional values (Moscow `37.625`, SPb `30.303894`, Kazan `49.125`) → decode crashed for non-Krasnodar cities (`decodingFailed` «Не удалось разобрать ответ сервера»). Changed both to `Double` in `WeatherModel.swift`
  - Verified: `BUILD SUCCEEDED`, no new warnings (pre-existing warnings only: ConfDataModel accessor macro on `let`, UIScreen.main deprecations)
- ✅ **Phase 5 complete** (Modernize patterns):
  - 5.1 All ViewModels migrated `ObservableObject`/`@Published`/Combine → `@Observable` (`@MainActor @Observable final` for MainActor ones): `ConferenceViewModel`, `HeaderViewModel`, `WeatherViewModel`, `SelectRoomViewModel`, `ScanViewModel`
  - Timers in `ConferenceViewModel`/`HeaderViewModel` moved from Combine `Timer.publish` to native `Timer.scheduledTimer` with `MainActor.assumeIsolated` + `[weak self]`; invalidation in `deinit` via `@ObservationIgnored nonisolated(unsafe)` stored timer (deinit is nonisolated in a @MainActor class)
  - View wiring: `@StateObject`/`@ObservedObject` → `@State` for owned VMs (`HeaderView`, `WeatherForecastView`, `SelectRoomView`, `KeysScannerView`) and plain `let` for injected `ConferenceRoomScreen.viewModel`; `YealinkMeetingPlannerApp` `@StateObject` → `@State`; `KeysScannerView` uses `@Bindable` for `$text1/$text2/$isScannerPresented` bindings
  - Precision fix: `SelectRoomViewModel` needed explicit `import Foundation` after dropping `import SwiftUI` (`SortDescriptor`, `localizedDescription`); `WeatherViewModel`/`SelectRoomViewModel`/`ScanViewModel` now `import Observation`
  - 5.2 Doc-comments added: protocols `YmsApiService`, `ConferenceRepository`, `DataStorage`, `KeychainService`, `WeatherServiceProtocol`; public VM methods (`ScanViewModel` openScanner/handleScannedText/saveData/deleteData, `SelectRoomViewModel.fetchAndSaveRooms`, `ConferenceViewModel.loadCachedData`/`clearData`, `WeatherViewModel.weatherIconName`, `HeaderViewModel.dateString`/`timeString`)
  - Verified: `BUILD SUCCEEDED`, no new warnings (pre-existing warnings only). No `ObservableObject`/`@Published`/`@StateObject`/`@ObservedObject`/`import Combine` remain in the codebase
- ✅ **Demo mode (feature)**: toggle in Settings → `Conference/DemoData.swift`
  - `SettingsStore.isDemoEnabled` (persisted via `storage.bool/forKey`; added `bool(forKey:)` to `DataStorage` protocol)
  - `SettingsView` gets a «Демо-данные» Toggle section at the top ("Демонстрация")
  - `Conference/DemoData.swift` — pure generator: fills 07:00–20:00 with 90-min meetings and guarantees the room is currently occupied (a meeting covers "now"); room name shown as «Демо-конференц-зал» via `ConferenceViewModel.displayRoomName`
  - `ConferenceViewModel` branches on `isDemoEnabled` in `loadSchedule`/`refreshSchedule`/`loadCachedData`/`currentMeetingDisplay` — in demo it serves `DemoData.conferences()` instead of API and skips real-room/no-room states
  - `ConferenceRoomScreen` re-runs `loadSchedule` on `settings.isDemoEnabled` change; preview injects `SettingsStore` + `MockStorage` (test seam). Added `MockStorage` (in-memory `DataStorage`) for previews/tests
  - Verified: `BUILD SUCCEEDED`, no new warnings; logic tested for 07:00–19:30 → always `occupiedNow=true`

### ✅ QRScanner build blocker (fixed)
A previous incomplete change rewrote `QRScannerOverlayView.swift` as a SwiftUI `View`, but `QRScannerViewController` still treated it as a `UIView` → ~10 compile errors.
**Fix applied:** `QRScannerViewController` now hosts the SwiftUI overlay via `UIHostingController` (pinned full-screen, transparent background). The hint label uses a computed position (`centerY + scanRectSize/2 - 24`) instead of `scanRectGuide.bottomAnchor`. `project.pbxproj` Info.plist exception (pre-existing) kept intact. App now builds successfully.

### Project State
- **Last commits:** Features added (settings screen, city selection, room selection, QR scanning, PIN entry)
- **Architecture:** MVVM with critical violations (View reads `@Query` directly, business logic in Views, all SRP/DIP violations)
- **Tech stack:** SwiftUI, SwiftData, `@Observable` everywhere (Combine / `ObservableObject` fully removed)

---

## What Worked (Existing patterns to preserve)

- `AppState.swift` uses `@Observable` correctly — this is the modern pattern to adopt everywhere
- `SettingsStore.swift` also uses `@Observable` correctly
- `YmsApiResponse.swift` provides a clean API client wrapper behind the `YmsApiService` protocol
- `ScheduleSlotFormatter.swift` is clean, pure logic (unit-test candidate) — `ConferenceTimeCalculator` now delegates to it
- Protocols `KeychainService`, `DataStorage`, `ConferenceRepository`, `RoomRepository`, `APICredentialsProviding` are now injectable in all consumers — unit tests can use in-memory fakes
- `ModelContext` access is now confined to `SwiftDataConferenceRepository` (conferences) + `SwiftDataRoomRepository` (rooms)

## What Didn't Work (Known issues to fix)

- **`ConferenceRoomScreen`** — ✅ fixed: no more `@Query`; meeting-card and schedule logic is in the ViewModel
- **All ViewModels** — ✅ fixed (Phase 5): migrated to `@Observable`; `@StateObject`/`@ObservedObject` removed
- **Timer management** — ✅ fixed (Phase 5): Combine `Timer.publish` → native `Timer.scheduledTimer`, invalidated in `deinit`
- **`try!` usage** — ✅ fixed (Phase 1): `try?`/`AnyView` fallbacks in previews
- **Typos in names** — ✅ fixed (Phase 4): `ConferenseSheduler` → `ConferenceScheduler`, `WetherView` → `WeatherView`, `metting` → `meeting`
- **Dead code** — ✅ fixed (Phase 4): `MockData.swift` deleted, `JSONAny` removed from `CodeNDecode.swift`
- **Magic numbers** — ✅ fixed (Phase 4): extracted to `LayoutDimensions` enum in main screens
- **Weather decode bug** — ✅ fixed (Phase 4): `WeatherData.longitude`/`elevation` `Int` → `Double` (Open-Meteo returns fractional values for most cities)

---

## Next Steps (Recommended Order)

### Session 2026-09-06: Code review — remaining issues after Phases 1-5

The following issues were identified in a thorough review of all 46 Swift files (~2800 lines). They were NOT addressed in Phases 1-5.

#### High priority (block testing & maintainability)

**1. ✅ DONE (09-06) View-owned VMs — now injectable**
- `WeatherForecastView`, `HeaderView`, `SelectRoomView` now accept an optional injected VM:
  `init(viewModel: X? = nil)` → `_viewModel = State(initialValue: viewModel ?? X())`
- Ownership stays local via `@State` (preserves instance across parent re-renders); injection enables test/preview stubs
- ⚠️ Default-arg `= VM()` does NOT compile — `@MainActor` VM init in default arg is "synchronous nonisolated context" error. Use `VM? = nil` + create in init body (init is MainActor-isolated in this module)
- Files: `WeatherView/WeatherForecastView.swift`, `HeaderView/HeaderView.swift`, `Conference/SelectRoomView.swift`

**2. ✅ DONE (09-06) `SelectRoomViewModel` no longer uses `ModelContext` — added `RoomRepository`**
- New `RoomRepository` protocol + `SwiftDataRoomRepository` added in `Conference/ConferenceDatabaseService.swift` (parallel to `ConferenceRepository`): `loadRooms()` / `replaceAll(with: [DatumRoom])` / `clearAll()`
- `SelectRoomViewModel` now depends on `RoomRepository` (injected via `configure(repository:appState:)`); SwiftData import removed from VM
- `SelectRoomView.task` builds `SwiftDataRoomRepository(modelContext:)` from `@Environment(\.modelContext)`
- Files: `Conference/ConferenceDatabaseService.swift`, `Conference/SelectRoomViewModel.swift`, `Conference/SelectRoomView.swift`

**3. ✅ DONE (09-06) `APIConfig.keychain` static singleton removed — injected**
- `APIConfig` is now a struct conforming to new `APICredentialsProviding` protocol (`hostURL` / `currentYlSecretKey` / `currentYlAccessKey` / `usesKeychainKeys`); `KeychainService` injected via `init(keychain:)`
- `YmsApiResponse` now holds `let config: APICredentialsProviding` (`init(config: = APIConfig())`); `signedHeaders`/URL-building are instance methods reading `config` (no more `Self.hostURL` / static `APIConfig.*` calls)
- Unused `baseUrl` static removed (dead code)
- Files: `LocalProperties/APIConfig.swift`, `NetworkLayers/YmsApiResponse.swift`, `Settings/SettingsView.swift` (`private let apiConfig = APIConfig()`)

#### Medium priority (SRP, OCP)

**4. `ConferenceViewModel` (150 lines, 8+ responsibilities)**
- API calls, Timer lifecycle, current meeting logic, busy slots, cache CRUD, demo mode, UI state, room name
- **Fix:** Split into `ConferenceScheduleManager` + `ConferenceState`

**5. `WeatherViewModel` (100 lines, 6+ responsibilities)**
- API fetch, UserDefaults caching, WMO→icon mapping, date formatting, UI state
- **Fix:** Split into `WeatherDataService` + `WeatherIconMapper` + `WeatherDateFormatter`

**6. `SettingsStore` (83 lines, 5+ responsibilities)**
- Pin code storage, city selection, demo mode toggle, pin change, pin verification
- **Fix:** Split into `PinManager`, `CityManager`, `AppSettings`

**7. `YmsApiResponse` (80+ lines)**
- Conference schedule, rooms, generic POST, HMAC-SHA256 signing, MD5, base URL
- **Fix:** Split into `YmsConferenceApi`, `YmsRoomApi`, `YmsRequestSigner`

**8. OCP violations — switch statements in View**
- `ConferenceRoomScreen.swift:106-117` — switch on `MeetingDisplayState`
- `ScheduleView.swift:113-122` — switch on `ScheduleBlockTone`
- **Fix:** Protocol-based computed properties (color, icon, text)

#### Low priority (clean code)

**9. Dead/unused files**
- `Model/ConfModel.swift` — unused struct
- `ScheduleView/ScheduleRow.swift` — unused component
- `ScanSecretKey/TextScannerView.swift` — duplicate of `ScannerView.swift`

**10. Type inconsistency**
- `ConfDataModel.endDateTimeStamp: String` should be `Int` (stores timestamp)

**11. `let vID = UUID()` in `@Model`**
- SwiftData won't track `let` properties; fine for identity but may cause migration issues

**12. Pre-existing warnings**
- `ConfDataModel` accessor macro on `let vID` (Swift 6)
- `UIScreen.main` deprecations in `QRScannerOverlayView`

---

### Extras discovered during Phases 3-5 (optional)
- `YmsApiResponse` signing reads keys via injected `config` — stubbable via `APICredentialsProviding`
- `scanRectSize: CGFloat = 260` duplicated in `QRScannerViewController`/`QRScannerOverlayView` — consider a shared constant
- `ScheduleSlotFormatter.timeSlots()` hardcodes 7:00–20:00/30-min step — could move to constants
- `ConferenceRoomScreen` has unused `@Environment(\.dismiss)` residual — can be removed
- Unit tests still absent — `ConferenceTimeCalculator`/`ScheduleSlotFormatter`/`TimeUtils` are the clean testable core; all deps stubbable (YmsApiService/ConferenceRepository/DataStorage/KeychainService/WeatherServiceProtocol)

---

## Key Files Reference

| File | Status | Notes |
|------|--------|-------|
| `Conference/ConferenceRoomScreen.swift` | ✅ Phases 1-5 | @Query/@ObservedObject removed; display-only View; injected VM via plain `let` |
| `Conference/ConferenceViewModel.swift` | ✅ Phases 1-5 | coordinator-only; `@MainActor @Observable final`; native Timer; demo-mode branch via `settings.isDemoEnabled` |
| `Conference/DemoData.swift` | ✅ NEW demo | synthetic day schedule; guarantees occupied-now |
| `Conference/ConferenceRoomScreen.swift` | ✅ demo | injected `SettingsStore` env; `displayRoomName`; demo-toggle refresh; `MockStorage` for previews |
| `Conference/SelectRoomViewModel.swift` | ✅ Phases 3-5 + Session 2 | `@Observable`; **`RoomRepository` injected via `configure(repository:appState:)` (no direct ModelContext)** |
| `Conference/SelectRoomView.swift` | ✅ Phase 5 | `@State private var viewModel = SelectRoomViewModel()` |
| `Conference/ConferenceDataFetcher.swift` | ✅ NEW Phase 3 | API + cache (SRP) |
| `Conference/ConferenceDatabaseService.swift` | ✅ Phase 3-4 + Session 2 | `ConferenceRepository` protocol + `SwiftDataConferenceRepository`; **+ `RoomRepository` protocol + `SwiftDataRoomRepository` (Session 2)** |
| `Conference/ConferenceTimeCalculator.swift` | ✅ NEW Phase 3 | Pure logic + `MeetingDisplayState`/`MeetingCardInfo` |
| `Header/HeaderViewModel.swift` | ✅ Phases 1,5 | `@Observable`; native `Timer` global-actor-safe via `MainActor.assumeIsolated`; deinit invalidates |
| `Header/HeaderView.swift` | ✅ Phase 5 | `@State private var headerViewModel = HeaderViewModel()` |
| `YealinkMeetingPlannerApp.swift` | ✅ Phases 1,5 | `@State` ownership of `AppState` + `ConferenceViewModel` |
| `WeatherView/WeatherViewModel.swift` | ✅ Phases 2-5 | `@Observable`; `DateFormatters`; `weatherIconName` dict |
| `WeatherView/WeatherForecastView.swift` | ✅ Phases 2-5 | `@State` VM; `LayoutDimensions` |
| `ScanSecretKey/ScanViewModel.swift` | ✅ Phases 3,5 | `@Observable`; `KeychainService` injected; no Combine |
| `ScanSecretKey/ScannerView.swift` | ✅ Phase 5 | `@State` VM + `@Bindable` for text/sheet bindings |
| `Helpers/DataStorage.swift` | ✅ Phases 3,5 | `DataStorage` protocol + `bool(forKey:)`; `UserDefaults` conforms |
| `Helpers/TimeUtils.swift` | ✅ NEW Phase 4 | single `minutes(of:)` source; `ScheduleSlotFormatter` delegates |
| `Helpers/DateFormatters.swift` | ✅ NEW Phase 4 | shared `DateFormatter`s (ruFullDate/timeHM/isoDate/shortWeekdayDay) |
| `Helpers/ModelContext+DeleteAll.swift` | ✅ NEW Phase 4 | generic `deleteAll(of:)` replaces clearXInternal |
| `Helpers/LayoutDimensions.swift` | ✅ NEW Phase 4 | named layout constants (magic numbers removed) |
| `Model/WeatherModel.swift` | ✅ Fix Phase 4 | `longitude`/`elevation` `Int` → `Double` (Open-Meteo fractional coords) |
| `ScanSecretKey/KeychainManager.swift` | ✅ Phase 3 | `KeychainService` protocol + conformance |
| `LocalProperties/APIConfig.swift` | ✅ Session 2 | struct + `APICredentialsProviding` protocol; `KeychainService` injected; statics (incl. unused `baseUrl`) removed |
| `NetworkLayers/YmsApiResponse.swift` | ✅ Session 2 | `let config: APICredentialsProviding`; instance `signedHeaders`/URL-builder |
| `Settings/SettingsStore.swift` | ✅ Phases 3,5,demo | `KeychainService` + `DataStorage` injected; `isDemoEnabled` persisted |
| `Settings/SettingsView.swift` | ✅ demo | «Демо-данные» Toggle in new "Демонстрация" section |
| `AppState.swift` | ✅ Phase 3 | `DataStorage` injected |
| `ScheduleView/ScheduleView.swift` | ✅ Phases 3-4 | `ScheduleBlockTone.color` extension (OCP); uses `DateFormatters.ruFullDate` |
| `ScheduleView/ScheduleSlotFormatter.swift` | ✅ Phases 3-4 | delegates `minutes(of:)` to `TimeUtils` |
| `Model/ConferenceScheduler.swift` | ✅ Phase 4 | renamed from `ConferenceSheduler.swift`; type `ConferenceScheduler` |
| `Model/CodeNDecode.swift` | ✅ Phase 4 | trimmed to `JSONNull` only (unused `JSONAny`/`JSONCodingKey` removed) |
| `ScanSecretKey/QRScannerViewController.swift` | ✅ Fixed | Hosts SwiftUI overlay via UIHostingController; app compiles |

---

## Notes for Next Agent

- The code review document (`code-review-yealink-meeting-planner.md`) has the full detailed analysis with line numbers
- **All ViewModels are now `@Observable`** — no `ObservableObject`/`@Published`/`Combine` anywhere (verified by grep). `@MainActor @Observable final` is the standard for model-context VMs; `ScanViewModel` is plain `@Observable`
- `ConferenceViewModel`/`HeaderViewModel` run a 60s `Timer` scheduled on the main run loop; the timer is stored as `@ObservationIgnored nonisolated(unsafe) private var` so `deinit` (nonisolated in @MainActor classes) can invalidate it. The block calls `MainActor.assumeIsolated { ... }` — keep this pattern if you touch these VMs
- Owned VMs in views use `init(viewModel: X? = nil) { _viewModel = State(initialValue: viewModel ?? X()) }` — keep `??` creation in the init **body**; a default-arg `= X()` fails to compile for `@MainActor` VMs
- `YmsApiResponse` reads credentials via injected `config: APICredentialsProviding` (default `APIConfig()`); `APIConfig` is now an instance, use `APIConfig()` / `APIConfig(keychain: fake)` — never `APIConfig.<static>` (removed)
- Build command: `xcodebuild -project YealinkMeetingPlanner.xcodeproj -scheme YealinkMeetingPlanner -destination 'platform=iOS Simulator,name=iPhone 17' build` — **passes now**
- `scanRectSize: CGFloat = 260` is duplicated in `QRScannerViewController` and `QRScannerOverlayView` — must stay in sync (consider a shared constant later)
- `ConferenceRoomScreen` previews return `AnyView` with `try? ModelContainer` — preserve this pattern in new previews
- New files under `Conference/`, `Helpers/`, etc. are auto-included via `PBXFileSystemSynchronizedRootGroup` — no pbxproj edits needed (folder renamess like `WetherView`→`WeatherView` are just filesystem moves)
- `WeatherData.longitude`/`elevation` must stay `Double` — Open-Meteo returns fractional coordinates (Moscow `37.625`); `Int` caused the «Не удалось разобрать ответ сервера» bug for most cities
- `ConferenceDataFetcher` + `ConferenceDataFetcher`/repository/calculator are all `@MainActor` (ModelContext/@Model constraint); pure `ConferenceTimeCalculator` logic is the testable unit
- `KeychainManager` has an empty `init()` now (was implicit); used by all `?? KeychainManager.shared` defaults
- Russian-language commit messages throughout — code comments may be in Russian too
- No unit tests exist — any refactoring should be verified by building and manual testing
