# Handoff — YMS_InfoConference / YealinkMeetingPlanner

**Created:** 2026-09-05
**Updated:** 2026-09-06 (Session 6: demo «ЗАНЯТОСТЬ» filled 07:00–10:00. ✅ 37 tests pass)
**Status:** 🟢 All phases 1-5 + Sessions 2-6 done. ✅ App compiles, unit tests green (37/37)

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
- ✅ **Session 4 (Clean Code / remaining review items 9-12)**:
  - 4.a Dead files removed: `Model/ConfModel.swift` (unused struct), `ScheduleView/ScheduleRow.swift` (unused component). `ScanSecretKey/TextScannerView.swift` **kept** — its `QRScannerView` is used by `ScannerView.swift:53` (earlier review note was wrong)
  - 4.b Type-inconsistency fix in `ConfDataModel`: removed write-only `endDateTimeStamp: String` field + init param (only ever written, never read). Instead of a `String`→`Int` change (incompatible SwiftData schema migration → crash on existing stores), the unused attribute was **removed** (attribute removal IS lightweight-migratable). Call sites updated: `ConferenceDatabaseService.repalceAll` (dropped `endDateTimeStamp:`), `DemoData.makeConference` (dropped `endDateTimeStamp: ""`)
  - 4.c `let vID = UUID()` → `var vID = UUID()` in `ConfDataModel` — fixes @Model accessor-macro warning (Swift 6 fatal error). `DatumRoom.vID` (plain Codable struct) left as `let`
  - 4.d `QRScannerOverlayView` rewritten: `UIScreen.main` → `GeometryReader`; `@State scanRectGuide` removed; frame derived from `LayoutDimensions.scannerScanRectSize`
  - 4.e Shared constant: `LayoutDimensions.scannerScanRectSize = 260` — replaces the duplicated `scanRectSize` in `QRScannerViewController` and `QRScannerOverlayView`
  - 4.f Doc-comments added: `NetError` enum, `YmsRequestSigner.headers(method:path:bodyData:)`, `YmsHTTPClient.post<Body:Response>(path:body:)`
  - Verified: `BUILD SUCCEEDED`, **no remaining code warnings** (previously only pre-existing `let vID` accessor macro + `UIScreen.main` deprecations — both eliminated; only benign appintents "Metadata extraction skipped" notice remains)
- ✅ **Phase 5 complete** (Modernize patterns):
  - 5.1 All ViewModels migrated `ObservableObject`/`@Published`/Combine → `@Observable` (`@MainActor @Observable final` for MainActor ones): `ConferenceViewModel`, `HeaderViewModel`, `WeatherViewModel`, `SelectRoomViewModel`, `ScanViewModel`
  - Timers in `ConferenceViewModel`/`HeaderViewModel` moved from Combine `Timer.publish` to native `Timer.scheduledTimer` with `MainActor.assumeIsolated` + `[weak self]`; invalidation in `deinit` via `@ObservationIgnored nonisolated(unsafe)` stored timer (deinit is nonisolated in a @MainActor class)
  - View wiring: `@StateObject`/`@ObservedObject` → `@State` for owned VMs (`HeaderView`, `WeatherForecastView`, `SelectRoomView`, `KeysScannerView`) and plain `let` for injected `ConferenceRoomScreen.viewModel`; `YealinkMeetingPlannerApp` `@StateObject` → `@State`; `KeysScannerView` uses `@Bindable` for `$text1/$text2/$isScannerPresented` bindings
  - Precision fix: `SelectRoomViewModel` needed explicit `import Foundation` after dropping `import SwiftUI` (`SortDescriptor`, `localizedDescription`); `WeatherViewModel`/`SelectRoomViewModel`/`ScanViewModel` now `import Observation`
  - 5.2 Doc-comments added: protocols `YmsApiService`, `ConferenceRepository`, `DataStorage`, `KeychainService`, `WeatherServiceProtocol`; public VM methods (`ScanViewModel` openScanner/handleScannedText/saveData/deleteData, `SelectRoomViewModel.fetchAndSaveRooms`, `ConferenceViewModel.loadCachedData`/`clearData`, `WeatherViewModel.weatherIconName`, `HeaderViewModel.dateString`/`timeString`)
  - Verified: `BUILD SUCCEEDED`, no new warnings (pre-existing warnings only). No `ObservableObject`/`@Published`/`@StateObject`/`@ObservedObject`/`import Combine` remain in the codebase
