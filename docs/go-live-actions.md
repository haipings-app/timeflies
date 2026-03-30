# Timeflies Go-Live Actions

This is the shortest practical path to publish the current build to App Store Connect.

## Current Project State

- App display name: `Timeflies`
- Current marketing version: `0.1.0`
- Current build number: `1`
- Current bundle identifier placeholder: `com.opensource.timeleft`
- App icon: ready
- Privacy manifest: ready
- App Store metadata draft: ready
- App privacy draft: ready

## You Still Need to Supply

- Final production bundle identifier
- Apple Developer signing team
- Privacy Policy URL
- Final App Store screenshots
- App Store Connect app record

## Step 1: Update Xcode Signing

In Xcode:

1. Open `TimeLeft.xcodeproj`
2. Select the `TimeLeft` target
3. Open `Signing & Capabilities`
4. Choose your Apple Developer Team
5. Replace the bundle identifier with your final production ID

Recommended bundle ID example:

- `com.yourname.timeflies`

## Step 2: Confirm Versioning

In the target Build Settings, verify:

- `Marketing Version`: `1.0.0` for first release
- `Current Project Version`: `1`

If you ship another upload for the same app version later, keep `Marketing Version` the same and increase `Current Project Version`.

## Step 3: Create the App Record

In App Store Connect:

1. Go to `Apps`
2. Click `+`
3. Choose `New App`
4. Set platform to `iOS`
5. App Name: `Timeflies - Deadline`
6. Primary Language: choose your launch language
7. Bundle ID: choose the exact same one used in Xcode
8. SKU: any internal identifier you want

## Step 4: Fill Store Metadata

Use these local drafts:

- `docs/app-store-metadata.md`
- `docs/app-store-privacy.md`

You must also provide:

- `Privacy Policy URL`
- Screenshots for required iPhone sizes

## Step 5: Archive in Xcode

In Xcode:

1. Choose an iOS device destination such as `Any iOS Device`
2. Select `Product > Archive`
3. Wait for Organizer to open

## Step 6: Validate and Upload

In Organizer:

1. Select the latest archive
2. Click `Distribute App`
3. Choose `App Store Connect`
4. Choose `Upload`
5. Let Xcode validate and upload

After upload, Apple will process the build before it appears in App Store Connect.

## Step 7: Submit for Review

In App Store Connect:

1. Open the app
2. Open the version you want to release
3. Attach the processed build
4. Complete app privacy, age rating, screenshots, and review notes
5. Click `Add for Review`
6. Click `Submit for Review`

## Suggested Review Notes

- No login is required.
- App data is stored locally on device.
- The app uses local notifications for reminders.
- Email and SMS provider screens are configuration placeholders in this version.

## Final Pre-Upload Sanity Check

- Launch app from a clean install
- Create a countdown
- Edit title, deadline, tasks, and notes
- Delete a countdown
- Trigger notification permission flow
- Confirm app icon and display name show as `Timeflies`
