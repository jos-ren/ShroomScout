//
//  ScannerViewModel.swift
//  ShroomScout
//
//  ViewModel for the Scanner screen. Manages camera capture, permissions, and photo state.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

// MARK: - Camera Authorization Status

enum CameraAuthorizationStatus {
    case notDetermined
    case restricted
    case denied
    case authorized

    var canAccessCamera: Bool {
        self == .authorized
    }

    var userFriendlyMessage: String {
        switch self {
        case .notDetermined:
            return "Camera access is needed to scan mushrooms."
        case .restricted:
            return "Camera access is restricted on this device."
        case .denied:
            return "Please enable camera access in Settings to scan mushrooms."
        case .authorized:
            return "Camera access enabled."
        }
    }
}

// MARK: - Scanner State

enum ScannerState: Equatable {
    case idle           // Ready to scan
    case scanning       // Camera active, looking for mushroom
    case captured       // Photo taken, ready to analyze
    case analyzing      // Processing image
    case error(String)  // Error occurred

    static func == (lhs: ScannerState, rhs: ScannerState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.scanning, .scanning), (.captured, .captured), (.analyzing, .analyzing):
            return true
        case (.error(let lhsMsg), .error(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

// MARK: - Scanner View Model

@MainActor
final class ScannerViewModel: ObservableObject {
    // MARK: - Preview Detection

    /// Returns true if running in SwiftUI Preview environment
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    // MARK: - Published Properties

    /// Current camera authorization status
    @Published private(set) var authorizationStatus: CameraAuthorizationStatus = .notDetermined

    /// Current scanner state
    @Published var state: ScannerState = .idle

    /// Captured image (if any)
    @Published var capturedImage: UIImage?

    /// Whether the flash is enabled
    @Published var isFlashEnabled: Bool = false

    /// Mascot message based on current state
    @Published private(set) var mascotMessage: String = "Point your camera at a mushroom!"

    /// Mascot expression based on current state
    @Published private(set) var mascotExpression: MascotView.Expression = .curious

    // MARK: - Camera Session

    let captureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    private var currentDevice: AVCaptureDevice?
    private var photoCaptureDelegate: PhotoCaptureDelegate?

    // MARK: - Computed Properties

    var isSessionRunning: Bool {
        captureSession.isRunning
    }

    var canCapture: Bool {
        authorizationStatus.canAccessCamera && state == .scanning && capturedImage == nil
    }

    var showCameraPermissionOverlay: Bool {
        !authorizationStatus.canAccessCamera && authorizationStatus != .notDetermined
    }

    // MARK: - Initialization

    init() {
        checkAuthorizationStatus()
    }

    // MARK: - Public Methods

    /// Check current camera authorization status
    func checkAuthorizationStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        updateAuthorizationStatus(from: status)
    }

    /// Request camera permission
    func requestCameraPermission() {
        // In preview mode, simulate authorized state
        guard !Self.isPreview else {
            authorizationStatus = .authorized
            setupCaptureSession()
            return
        }

        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            Task { @MainActor in
                self?.authorizationStatus = granted ? .authorized : .denied
                if granted {
                    self?.setupCaptureSession()
                }
            }
        }
    }

    /// Setup and start the camera capture session
    func setupCaptureSession() {
        // Skip camera setup in SwiftUI Previews to prevent crashes
        guard !Self.isPreview else {
            state = .scanning
            updateMascotState()
            return
        }

        guard authorizationStatus.canAccessCamera else { return }
        guard !captureSession.isRunning else { return }

        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }

            await MainActor.run {
                self.state = .scanning
                self.updateMascotState()
            }

            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo

            // Add video input
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                await MainActor.run {
                    self.state = .error("No camera available")
                    self.updateMascotState()
                }
                return
            }