- ✅ **Session 5 (unit tests)**:
  - New target `YealinkMeetingPlannerTests` (`com.apple.product-type.bundle.unit-test`, hosted in app via `TEST_HOST`) added to pbxproj manually (objectVersion 77, `PBXFileSystemSynchronizedRootGroup` path `YealinkMeetingPlannerTests`); new files auto-included just like the app source
  - Shared scheme `YealinkMeetingPlanner.xcscheme` created (xcshareddata) with TestAction → both `xcodebuild build` and `xcodebuild test -scheme YealinkMeetingPlanner` work
  - 37 tests across 6 suites: `TimeUtils`, `WeatherIconMapper`, `ScheduleSlotFormatter`, `ConferenceTimeCalculator`, `DemoData`, `YmsRequestSigner` (headers incl. real MD5/SHA256 checks, no network)
  - Test target sets `SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated`; test classes are `@MainActor` (app module defaults everything to MainActor). Helper `TestTime` (fixed Moscow-time calendar) in `YealinkMeetingPlannerTests/TestHelpers.swift`
  - Verified: `** TEST SUCCEEDED **`, 37/37 passed
- ✅ **Demo mode (feature)**: toggle in Settings → `Conference/DemoData.swift`
  - `SettingsStore.isDemoEnabled` (persisted via `storage.bool/forKey`; added `bool(forKey:)` to `DataStorage` protocol)
  - `SettingsView` gets a «Демо-данные» Toggle section at the top ("Демонстрация")
  - `Conference/DemoData.swift` — pure generator: first meeting at 07:00, then 90-min meetings (adjacent in the morning, 30-min breaks afternoon) up to 20:00; guarantees the room is currently occupied; room name «Демо-конференц-зал» via `ConferenceViewModel.displayRoomName`
  - `ConferenceViewModel` branches on `isDemoEnabled` in `loadSchedule`/`refreshSchedule`/`loadCachedData`/`currentMeetingDisplay` — in demo it serves `DemoData.conferences()` instead of API and skips real-room/no-room states
  - `ConferenceRoomScreen` re-runs `loadSchedule` on `settings.isDemoEnabled` change; preview injects `SettingsStore` + `MockStorage` (test seam). Added `MockStorage` (in-memory `DataStorage`) for previews/tests
  - Verified: `BUILD SUCCEEDED`, no new warnings; logic tested for 07:00–19:30 → always `occupiedNow=true`
- ✅ **Session 6 (demo «ЗАНЯТОСТЬ»: первая встреча в 07:00)**:
  - Iterative: (1) morning looked empty 07:00–10:00 → made back-to-back from 07:00; (2) user wanted 07:00–10:00 «свободно» → morning loop start moved to 10:00; (3) **final**: user asked to fix the first meeting start to 07:00 → morning loop start is `dayStart` again (`var time = dayStart`, adjacent 90-min meetings up to the current meeting; afternoon keeps 30-min breaks)
  - ⚠️ Note: at some point the file contained `var time = 70 * 60` (dead code — loop never ran); replaced with `dayStart`
  - Test `testFirstMeetingStartsAtSeven` (renamed from `testSevenToTenIsAlwaysFree`): earliest meeting start == 07:00 and 07:00–08:00 busy for demo starts 07:00/09:45/12:00/15:00
  - Verified: `** TEST SUCCEEDED **`, **37/37 passed**

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

