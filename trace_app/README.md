# TRACE — Mobile App (Flutter / FlutterFlow-compatible)

Ground-level companion to the TRACE transparency dashboard. Feeds data INTO the system.
3 user types: **Citizen**, **Field Auditor**, **Contractor**.

Built in Flutter using FlutterFlow conventions (`lib/flutter_flow/…`, `lib/pages/…`, `lib/app_state.dart`) so the codebase can be opened/edited in FlutterFlow or run directly via the Flutter SDK.

## Run

```bash
cd trace_app
flutter pub get
flutter run
```

### Platform setup needed for physical devices
- Android: add to `android/app/src/main/AndroidManifest.xml`:
  - `android.permission.CAMERA`
  - `android.permission.ACCESS_FINE_LOCATION`
  - `android.permission.ACCESS_COARSE_LOCATION`
  - `android.permission.INTERNET`
- iOS: add to `ios/Runner/Info.plist`:
  - `NSCameraUsageDescription`, `NSLocationWhenInUseUsageDescription`,
    `NSPhotoLibraryUsageDescription`, `NSMicrophoneUsageDescription`.

> Tip: run `flutter create .` inside `trace_app/` once to generate the native
> `android/` and `ios/` folders, then add the permissions above.

## Screens built (PRD §25)
- Splash → Role select → OTP login → Profile setup
- **Citizen**: Home, Report an Issue (photo + GPS + project auto-link), Scheme Status, My Reports
- **Field Auditor**: Home, QR Scan, Inspection form (location fence ±500 m, min 3 photos, checklist, verdict, immutability warning), Inspection detail
- **Contractor**: Home (risk score + alerts), Submit Invoice, Submit Milestone, Payment Tracker (blocked reasons)

## Hackathon rules enforced in code
- Photo is mandatory for citizen reports and auditor inspections.
- GPS is mandatory; auditor + contractor milestone submissions require within 500 m of project.
- Photos for auditor / milestone come from camera only (no gallery).
- Immutability confirmation before any final on-chain submission.
- No PII of other citizens is shown; scheme data is aggregate.

## API wiring
`lib/services/mock_api.dart` exposes the 7 endpoints from the PRD (`postReport`, `postInspection`, `postInvoice`, `postMilestone`, `getSchemes`, `getPayments`, `getRiskScore`). Replace the stub bodies with real HTTP calls to Person A's backend.

## Roadmap (not built, per PRD §147)
OCR invoices · offline queue sync · voice notes · in-app PDF export · push notifications.

## Structure
```
lib/
  main.dart                  # GoRouter + theme bootstrap
  app_state.dart             # role, profile, auth flag (Provider)
  flutter_flow/
    flutter_flow_theme.dart  # FF-style theme helpers
  models/models.dart
  services/mock_api.dart
  widgets/common.dart        # PrimaryButton, SectionCard, StatusPill, ImmutabilityDialog…
  pages/
    onboarding/              # splash, role_select, otp, profile_setup
    citizen/                 # home, report, schemes, my_reports
    auditor/                 # home, qr_scan, inspection_form, inspection_detail
    contractor/              # home, submit_invoice, submit_milestone, payment_tracker
```
