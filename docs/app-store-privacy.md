# App Privacy Draft

This file is a working draft for the App Store Connect privacy questionnaire. It is separate from `PrivacyInfo.xcprivacy`.

## Current Product Behavior

- The current iPhone build stores countdowns locally on device.
- The app schedules local notifications when the user enables reminders.
- The app does not require an account.
- The app does not currently send analytics, ads, or third-party tracking data.
- Email and SMS provider wiring is not active in the current build.

## Proposed App Store Connect Answers

### Data Used to Track You

- None

### Data Linked to the User

- None in the current build

### Data Not Linked to the User

- None in the current build

## Permissions and Disclosures

- Notifications: explain that reminders are used to surface approaching deadlines and task urgency.

## Re-check Before Submission

- If analytics, crash reporting, email delivery, or SMS delivery is added, update this document and the App Store Connect answers before submitting a new build.