**4. ✅ DONE (09-06) `ConferenceViewModel` split — `ConferenceScheduleStore` + thin VM**
- NEW `Conference/ConferenceScheduleStore.swift` (@MainActor @Observable): owns `confDataItems`/`isLoading`/`errorMessage`, fetcher, timer, demo-mode branching, cache CRUD, `roomId`, `displayRoomName`, lifecycle `start()/loadSchedule()/loadCachedData()/clearData()`
- `ConferenceViewModel` is now presentation-only: forwards lifecycle + data state to store; holds `appState`+`settings` for `currentMeetingDisplay`; `busySlots` via `ConferenceTimeCalculator`
- Public surface unchanged (App/`ConferenceRoomScreen` untouched): `init(appState:modelContext:api:settings:repository:)`, `roomId`, `displayRoomName`, `currentMeetingDisplay`, `busySlots`, `start()`, `loadSchedule()`
- ⚠️ Observation caveat: VM's computed props forward to store — view re-renders because body reads tracked `scheduleStore.confDataItems` transitively. Verified by build; manual verification advised

**5. ✅ DONE (09-06) `WeatherViewModel` split — `WeatherCache` + `WeatherIconMapper`**
- NEW `WeatherView/WeatherCache.swift` — UserDefaults per-city cache (load/save/isCacheValid) extracted from VM
- NEW `WeatherView/WeatherIconMapper.swift` — WMO code → SF Symbol dict (`static func name(for:)`), replaces `WeatherViewModel.weatherIconName` (static removed)
- VM keeps `fetchWeather()` + `formatDate` (delegates to shared `DateFormatters`; no separate `WeatherDateFormatter` created — would be ceremony over existing `DateFormatters`). `WeatherServiceProtocol` already isolated networking
- `WeatherForecastView` now calls `WeatherIconMapper.name(for:)`

**6. ✅ DONE (09-06) `SettingsStore` split — `PinManager` extracted**
- NEW `Settings/PinManager.swift` — Keychain pin storage/change/check (was `settings_access_pin` + logic in SettingsStore)
- `SettingsStore` keeps `selectedCity`/`isDemoEnabled` + delegates `changePin(to:)`/`checkPin(_:)` to `PinManager`; public surface & call sites unchanged

**7. ✅ DONE (09-06) `YmsApiResponse` split**
- NEW `NetworkLayers/YmsApiClient.swift`: `YmsRequestSigner` (HMAC-SHA256 headers), `YmsHTTPClient` (single POST/URL/decode/error path), `YmsConferenceApi`, `YmsRoomApi`
- `YmsApiResponse.swift` → thin `YmsApiService` facade: protocol + request bodies (`ConferenceScheduleRequest`/`RoomListRequest`) + facade composing `YmsConferenceApi`/`YmsRoomApi`; `init(config:)` preserved
- Signing/URL-building replaced static `Self.hostURL` entirely

**8. ✅ DONE (09-06) OCP — no more switch over states in View**
- `MeetingDisplayState` now exposes computed `title`/`time`/`contactName`/`contactPhone`/`roomStatus` (view just reads them); `RoomStatus` enum moved from `CurrentMeetingView.swift` into `ConferenceTimeCalculator.swift` (model layer)
- `ConferenceRoomScreen.currentMeetingView` switch deleted
- `ScheduleBlockTone.color` extension moved from `ScheduleView.swift` to NEW `ScheduleView/ScheduleBlockTone+Color.swift`

#### Previously "Low priority (clean code)" — ✅ all resolved (Session 4)

**9. Dead/unused files** — ✅
- `Model/ConfModel.swift` — **deleted** (Session 4)
- `ScheduleView/ScheduleRow.swift` — **deleted** (Session 4)
- `ScanSecretKey/TextScannerView.swift` — **kept**: `QRScannerView` (UIViewControllerRepresentable) is used by `ScannerView.swift:53` (the «duplicate» note was wrong)

**10. Type inconsistency** — ✅ resolved
- `ConfDataModel.endDateTimeStamp: String` — removed (write-only; attribute removal is lightweight-migratable, unlike `String`→`Int` type change which would crash existing stores). Decode model `ConferenceTime.endDateTimeStamp: Double` retained

