import SwiftUI

struct HomeView: View {
    @StateObject private var scanner = QRScannerViewModel()
    @StateObject private var library = SOPLibraryStore()
    @State private var selectedCategory: DeviceCategory = .labEquipment
    @State private var selectedSavedResource: SOPSavedResource?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    scannerPanel
                    statusCard
                    scanResultSection
                    librarySection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.97, blue: 1.0),
                        Color(red: 0.88, green: 0.93, blue: 0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("SOP Scanner")
            .navigationDestination(item: $selectedSavedResource) { resource in
                ResourcePreviewView(
                    resource: resource,
                    localURL: library.localURL(for: resource)
                )
            }
        }
        .onAppear {
            scanner.requestAccessIfNeeded()
        }
    }

    private var scannerPanel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.92))

            switch scanner.authorizationState {
            case .authorized:
                ZStack {
                    CameraPreviewView(session: scanner.session)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                    ScannerOverlayView()
                }
            case .idle:
                placeholderPanel(
                    icon: "camera.viewfinder",
                    title: "Preparing Camera",
                    message: "Checking permission and getting the scanner ready."
                )
            case .denied:
                placeholderPanel(
                    icon: "camera.fill.badge.xmark",
                    title: "Camera Access Needed",
                    message: "Allow camera access in Settings to scan QR codes."
                )
            case .restricted, .unavailable:
                placeholderPanel(
                    icon: "exclamationmark.triangle.fill",
                    title: "Camera Unavailable",
                    message: "This device cannot provide camera access right now."
                )
            }
        }
        .frame(height: 360)
        .overlay(alignment: .topLeading) {
            Text("Live Scanner")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(16)
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Status")
                .font(.headline)

            Text(scanner.statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !library.downloadMessage.isEmpty {
                Text(library.downloadMessage)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(library.isDownloading ? .blue : .green)
            }

            if scanner.scannedCode != nil {
                Button("Scan Again") {
                    scanner.scanAgain()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    @ViewBuilder
    private var scanResultSection: some View {
        if let scannedCode = scanner.scannedCode {
            VStack(alignment: .leading, spacing: 16) {
                Text("Scanned QR")
                    .font(.headline)

                Text(scannedCode)
                    .font(.body.monospaced())
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.black.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                if let candidate = scanner.scannedCandidate {
                    supportedResultCard(candidate: candidate)
                } else {
                    unsupportedResultCard
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        } else {
            tipsCard
        }
    }

    private func supportedResultCard(candidate: ScannedResourceCandidate) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Detected Resource")
                    .font(.headline)
                Spacer()
                Text(candidate.kind.title)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.12), in: Capsule())
            }

            Text("Save this SOP file to the device category students will use.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Device Type", selection: $selectedCategory) {
                ForEach(DeviceCategory.allCases) { category in
                    Text(category.title).tag(category)
                }
            }
            .pickerStyle(.menu)

            HStack {
                Button("Save to iPhone") {
                    Task {
                        await library.saveResource(from: candidate, category: selectedCategory)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(library.isDownloading)

                Link("Open Original Link", destination: candidate.url)
                    .buttonStyle(.bordered)
            }
        }
    }

    private var unsupportedResultCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Link Detected")
                .font(.headline)

            Text("This QR code is not a supported PDF, text, Word, or video link yet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips")
                .font(.headline)

            Text("Scan a QR code that points to a PDF, text file, Word document, or video file.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("After scanning, choose a device type so the SOP can be saved into the right category.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var librarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saved SOP Library")
                .font(.headline)

            ForEach(DeviceCategory.allCases) { category in
                let resources = library.resources(for: category)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(category.title)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(resources.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if resources.isEmpty {
                        Text("No files saved in this category yet.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(resources) { resource in
                            Button {
                                selectedSavedResource = resource
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: iconName(for: resource.kind))
                                        .font(.title3)
                                        .foregroundStyle(.accentColor)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(resource.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)

                                        Text(resource.localFilename)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)

                                        Text(resource.savedAt, style: .date)
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }

                                    Spacer()
                                }
                                .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func iconName(for kind: SOPResourceKind) -> String {
        switch kind {
        case .pdf:
            "doc.richtext"
        case .text:
            "text.page"
        case .word:
            "doc.text"
        case .video:
            "video"
        case .unsupported:
            "questionmark.square"
        }
    }

    private func placeholderPanel(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 42))
                .foregroundStyle(.white)

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

private struct ScannerOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.62

            ZStack {
                Color.black.opacity(0.22)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .frame(width: size, height: size)
                    .blendMode(.destinationOut)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: size, height: size)
            }
            .compositingGroup()
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    HomeView()
}
