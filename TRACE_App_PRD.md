# TRACE — Mobile App PRD
**Version:** 1.0 | **Hackathon Build** | **Platform:** React Native (Android + iOS)

---

## What This App Is

The web dashboard is for admins, auditors, and RBI to monitor everything from the top.  
The mobile app is for the ground level — citizens reporting problems, field auditors verifying work, and contractors submitting proof.

The app feeds data INTO the system. The dashboard displays it.

---

## Who Uses It — 3 User Types

| User | What they do |
|---|---|
| **Citizen** | Report bad roads, suspicious projects, check scheme status in their area |
| **Field Auditor** | Scan project QR code on-site, submit inspection report with photo + GPS |
| **Contractor** | Upload material invoices, submit milestone completion proof, check payment status |

---

## Screens to Build

### Onboarding
- Splash screen with TRACE logo
- Role selection: Citizen / Field Auditor / Contractor
- OTP-based login (phone number only — no passwords)
- One-time profile setup (name, district, Aadhaar last 4 for auditors/contractors)

---

### Citizen Flow

**Home Screen**
- District name at top
- "Report an Issue" — big primary button
- "Active Projects Near Me" — list of 3-5 nearby registered projects
- "Scheme Status" — quick view of schemes active in their district (allocated vs returned amount)
- Alert banner if any project in their district is flagged 🔴

**Report an Issue Screen**
- Category picker: Road Quality / Ghost Project / Suspicious Activity / Other
- Photo upload — mandatory, camera opens directly
- GPS auto-captured — user sees their location on a small map
- Text description — optional, 200 char limit
- Project linkage — if they're near a registered project, it auto-suggests linking
- Submit button → confirmation screen with report ID

**Scheme Status Screen**
- List of active government schemes in their district
- Each scheme shows: Allocated ₹X crore | Returned ₹Y crore | Status (green / yellow / red)
- Tap any scheme → see beneficiary count, timeline, district rank

**My Reports Screen**
- History of all reports submitted
- Status tag on each: Received / Under Review / Acted Upon

---

### Field Auditor Flow

**Home Screen**
- Assigned inspections list — project name, location, due date
- "Scan Project QR" — big button, opens camera immediately
- Inspection history

**QR Scan + Inspection Screen**
- Scan QR code posted at project site → pulls up that contract on-chain
- Shows: Project name, contractor, specs, milestone being verified
- Inspection form:
  - GPS auto-captured (cannot be faked — location must match project coordinates ±500m)
  - Photo upload — minimum 3 photos required
  - Checklist: spec items pulled from the smart contract (road width, thickness, etc.)
  - Each checklist item: Pass / Fail / Partial
  - Voice note option — for additional observations
  - Overall verdict: Approved / Rejected / Needs Re-inspection
- Submit → data written to blockchain immediately
- **Cannot edit after submission** — show clear warning before final submit

**Inspection Detail Screen**
- View any past inspection
- Shows all photos, checklist results, GPS stamp, timestamp
- Download as PDF (for court use)

---

### Contractor Flow

**Home Screen**
- Active contracts list
- Payment status per milestone: Released / Pending / Blocked (with reason)
- Risk score for their account — colour coded (green/yellow/red)
- Alert if any payment is frozen + reason shown

**Submit Invoice Screen**
- Select which contract and material
- Upload GST invoice photo
- System auto-reads invoice amount (OCR — or manual entry fallback)
- Invoice gets linked to that contract on-chain
- Confirmation with invoice ID

**Submit Milestone Completion Screen**
- Select milestone (1 of 4)
- Upload completion photos — minimum 5
- GPS must match project location
- Upload any supporting documents (completion certificate, etc.)
- Submit → triggers the 3-layer verification on dashboard side

**Payment Tracker Screen**
- Full payment history per contract
- Milestone breakdown: amount, expected release date, actual release date, status
- If blocked — shows which verification layer failed and what to do

---

## Key Technical Rules

**GPS is mandatory** for citizen reports and field auditor inspections. App should refuse submission if location is off.

**Photos cannot be uploaded from gallery** for field auditors — must be taken in-app in real time. Prevents using old photos.

**Offline mode** — field auditors often have no signal on-site. App must queue submissions and sync when connection returns. Show "queued" status clearly.

**Immutability warning** — before any final submission (especially auditor inspections), show a clear screen: "This cannot be edited after submission. It will be recorded permanently."

**No personal data shown** to citizens about other citizens. Scheme data is aggregate only.

---

## What Connects to the Backend

| App Action | API Endpoint |
|---|---|
| Citizen submits report | `POST /api/report` |
| Auditor submits inspection | `POST /api/inspection` |
| Contractor uploads invoice | `POST /api/invoice` |
| Contractor submits milestone | `POST /api/milestone` |
| Citizen views scheme status | `GET /api/schemes/:districtId` |
| Contractor views payment status | `GET /api/payments/:contractId` |
| Contractor views risk score | `GET /api/risk-score/:contractorId` |

---

## What to Build for Hackathon vs What's Roadmap

### Build now (must be in demo)
- Citizen report screen — photo + GPS + submit
- Field auditor QR scan + inspection form
- Contractor payment status screen
- OTP login with role selection

### Describe as roadmap (don't build)
- OCR on invoices
- Offline queue sync
- Voice notes
- PDF export from app
- Push notifications

---

## Demo Script for the App (Person C owns this)

1. Open app → select Citizen → login
2. Tap "Report an Issue" → take photo of bad road → GPS auto-fills → submit
3. Switch to dashboard — show the citizen report appearing linked to the Jhansi contract
4. Open app → switch to Field Auditor → scan QR → fill checklist → 2 items fail → submit
5. Switch to dashboard — show the failed inspection triggered a payment freeze
6. Open app → switch to Contractor → show payment blocked with reason

Total app screen time in demo: under 90 seconds. Clean, fast, devastating.

---

## Person-wise Ownership

| Person | App responsibility |
|---|---|
| **Person B** | Build all screens in React Native, wire to Person A's API |
| **Person A** | Expose the 7 API endpoints listed above |
| **Person C** | Test all 3 user flows end to end, run the demo script 10 times minimum |
| **Person D** | Add app screenshots to pitch deck, include app in the demo narrative |
