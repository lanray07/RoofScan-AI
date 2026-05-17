# RoofScan AI

RoofScan AI is a SwiftUI iOS app scaffold for roofing inspections, AI-assisted visual findings, client-ready report generation, local persistence, and subscription gating.

## Requirements

- Xcode 16 or later
- iOS 17 or later
- SwiftUI
- SwiftData
- StoreKit 2

## Run

Open `RoofScan AI.xcodeproj` in Xcode and run the `RoofScan AI` scheme on an iOS simulator or device.

Mock AI and mock subscription state are enabled by default in `RoofScanAIApp.swift`:

```swift
@State private var subscriptionManager = SubscriptionManager(useMockState: true)
...
.environment(\.aiService, MockAIService())
```

## Remote AI

The app never stores third-party AI API keys. Replace the backend URL in `Utilities/AppConstants.swift`, then inject `RemoteAIService()` instead of `MockAIService()` after your secure backend is live.

Expected endpoint:

```http
POST https://YOUR_BACKEND_URL.com/roof-scan
```

## StoreKit

Placeholder products are defined in `Resources/StoreKitConfiguration.storekit`:

- `com.roofscanai.pro.monthly`
- `com.roofscanai.pro.yearly`
- `com.roofscanai.business.monthly`

Create matching products in App Store Connect before production release.

## App Review Notes

The app displays safety disclaimers during onboarding and in generated reports. Before submission, replace the placeholder privacy policy and terms text in `SettingsView.swift` with production legal documents.