**11. `let vID = UUID()` in `@Model`** — ✅
- `ConfDataModel.vID`: `let` → `var` (accessor-macro warning / Swift 6 fatal). `DatumRoom.vID` (plain Codable struct) left as `let` — no macro

**12. Pre-existing warnings** — ✅ both gone (BUILD SUCCEEDED)
- `ConfDataModel` accessor macro on `let vID` (fixed by 4.c)
- `UIScreen.main` deprecations in `QRScannerOverlayView` (fixed by 4.d: `GeometryReader`)

---

### Extras discovered during Phases 3-5 (optional)
- `YmsApiResponse` signing reads keys via injected `config` — stubbable via `APICredentialsProviding`
- ~~`scanRectSize: CGFloat = 260` duplicated~~ — ✅ resolved: `LayoutDimensions.scannerScanRectSize` (Session 4)
- `ScheduleSlotFormatter.timeSlots()` hardcodes 7:00–20:00/30-min step — could move to constants
- `ConferenceRoomScreen` has unused `@Environment(\.dismiss)` residual — can be removed
- ~~Unit tests still absent~~ — ✅ added (Session 5) + extended (Session 6): target `YealinkMeetingPlannerTests`, 37 tests, all green. Pure core covered: `ConferenceTimeCalculator`/`ScheduleSlotFormatter`/`TimeUtils`/`WeatherIconMapper`/`DemoData`/`YmsRequestSigner`. Deps remain stubbable for VM-level tests (YmsApiService/ConferenceRepository/RoomRepository/DataStorage/KeychainService/WeatherServiceProtocol/APICredentialsProviding)

---

## Key Files Reference

