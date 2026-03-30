import AVFoundation
import Foundation

final class QRScannerViewModel: NSObject, ObservableObject {
    enum AuthorizationState {
        case idle
        case authorized
        case denied
        case restricted
        case unavailable
    }

    @Published private(set) var authorizationState: AuthorizationState = .idle
    @Published private(set) var scannedCode: String?
    @Published private(set) var scannedCandidate: ScannedResourceCandidate?
    @Published private(set) var statusMessage = "Point the camera at a QR code to scan."

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "SOP.ScannerSession")
    private var isConfigured = false
    private var isScanningEnabled = true

    func requestAccessIfNeeded() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorizationState = .authorized
            configureSessionIfNeeded()
            startScanning()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if granted {
                        self.authorizationState = .authorized
                        self.configureSessionIfNeeded()
                        self.startScanning()
                    } else {
                        self.authorizationState = .denied
                        self.statusMessage = "Camera access is required to scan QR codes."
                    }
                }
            }
        case .denied:
            authorizationState = .denied
            statusMessage = "Enable camera access in Settings to scan QR codes."
        case .restricted:
            authorizationState = .restricted
            statusMessage = "This device currently restricts camera access."
        @unknown default:
            authorizationState = .unavailable
            statusMessage = "Camera access is unavailable on this device."
        }
    }

    func startScanning() {
        guard authorizationState == .authorized else { return }
        isScanningEnabled = true
        statusMessage = "Point the camera at a QR code to scan."

        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stopScanning() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    func scanAgain() {
        DispatchQueue.main.async {
            self.scannedCode = nil
            self.scannedCandidate = nil
            self.startScanning()
        }
    }

    private func configureSessionIfNeeded() {
        guard !isConfigured else { return }
        isConfigured = true

        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard let device = AVCaptureDevice.default(for: .video) else {
                DispatchQueue.main.async {
                    self.authorizationState = .unavailable
                    self.statusMessage = "No camera is available on this device."
                }
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                self.session.beginConfiguration()

                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }

                let output = AVCaptureMetadataOutput()
                if self.session.canAddOutput(output) {
                    self.session.addOutput(output)
                    output.setMetadataObjectsDelegate(self, queue: .main)
                    output.metadataObjectTypes = [.qr]
                }

                self.session.commitConfiguration()
            } catch {
                DispatchQueue.main.async {
                    self.authorizationState = .unavailable
                    self.statusMessage = "The camera could not be configured."
                }
            }
        }
    }
}

extension QRScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard isScanningEnabled else { return }
        guard
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            object.type == .qr,
            let value = object.stringValue,
            !value.isEmpty
        else {
            return
        }

        isScanningEnabled = false
        scannedCode = value
        scannedCandidate = Self.candidate(from: value)
        statusMessage = scannedCandidate?.isSupported == true
            ? "QR code captured. Ready to save."
            : "QR code captured."
        stopScanning()
    }

    private static func candidate(from value: String) -> ScannedResourceCandidate? {
        guard let url = URL(string: value), let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) else {
            return nil
        }

        let kind = classify(url: url)
        return ScannedResourceCandidate(url: url, kind: kind)
    }

    private static func classify(url: URL) -> SOPResourceKind {
        let ext = url.pathExtension.lowercased()

        if ext == "pdf" {
            return .pdf
        }

        if ["txt", "rtf", "md"].contains(ext) {
            return .text
        }

        if ["doc", "docx"].contains(ext) {
            return .word
        }

        if ["mp4", "mov", "m4v", "avi"].contains(ext) {
            return .video
        }

        return .unsupported
    }
}