            await MainActor.run {
                self.currentDevice = videoDevice
            }

            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.captureSession.canAddInput(videoInput) {
                    self.captureSession.addInput(videoInput)
                }
            } catch {
                await MainActor.run {
                    self.state = .error("Failed to setup camera: \(error.localizedDescription)")
                    self.updateMascotState()
                }
                return
            }

            // Add photo output
            let photoOutput = AVCapturePhotoOutput()
            if self.captureSession.canAddOutput(photoOutput) {
                self.captureSession.addOutput(photoOutput)
                await MainActor.run {
                    self.photoOutput = photoOutput
                }
            }

            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }

    /// Stop the camera capture session
    func stopCaptureSession() {
        guard captureSession.isRunning else { return }

        Task.detached(priority: .userInitiated) { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    /// Capture a photo
    func capturePhoto() {
        guard canCapture else { return }

        // In preview mode, use a mock image
        if Self.isPreview {
            capturedImage = Self.createMockCapturedImage()
            state = .captured
            updateMascotState()
            return
        }

        guard let photoOutput = photoOutput else {
            state = .error("Camera not ready")
            updateMascotState()
            return
        }

        let settings = AVCapturePhotoSettings()

        // Enable flash if available and requested
        if isFlashEnabled, let device = currentDevice, device.hasFlash {
            settings.flashMode = .on
        } else {
            settings.flashMode = .off
        }

        // Create and store the delegate
        let delegate = PhotoCaptureDelegate { [weak self] image in
            Task { @MainActor in
                if let image = image {
                    self?.capturedImage = image
                    self?.state = .captured
                } else {
                    self?.state = .error("Failed to capture photo")
                }
                self?.updateMascotState()
            }
        }

        photoCaptureDelegate = delegate
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }

    /// Creates a mock captured image for preview mode
    static func createMockCapturedImage() -> UIImage {
        let size = CGSize(width: 400, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Draw forest green background
            UIColor(red: 0.15, green: 0.25, blue: 0.15, alpha: 1.0).setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Draw a lighter green circle in the middle (mock mushroom area)
            UIColor(red: 0.2, green: 0.35, blue: 0.2, alpha: 1.0).setFill()
            let circleRect = CGRect(x: 100, y: 200, width: 200, height: 200)
            context.cgContext.fillEllipse(in: circleRect)

            // Draw "🍄" text in the center
            let text = "🍄"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 100)
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }

    /// Retake the photo
    func retakePhoto() {
        capturedImage = nil
        state = .scanning
        updateMascotState()
    }

    /// Toggle flash mode
    func toggleFlash() {
        isFlashEnabled.toggle()
    }

    /// Reset the scanner to initial state
    func reset() {
        capturedImage = nil
        state = .idle
        updateMascotState()
    }

    // MARK: - Private Methods

    private func updateAuthorizationStatus(from status: AVAuthorizationStatus) {
        switch status {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .restricted:
            authorizationStatus = .restricted
        case .denied:
            authorizationStatus = .denied
        case .authorized:
            authorizationStatus = .authorized
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }

    private func updateMascotState() {
        switch state {
        case .idle:
            mascotMessage = "Ready to scan!"
            mascotExpression = .happy
        case .scanning:
            mascotMessage = "Point your camera at a mushroom!"
            mascotExpression = .curious
        case .captured:
            mascotMessage = "Great shot! Tap 'Analyze' to identify."
            mascotExpression = .excited
        case .analyzing:
            mascotMessage = "Let me take a closer look..."
            mascotExpression = .curious
        case .error(let message):
            mascotMessage = "Oops! \(message)"
            mascotExpression = .cautious
        }
    }
}

// MARK: - Photo Capture Delegate

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        super.init()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error.localizedDescription)")
            completion(nil)
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completion(nil)
            return
        }

        completion(image)
    }
}

// MARK: - Preview Helper

extension ScannerViewModel {
    static var preview: ScannerViewModel {
        let viewModel = ScannerViewModel()
        viewModel.authorizationStatus = .authorized
        viewModel.state = .scanning
        return viewModel
    }

    static var previewDenied: ScannerViewModel {
        let viewModel = ScannerViewModel()
        viewModel.authorizationStatus = .denied
        return viewModel
    }

    static var previewCaptured: ScannerViewModel {
        let viewModel = ScannerViewModel()
        viewModel.authorizationStatus = .authorized
        viewModel.state = .captured
        // Note: We can't easily set a preview image without an actual photo
        return viewModel
    }
}
