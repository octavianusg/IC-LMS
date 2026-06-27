# IC‑LMS — Manual Setup & On‑Device Checklist

This app was built in a Linux container with no Xcode toolchain, so nothing here
has been compiled or run. Everything below is what **you** must configure in
Xcode and verify on a real iPad/Mac before the app is functional in **live**
mode. The app runs fully in **mock** mode (debug builds) with none of this.

---

## 1. Xcode project settings

- [ ] Open `IC-LMS.xcodeproj` in **Xcode 16+** and let it resolve the
      synchronized file groups (all files under `IC-LMS/` are auto‑included).
- [ ] **Deployment target: iOS/iPadOS 26 (and macOS 26 if targeting Mac).**
      The design system uses the Liquid Glass API (`.glassEffect`). On a lower
      target those calls won't compile — either raise the target or replace
      `glassEffect` with `.background(.ultraThinMaterial)` in
      `DesignSystem/Components/*` and `App/DebugDataModeSwitch.swift` /
      `App/RootView.swift`.
- [ ] **Swift Language Version: Swift 5** (recommended). The app uses the
      standard `@State private var model = @MainActor AppEnvironment.makeDefault()`
      pattern; Swift 6 strict concurrency may surface isolation warnings to clean
      up first.
- [ ] Set your **Team** and a unique **Bundle Identifier**.

## 2. Signing & Capabilities (required for LIVE mode only)

- [ ] **iCloud** capability → check **CloudKit**.
- [ ] Create/select an **iCloud container**, e.g. `iCloud.<your-bundle-id>`.
- [ ] **Background Modes** → enable **Remote notifications** (for CloudKit
      sharing + change notifications).
- [ ] **Push Notifications** capability (CloudKit subscriptions/sharing).
- [ ] Confirm the generated `IC-LMS.entitlements` includes the iCloud container
      and `aps-environment`.

> Mock mode touches none of this. The code constructs CloudKit lazily, so a
> debug build with no iCloud capability still launches and runs on seeded data.

## 3. CloudKit schema (CloudKit Dashboard)

The app writes these record types (created automatically on first save in the
**Development** environment). Field names come from the model `toRecord()`
methods:

- [ ] **Challenge** — `title` (String), `summary` (String),
      `phasesData` (Bytes), `participantsData` (Bytes), `ownerName` (String),
      `createdAt` (Date/Time), `updatedAt` (Date/Time).
- [ ] **CheckpointAssessment** — `challengeID`, `checkpointID`,
      `participantID`, `skillID` (Strings), `evidenceData` (Bytes),
      `finalRatingLevel` (Int64), `createdAt`, `updatedAt`.
- [ ] **Submission** — `challengeID`, `assignmentID`, `studentName` (Strings),
      `note` (String), `imageData` (Bytes, optional), `createdAt`.
- [ ] **Add a Queryable index on `recordName`** for each type so the
      list/fetch queries (`NSPredicate(value: true)`) succeed — otherwise
      `fetchAll` returns a CloudKit error.
- [ ] When ready for release, **Deploy Schema to Production**.

## 4. Known code gaps to address before relying on LIVE features

- [ ] **CKShare requires a custom record zone.** `CloudKitManager` /
      `CloudKitSharingManager` currently use the **default** private zone, which
      does not support sharing. To make `CKShare` actually work, save shareable
      `Challenge` records into a custom `CKRecordZone` and share from there.
      (Sharing UI and accept-handling are wired; the zone is the missing piece.)
- [ ] **Photos are stored as `Data` in records.** Evidence/Submission images go
      into record `Bytes` fields, which hit CloudKit's ~1 MB record limit fast.
      Move image payloads to **`CKAsset`** for production.
- [ ] **Optimistic local updates** in `ChallengeEditorViewModel.addItem` and
      `AssessmentViewModel` mutate state before the save completes; on a genuine
      (non-offline) save failure the UI keeps the item but it isn't persisted.
      Add rollback if this matters.

## 5. Info.plist

- [ ] No usage string is required for the photo **picker** (`PhotosPicker` runs
      out of process).
- [ ] If you add **camera** capture later, add `NSCameraUsageDescription`.

---

## 6. On‑device verification checklist

### Mock mode (debug build, no iCloud needed)
- [ ] App launches into seeded challenges ("Clean Water…", "Design a Community Market").
- [ ] Floating **ladybug** control (bottom‑right) expands; toggle flips
      Mock ↔ Live; it is draggable and stays where dropped.
- [ ] **Authoring:** create a challenge; add content, an assignment, and a
      checkpoint (pick a skill) into different phases; add/remove students.
- [ ] **Run mode:** tap **Run**; step through items with progress; open a
      checkpoint → pick a student → assessment.
- [ ] **Assessment:** capture a **photo + note**, a **blank Pencil note**, an
      **annotated photo** (Apple Pencil), and a **student upload**; assign a
      final rating; reopen and confirm evidence + rating persisted.
- [ ] **Student:** long‑press a challenge card → **Open as student**; enter a
      name; submit work for an assignment; checkpoints are hidden from students.

### Live mode (real device + iCloud)
- [ ] Sign in to iCloud on the device; flip the switch to **Live**.
- [ ] Create/edit a challenge; force‑quit and relaunch → data restored (cache),
      then syncs from CloudKit.
- [ ] Verify the same data appears on a **second device** with the same Apple ID.
- [ ] **Account banner:** sign out of iCloud → non‑blocking banner appears, app
      still usable; edits persist locally and sync after signing back in.
- [ ] **Offline:** enable Airplane Mode → edits still save (cache), banner shows
      offline; reconnect → changes sync.
- [ ] **Sharing:** tap **Share** on a challenge → invite via the system sheet →
      accept on a second device/Apple ID → the shared challenge opens in the
      student view. *(Requires the custom‑zone fix in §4.)*

### Pencil & hardware
- [ ] Apple Pencil drawing feels natural on the handwriting canvas (PencilKit).
- [ ] Annotate‑on‑photo overlays the drawing on the captured image in summary cards.

---

## 7. Running the tests

```
xcodebuild test -scheme IC-LMS \
  -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M4)'
```

Suites cover the view models (authoring, assessment, run, student), the mock
data source, the Core Data cache manager, and the sharing/account wiring. They
use protocol mocks and an in‑memory store — no iCloud required.