| File | Status | Notes |
|------|--------|-------|
| `Conference/ConferenceRoomScreen.swift` | ✅ Sessions 1-5,3 | no switch over state; reads `state.title/time/contactName/contactPhone/roomStatus` |
| `Conference/ConferenceViewModel.swift` | ✅ Session 3 | thin presentation VM; forwards to `ConferenceScheduleStore`; `currentMeetingDisplay`+`busySlots` |
| `Conference/ConferenceScheduleStore.swift` | ✅ NEW Session 3 | schedule data + cache + timer + demo + `roomId`/`displayRoomName` |
| `Conference/DemoData.swift` | ✅ Session 6 | synthetic day schedule; first meeting 07:00, morning adjacent, afternoon 30-min breaks; guarantees occupied-now |
| `Conference/ConferenceRoomScreen.swift` | ✅ demo | injected `SettingsStore` env; `displayRoomName`; demo-toggle refresh; `MockStorage` for previews |
| `Conference/SelectRoomViewModel.swift` | ✅ Phases 3-5 + Session 2 | `@Observable`; **`RoomRepository` injected via `configure(repository:appState:)` (no direct ModelContext)** |
| `Conference/SelectRoomView.swift` | ✅ Phase 5 | `@State private var viewModel = SelectRoomViewModel()` |
| `Conference/ConferenceDataFetcher.swift` | ✅ NEW Phase 3 | API + cache (SRP) |
| `Conference/ConferenceDatabaseService.swift` | ✅ Phase 3-4 + Session 2 | `ConferenceRepository` protocol + `SwiftDataConferenceRepository`; **+ `RoomRepository` protocol + `SwiftDataRoomRepository` (Session 2)** |
| `Conference/ConferenceTimeCalculator.swift` | ✅ NEW Phase 3 + Session 3 | Pure logic + `MeetingDisplayState` display props (OCP) + `RoomStatus` moved here |
| `Conference/ConferenceViewModel.swift` | ✅ Session 3 | thin presentation VM; forwards to `ConferenceScheduleStore` |
| `Conference/ConferenceScheduleStore.swift` | ✅ NEW Session 3 | schedule data + cache + timer + demo + `roomId`/`displayRoomName` |
| `Header/HeaderViewModel.swift` | ✅ Phases 1,5 | `@Observable`; native `Timer` global-actor-safe via `MainActor.assumeIsolated`; deinit invalidates |
| `Header/HeaderView.swift` | ✅ Phase 5 | `@State private var headerViewModel = HeaderViewModel()` |
| `YealinkMeetingPlannerApp.swift` | ✅ Phases 1,5 | `@State` ownership of `AppState` + `ConferenceViewModel` |
| `WeatherView/WeatherViewModel.swift` | ✅ Session 3 | `@Observable`; `fetchWeather`+`formatDate`; uses `WeatherCache`; icon mapping removed |
| `WeatherView/WeatherForecastView.swift` | ✅ Session 3 | `@State` VM; `WeatherIconMapper.name(for:)`; `LayoutDimensions` |
| `WeatherView/WeatherCache.swift` | ✅ NEW Session 3 | per-city UserDefaults cache (SRP) |
| `WeatherView/WeatherIconMapper.swift` | ✅ NEW Session 3 | WMO → SF Symbol dict (OCP); replaces static `weatherIconName` |
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
| `NetworkLayers/YmsApiResponse.swift` | ✅ Session 3 | thin `YmsApiService` facade: protocol + request bodies + facade over `YmsConferenceApi`/`YmsRoomApi` |
| `NetworkLayers/YmsApiClient.swift` | ✅ NEW Session 3 | `YmsRequestSigner` + `YmsHTTPClient` + `YmsConferenceApi` + `YmsRoomApi` |
| `Settings/SettingsStore.swift` | ✅ Session 3 | `PinManager` delegate; `selectedCity`/`isDemoEnabled` persisted |
| `Settings/PinManager.swift` | ✅ NEW Session 3 | Keychain pin change/check (SRP) |
| `Settings/SettingsView.swift` | ✅ demo | «Демо-данные» Toggle in new "Демонстрация" section |
| `AppState.swift` | ✅ Phase 3 | `DataStorage` injected |
| `ScheduleView/ScheduleView.swift` | ✅ Phases 3-4 + Session 3 | uses `DateFormatters.ruFullDate`; `color` extension moved out |
| `ScheduleView/ScheduleBlockTone+Color.swift` | ✅ NEW Session 3 | `ScheduleBlockTone.color` extension (OCP) |
| `ScheduleView/ScheduleSlotFormatter.swift` | ✅ Phases 3-4 | delegates `minutes(of:)` to `TimeUtils` |
| `Model/ConferenceScheduler.swift` | ✅ Phase 4 | renamed from `ConferenceSheduler.swift`; type `ConferenceScheduler` |
| `Model/CodeNDecode.swift` | ✅ Phase 4 | trimmed to `JSONNull` only (unused `JSONAny`/`JSONCodingKey` removed) |
| `ScanSecretKey/QRScannerViewController.swift` | ✅ Fixed + Session 4 | Hosts SwiftUI overlay via UIHostingController; `scanRectSize` uses `LayoutDimensions.scannerScanRectSize` |

| `Model/SwiftData/ConfDataModel.swift` | ✅ Session 4 | `endDateTimeStamp` removed (write-only); `vID` `var`; formatted init |
| `ScanSecretKey/QRScannerOverlayView.swift` | ✅ Session 4 | `GeometryReader` instead of `UIScreen.main`; no `@State scanRectGuide` |
| `Helpers/LayoutDimensions.swift` | ✅ Phase 4 + Session 4 | `scannerScanRectSize` added |
| ~~`Model/ConfModel.swift`~~ | ✅ deleted Session 4 | unused struct |
| ~~`ScheduleView/ScheduleRow.swift`~~ | ✅ deleted Session 4 | unused component |

| `YealinkMeetingPlannerTests/` (7 файлов) | ✅ NEW Session 5, +1 Session 6 | Test-target sources: TimeUtils, WeatherIconMapper, ScheduleSlotFormatter, ConferenceTimeCalculator, DemoData (incl. `testSevenToTenIsAlwaysBusy`), YmsRequestSigner + `TestHelpers.swift` (TestTime) |
| `YealinkMeetingPlannerTests` target | ✅ NEW Session 5 | unit-test bundle, hosted via TEST_HOST, `PBXFileSystemSynchronizedRootGroup` |
| `YealinkMeetingPlanner.xcscheme` | ✅ NEW Session 5 | shared scheme w/ TestAction (build + test work) |

