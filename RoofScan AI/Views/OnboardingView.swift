import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var selectedUserType: UserType = .roofer
    @State private var acceptedDisclaimer = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose user type")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                            ForEach(UserType.allCases) { type in
                                Button {
                                    selectedUserType = type
                                } label: {
                                    HStack {
                                        Text(type.displayName)
                                            .font(.subheadline.weight(.semibold))
                                            .lineLimit(2)
                                        Spacer()
                                        if selectedUserType == type {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(AppTheme.blue)
                                        }
                                    }
                                    .padding(12)
                                    .frame(minHeight: 58)
                                    .background(selectedUserType == type ? AppTheme.blue.opacity(0.12) : AppTheme.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("AI disclaimer", systemImage: "shield.lefthalf.filled")
                            .font(.headline)

                        ForEach(AppConstants.disclaimerBullets, id: \.self) { item in
                            Label(item, systemImage: "checkmark")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Toggle("I understand and will verify all findings before using reports.", isOn: $acceptedDisclaimer)
                            .font(.subheadline.weight(.semibold))
                            .toggleStyle(.switch)
                    }
                    .padding(16)
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Button(action: onComplete) {
                        Label("Start Inspecting", systemImage: "arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(AppTheme.blue)
                    .disabled(!acceptedDisclaimer)
                }
                .padding()
            }
            .background(AppTheme.pageBackground)
            .navigationTitle("RoofScan AI")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "house.lodge.fill")
                .font(.system(size: 50))
                .foregroundStyle(AppTheme.blue)
            Text("Welcome to RoofScan AI")
                .font(.largeTitle.weight(.bold))
            Text("Create roof inspections, scan visible photo evidence, review findings, and export client-ready reports.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 24)
    }
}
