# Release Checklist

## Identity

- Replace `com.opensource.timeleft` with the production bundle identifier
- Set the final app name to `Timeflies - Deadline` in App Store Connect
- Set the final `MARKETING_VERSION`
- Set the correct `CURRENT_PROJECT_VERSION`
- Confirm signing team and App Store Connect app record

## Product Readiness

- Test create, edit, duplicate, delete, and task editing flows
- Test notification permission prompt and reminder scheduling
- Test cold launch and relaunch with saved local data
- Confirm no placeholder or desktop-only copy remains

## Store Assets

- Provide final App Store icon
- Capture iPhone screenshots in required sizes
- Finalize app name, subtitle, keywords, description, and review notes
- Publish a privacy policy URL

## Compliance

- Re-check `PrivacyInfo.xcprivacy`
- Fill in App Store Connect privacy answers
- Verify no third-party SDK disclosure is missing
- Verify notification usage is reflected in the product description

## Submission

- Archive a Release build
- Validate in Xcode Organizer
- Upload to App Store Connect
- Add review notes about local-only storage and notification behavior