---

## Notes for Next Agent

- The code review document (`code-review-yealink-meeting-planner.md`) has the full detailed analysis with line numbers
- **All ViewModels are now `@Observable`** — no `ObservableObject`/`@Published`/`Combine` anywhere (verified by grep). `@MainActor @Observable final` is the standard for model-context VMs; `ScanViewModel` is plain `@Observable`
- Owned VMs in views use `init(viewModel: X? = nil) { _viewModel = State(initialValue: viewModel ?? X()) }` — keep `??` creation in the init **body**; a default-arg `= X()` fails to compile for `@MainActor` VMs
- `ConferenceScheduleStore`/`HeaderViewModel` run a 60s `Timer` scheduled on the main run loop; the timer is stored as `@ObservationIgnored nonisolated(unsafe) private var` so `deinit` (nonisolated in @MainActor classes) can invalidate it. The block calls `MainActor.assumeIsolated { ... }` — keep this pattern if you touch them
- `ConferenceViewModel` forwards data state to `ConferenceScheduleStore` via computed props — Observation is transitive (body reads tracked `store.confDataItems`), so views still re-render on data change
- `YmsApiResponse` is now a thin facade; networking lives in `YmsApiClient.swift` (`YmsRequestSigner`/`YmsHTTPClient`/`YmsConferenceApi`/`YmsRoomApi`). Credentials via injected `config: APICredentialsProviding` (default `APIConfig()`)
- Build command: `xcodebuild -project YealinkMeetingPlanner.xcodeproj -scheme YealinkMeetingPlanner -destination 'platform=iOS Simulator,name=iPhone 17' build` — **passes now**
- `scanRectSize` is unified via `LayoutDimensions.scannerScanRectSize` (used by both `QRScannerViewController` and `QRScannerOverlayView`)
- **Schema note (Session 4):** `ConfDataModel.endDateTimeStamp` attribute was **removed**. SwiftData lightweight migration handles attribute removal; change only additive/deletive, never a type change (`String`→`Int` would crash existing stores). `ConfDataModel.vID` is now `var`
- `ConferenceRoomScreen` previews return `AnyView` with `try? ModelContainer` — preserve this pattern in new previews
- New files under `Conference/`, `Helpers/`, etc. are auto-included via `PBXFileSystemSynchronizedRootGroup` — no pbxproj edits needed (folder renamess like `WetherView`→`WeatherView` are just filesystem moves)
- `WeatherData.longitude`/`elevation` must stay `Double` — Open-Meteo returns fractional coordinates (Moscow `37.625`); `Int` caused the «Не удалось разобрать ответ сервера» bug for most cities
- `ConferenceDataFetcher` + `ConferenceDataFetcher`/repository/calculator are all `@MainActor` (ModelContext/@Model constraint); pure `ConferenceTimeCalculator` logic is the testable unit
- `KeychainManager` has an empty `init()` now (was implicit); used by all `?? KeychainManager.shared` defaults
- Russian-language commit messages throughout — code comments may be in Russian too
- **Unit tests (Session 5+6):** run `xcodebuild test -project YealinkMeetingPlanner.xcodeproj -scheme YealinkMeetingPlanner -destination 'platform=iOS Simulator,name=iPhone 17'` (shared scheme now includes TestAction). Test target is hosted in the app (`TEST_HOST`); a running simulator with the app is required. Tests are `@MainActor` because the app module is built with `-default-isolation=MainActor`; the tests target itself is `nonisolated`. New test files in `YealinkMeetingPlannerTests/` are auto-included via `PBXFileSystemSynchronizedRootGroup`
- **Demo schedule (Session 6):** `DemoData.conferences` — first meeting at 07:00; morning meetings adjacent (90 min each) up to the current meeting; afternoon keeps 30-min breaks. Current meeting always covers "now". Test `testFirstMeetingStartsAtSeven` verifies earliest start == 07:00 and 07:00–08:00 busy
