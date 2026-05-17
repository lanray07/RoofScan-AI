import PhotosUI
import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @AppStorage("businessName") private var businessName = ""
    @AppStorage("businessContactName") private var businessContactName = ""
    @AppStorage("businessPhone") private var businessPhone = ""
    @AppStorage("businessEmail") private var businessEmail = ""
    @AppStorage("businessLogoBase64") private var businessLogoBase64 = ""

    @Query private var inspections: [RoofInspection]
    @Query private var photos: [RoofPhoto]
    @Query private var issues: [RoofIssue]
    @Query private var reports: [RoofReport]
    @Query private var subscriptions: [SubscriptionState]

    @State private var viewModel = SettingsViewModel()
    @State private var logoPickerItem: PhotosPickerItem?
    @State private var showsDeleteConfirmation = false

    var body: some View {
        Form {
            Section("Subscription") {
                LabeledContent("Status", value: subscriptionManager.statusText)

                Button {
                    router.navigate(to: .paywall)
                } label: {
                    Label("View Plans", systemImage: "bolt.shield")
                }

                Button {
                    subscriptionManager.openManageSubscriptions()
                } label: {
                    Label("Manage Subscription", systemImage: "person.crop.circle.badge.checkmark")
                }
            }

            Section("Business Profile") {
                TextField("Business name", text: $businessName)
                TextField("Contact name", text: $businessContactName)
                TextField("Phone", text: $businessPhone)
                    .keyboardType(.phonePad)
                TextField("Email", text: $businessEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            Section("Report Branding") {
                PhotosPicker(selection: $logoPickerItem, matching: .images) {
                    Label(businessLogoBase64.isEmpty ? "Add Logo" : "Replace Logo", systemImage: "photo.badge.plus")
                }
                .disabled(!subscriptionManager.canUseProBranding)

                if !businessLogoBase64.isEmpty {
                    Button(role: .destructive) {
                        businessLogoBase64 = ""
                    } label: {
                        Label("Remove Logo", systemImage: "trash")
                    }
                }

                LabeledContent("Pro branding", value: subscriptionManager.canUseProBranding ? "Enabled" : "Upgrade required")
                LabeledContent("Business branding", value: subscriptionManager.canUseBusinessBranding ? "Enabled" : "Upgrade required")
            }

            Section("Safety and Legal") {
                NavigationLink("Privacy Policy") {
                    LegalTextView(title: "Privacy Policy", text: privacyText)
                }
                NavigationLink("Terms of Use") {
                    LegalTextView(title: "Terms of Use", text: termsText)
                }
                NavigationLink("AI Disclaimer") {
                    LegalTextView(title: "AI Disclaimer", text: AppConstants.reportDisclaimer)
                }
            }

            Section("Saved Reports") {
                if reports.isEmpty {
                    Text("No reports saved locally.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(reports) { report in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(report.title)
                                    .font(.headline)
                                Text(report.createdAt.roofScanShortDate)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if let url = report.pdfLocalURL {
                                ShareLink(item: url) {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                    }
                }
            }

            Section("Local Data") {
                Button(role: .destructive) {
                    showsDeleteConfirmation = true
                } label: {
                    Label("Delete All Local Data", systemImage: "trash")
                }

                if let message = viewModel.confirmationMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .onChange(of: logoPickerItem) { _, newItem in
            Task { await loadLogo(from: newItem) }
        }
        .confirmationDialog("Delete all local RoofScan AI data?", isPresented: $showsDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete all data", role: .destructive) {
                viewModel.deleteAllLocalData(
                    inspections: inspections,
                    photos: photos,
                    issues: issues,
                    reports: reports,
                    subscriptions: subscriptions,
                    modelContext: modelContext
                )
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes inspections, photos, issues, reports, and stored subscription state from this device.")
        }
    }

    private func loadLogo(from item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let jpeg = ImageUtilities.normalizedJPEGData(from: data, maxDimension: 512, compressionQuality: 0.82) {
                businessLogoBase64 = jpeg.base64EncodedString()
            }
        } catch {
            viewModel.confirmationMessage = "Unable to load logo. \(error.localizedDescription)"
        }
    }

    private var privacyText: String {
        """
        RoofScan AI stores inspections, roof photos, findings, and generated reports locally on this device using SwiftData. Remote AI mode should send photo data only to your secure backend endpoint. Do not place third-party AI API keys in the iOS app.

        Before App Store submission, replace this placeholder with your complete privacy policy, including data collection, retention, deletion, analytics, support, and backend processing details.
        """
    }

    private var termsText: String {
        """
        RoofScan AI provides visual inspection workflow tools and AI-generated suggestions. Users remain responsible for safe photo capture, professional verification, client communication, and compliance with local laws and industry standards.

        Before App Store submission, replace this placeholder with production terms of use and subscription terms.
        """
    }
}

private struct LegalTextView: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(title)
        .background(AppTheme.pageBackground)
    }
}
