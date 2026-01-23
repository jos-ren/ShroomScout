//
//  ScannerView.swift
//  ShroomScout
//
//  Camera-based scanner screen for identifying mushrooms.
//  Features:
//  - Real-time camera preview using AVFoundation
//  - Scanning viewfinder overlay with animated frame
//  - Mascot with encouraging messages
//  - Capture button with flash toggle
//  - Close/cancel button
//

import SwiftUI
import AVFoundation
import PhotosUI

// MARK: - Results Flow Step

enum ResultsFlowStep {
    case results
    case matchDetail
    case confirmation
}

struct ScannerView: View {
    @Binding var isPresented: Bool

    @StateObject private var viewModel = ScannerViewModel()
    @State private var viewfinderScale: CGFloat = 1.0
    @State private var showCaptureFlash: Bool = false
    @State private var showResultsFlow: Bool = false
    @State private var identificationResult: IdentificationResult?
    @State private var selectedMatch: IdentificationMatch?
    @State private var resultsFlowStep: ResultsFlowStep = .results
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isAnalyzing: Bool = false
    @State private var scanLineOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            // Camera preview or permission overlay
            if viewModel.authorizationStatus.canAccessCamera {
                cameraPreviewLayer
            } else if viewModel.authorizationStatus == .notDetermined {
                permissionRequestView
            } else {
                permissionDeniedView
            }

            // Viewfinder overlay (when scanning)
            if viewModel.state == .scanning {
                viewfinderOverlay
            }

            // Captured image overlay
            if let capturedImage = viewModel.capturedImage {
                capturedImageOverlay(image: capturedImage)
            }

            // Scanning animation overlay
            if isAnalyzing {
                scanningOverlay
            }

            // Capture flash effect
            if showCaptureFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            // UI Controls overlay
            VStack(spacing: 0) {
                // Top bar with close button and flash toggle
                topControlsBar

                Spacer()

                // Mascot and message
                mascotSection
                    .padding(.bottom, 24)

                // Bottom controls
                bottomControlsSection
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            if viewModel.authorizationStatus == .notDetermined {
                viewModel.requestCameraPermission()
            } else if viewModel.authorizationStatus.canAccessCamera {
                viewModel.setupCaptureSession()
            }
        }
        .onDisappear {
            viewModel.stopCaptureSession()
        }
        .fullScreenCover(isPresented: $showResultsFlow) {
            resultsFlowView
        }
    }

    // MARK: - Camera Preview

    private var cameraPreviewLayer: some View {
        Group {
            if ScannerViewModel.isPreview {
                // Mock camera preview for SwiftUI Previews
                mockCameraPreview
            } else {
                CameraPreviewView(session: viewModel.captureSession)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Mock Camera Preview (for Previews)

    private var mockCameraPreview: some View {
        ZStack {
            // Forest/nature background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.3, blue: 0.2),
                    Color(red: 0.15, green: 0.25, blue: 0.15),
                    Color(red: 0.1, green: 0.2, blue: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Fake mushroom in center
            VStack(spacing: 8) {
                Text("🍄")
                    .font(.system(size: 120))
                    .shadow(color: .black.opacity(0.3), radius: 10)

                Text("Mock Camera Preview")
                    .font(.nunito(14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    // MARK: - Viewfinder Overlay

    private var viewfinderOverlay: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width - 64, 300)

            ZStack {
                // Dimmed background with cutout
                ViewfinderMask(frameSize: size)
                    .fill(Color.black.opacity(0.5))
                    .ignoresSafeArea()

                // Animated viewfinder frame
                ViewfinderFrame(size: size)
                    .stroke(AppColors.coral, lineWidth: 3)
                    .frame(width: size, height: size)
                    .scaleEffect(viewfinderScale)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: viewfinderScale
                    )
                    .onAppear {
                        viewfinderScale = 1.03
                    }

                // Corner brackets
                ViewfinderCorners(size: size, cornerLength: 24, lineWidth: 4)
                    .stroke(AppColors.primaryGreen, lineWidth: 4)
                    .frame(width: size, height: size)
            }
        }
    }

    // MARK: - Captured Image Overlay

    private func capturedImageOverlay(image: UIImage) -> some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .ignoresSafeArea()
        }
    }

    // MARK: - Scanning Overlay

    private var scanningOverlay: some View {
        GeometryReader { geometry in
            ZStack {
                // Semi-transparent overlay
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                // Scanning line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.coral.opacity(0),
                                AppColors.coral.opacity(0.8),
                                AppColors.coral,
                                AppColors.coral.opacity(0.8),
                                AppColors.coral.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 4)
                    .shadow(color: AppColors.coral.opacity(0.8), radius: 8, x: 0, y: 0)
                    .offset(y: scanLineOffset)

                // Analyzing text
                VStack(spacing: 16) {
                    Spacer()

                    Text("Analyzing...")
                        .font(.nunito(18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(20)

                    Spacer()
                        .frame(height: 120)
                }
            }
            .onAppear {
                // Start scanning animation
                let height = geometry.size.height
                scanLineOffset = -height / 2

                withAnimation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
                ) {
                    scanLineOffset = height / 2
                }
            }
            .onDisappear {
                scanLineOffset = 0
            }
        }
    }

    // MARK: - Results Flow View

    @ViewBuilder
    private var resultsFlowView: some View {
        if let result = identificationResult {
            switch resultsFlowStep {
            case .results:
                ScanResultsView(
                    capturedImage: viewModel.capturedImage ?? ScannerViewModel.createMockCapturedImage(),
                    identificationResult: result,
                    onConfirmDiscovery: { match in
                        // User selected a match - navigate to detail without animation
                        selectedMatch = match
                        resultsFlowStep = .matchDetail
                    },
                    onTryAgain: {
                        // Close results and retake
                        showResultsFlow = false
                        identificationResult = nil
                        resultsFlowStep = .results
                        viewModel.retakePhoto()
                    }
                )
            case .matchDetail:
                if let match = selectedMatch {
                    MatchDetailView(
                        match: match,
                        capturedImage: viewModel.capturedImage ?? ScannerViewModel.createMockCapturedImage(),
                        onConfirm: {
                            // User confirmed the match - show confirmation without animation
                            resultsFlowStep = .confirmation
                        },
                        onBack: {
                            // Go back to results without animation
                            resultsFlowStep = .results
                        }
                    )
                }
            case .confirmation:
                if let match = selectedMatch {
                    ConfirmationView(
                        species: SampleSpecies(
                            id: match.species.id,
                            commonName: match.species.commonName,
                            scientificName: match.species.scientificName,
                            description: match.species.speciesDescription,
                            rarity: match.species.rarity,
                            edibility: match.species.edibility,
                            season: match.species.season,
                            habitat: match.species.habitat,
                            keyFeatures: match.species.identificationTips.components(separatedBy: ". "),
                            funFact: "A fascinating mushroom find!",
                            imageName: match.species.referenceImageName,
                            isDiscovered: true
                        ),
                        isNewSpecies: true,
                        stats: DiscoveryStats(
                            totalSpeciesFound: 5,
                            totalSightings: 12,
                            xpEarned: DiscoveryStats.xpForRarity(match.species.rarity) + DiscoveryStats.newSpeciesBonus
                        ),
                        onViewCollection: {
                            showResultsFlow = false
                            resultsFlowStep = .results
                            isPresented = false
                        },
                        onKeepExploring: {
                            showResultsFlow = false
                            resultsFlowStep = .results
                            isPresented = false
                        }
                    )
                }
            }
        }
    }

    // MARK: - Top Controls Bar

    private var topControlsBar: some View {
        HStack {
            // Close button
            Button(action: { isPresented = false }) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 44, height: 44)

                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(BounceButtonStyle())

            Spacer()

            // Flash toggle (only when scanning)
            if viewModel.state == .scanning && viewModel.authorizationStatus.canAccessCamera {
                Button(action: { viewModel.toggleFlash() }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isFlashEnabled ? AppColors.coral : Color.black.opacity(0.5))
                            .frame(width: 44, height: 44)

                        Image(systemName: viewModel.isFlashEnabled ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(BounceButtonStyle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Mascot Section

    private var mascotSection: some View {
        VStack(spacing: 12) {
            MascotView(expression: viewModel.mascotExpression, size: 80)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)

            Text(viewModel.mascotMessage)
                .font(.nunito(16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Bottom Controls Section

    private var bottomControlsSection: some View {
        VStack(spacing: 24) {
            if viewModel.capturedImage != nil {
                // Photo captured - show analyze/retake buttons
                capturedPhotoControls
            } else if viewModel.authorizationStatus.canAccessCamera {
                // Camera active - show capture button with gallery option
                ZStack {
                    // Capture button (center)
                    captureButton

                    // Gallery button (left side)
                    HStack {
                        galleryButton
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
    }

    // MARK: - Gallery Button

    private var galleryButton: some View {
        PhotosPicker(
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(BounceButtonStyle())
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                await loadSelectedPhoto()
            }
        }
    }

    // MARK: - Load Selected Photo

    private func loadSelectedPhoto() async {
        guard let selectedPhotoItem else { return }

        do {
            if let data = try await selectedPhotoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    viewModel.capturedImage = image
                    viewModel.state = .captured
                    self.selectedPhotoItem = nil
                }
            }
        } catch {
            print("Failed to load photo from gallery: \(error)")
            await MainActor.run {
                self.selectedPhotoItem = nil
            }
        }
    }

    // MARK: - Capture Button

    private var captureButton: some View {
        Button(action: capturePhoto) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 80, height: 80)

                // Inner filled circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
            }
        }
        .buttonStyle(CaptureButtonStyle())
        .disabled(!viewModel.canCapture)
    }

    // MARK: - Captured Photo Controls

    private var capturedPhotoControls: some View {
        HStack(spacing: 24) {
            // Retake button
            Button(action: { viewModel.retakePhoto() }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Retake")
                        .font(.nunito(16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.2))
                .cornerRadius(100)
            }
            .buttonStyle(BounceButtonStyle())

            // Analyze button
            Button(action: analyzePhoto) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkle.magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Analyze")
                        .font(.nunito(16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(AppColors.coral)
                .cornerRadius(100)
            }
            .buttonStyle(BounceButtonStyle())
        }
    }

    // MARK: - Permission Request View

    private var permissionRequestView: some View {
        VStack(spacing: 24) {
            Spacer()

            AnimatedMascotView(expression: .curious, size: 120)

            Text("Camera Access Needed")
                .font(.nunito(24, weight: .bold))
                .foregroundColor(.white)

            Text("We need camera access to scan and identify mushrooms. Your photos stay on your device.")
                .font(.nunito(14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)

            AppButton("Enable Camera", style: .primary) {
                viewModel.requestCameraPermission()
            }
            .padding(.horizontal, 48)
            .padding(.top, 8)

            Spacer()
        }
    }

    // MARK: - Permission Denied View

    private var permissionDeniedView: some View {
        VStack(spacing: 24) {
            Spacer()

            MascotView(expression: .encouraging, size: 120)

            Text("Camera Access Required")
                .font(.nunito(24, weight: .bold))
                .foregroundColor(.white)

            Text(viewModel.authorizationStatus.userFriendlyMessage)
                .font(.nunito(14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)

            AppButton("Open Settings", style: .primary) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.horizontal, 48)
            .padding(.top, 8)

            Button(action: { isPresented = false }) {
                Text("Go Back")
                    .font(.nunito(16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 8)

            Spacer()
        }
    }

    // MARK: - Actions

    private func capturePhoto() {
        // Show flash effect
        withAnimation(.easeOut(duration: 0.1)) {
            showCaptureFlash = true
        }

        // Hide flash after brief moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeIn(duration: 0.15)) {
                showCaptureFlash = false
            }
        }

        // Trigger haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        // Capture the photo
        viewModel.capturePhoto()
    }

    private func analyzePhoto() {
        print("🔍 [ScannerView] analyzePhoto() called")
        print("🔍 [ScannerView] capturedImage exists: \(viewModel.capturedImage != nil)")

        // Show scanning animation
        isAnalyzing = true

        // Trigger haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        // Simulate analysis time (1 second for mock), then show results
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isAnalyzing = false

            // Use mock identification result with 3 matches
            identificationResult = IdentificationResult.mock
            resultsFlowStep = .results
            showResultsFlow = true
            print("🔍 [ScannerView] identificationResult set, presenting results")
        }
    }
}

// MARK: - Camera Preview View (UIViewRepresentable)

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        // No updates needed
    }
}

class CameraPreviewUIView: UIView {
    var session: AVCaptureSession? {
        didSet {
            guard let session = session else { return }
            previewLayer.session = session
        }
    }

    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.videoGravity = .resizeAspectFill
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(previewLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}

// MARK: - Viewfinder Shapes

/// Creates a dimmed overlay with a transparent rectangular cutout
struct ViewfinderMask: Shape {
    let frameSize: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Rectangle().path(in: rect)

        let cutoutRect = CGRect(
            x: (rect.width - frameSize) / 2,
            y: (rect.height - frameSize) / 2,
            width: frameSize,
            height: frameSize
        )

        path.addRoundedRect(in: cutoutRect, cornerSize: CGSize(width: 16, height: 16))
        return path
    }
}

/// Rounded rectangle frame for the viewfinder
struct ViewfinderFrame: Shape {
    let size: CGFloat

    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: 16)
            .path(in: CGRect(x: 0, y: 0, width: size, height: size))
    }
}

/// Corner bracket decorations for the viewfinder
struct ViewfinderCorners: Shape {
    let size: CGFloat
    let cornerLength: CGFloat
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 16
        let offset = lineWidth / 2

        // Top-left corner
        path.move(to: CGPoint(x: offset, y: cornerLength + cornerRadius))
        path.addLine(to: CGPoint(x: offset, y: cornerRadius))
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius - offset,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: cornerLength + cornerRadius, y: offset))

        // Top-right corner
        path.move(to: CGPoint(x: size - cornerLength - cornerRadius, y: offset))
        path.addLine(to: CGPoint(x: size - cornerRadius, y: offset))
        path.addArc(
            center: CGPoint(x: size - cornerRadius, y: cornerRadius),
            radius: cornerRadius - offset,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: size - offset, y: cornerLength + cornerRadius))

        // Bottom-right corner
        path.move(to: CGPoint(x: size - offset, y: size - cornerLength - cornerRadius))
        path.addLine(to: CGPoint(x: size - offset, y: size - cornerRadius))
        path.addArc(
            center: CGPoint(x: size - cornerRadius, y: size - cornerRadius),
            radius: cornerRadius - offset,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: size - cornerLength - cornerRadius, y: size - offset))

        // Bottom-left corner
        path.move(to: CGPoint(x: cornerLength + cornerRadius, y: size - offset))
        path.addLine(to: CGPoint(x: cornerRadius, y: size - offset))
        path.addArc(
            center: CGPoint(x: cornerRadius, y: size - cornerRadius),
            radius: cornerRadius - offset,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: offset, y: size - cornerLength - cornerRadius))

        return path
    }
}

// MARK: - Capture Button Style

struct CaptureButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Scanner - Camera Active") {
    ScannerView(isPresented: .constant(true))
}

#Preview("Scanner - Permission Denied") {
    struct PreviewWrapper: View {
        @State private var isPresented = true

        var body: some View {
            Color.clear
                .sheet(isPresented: $isPresented) {
                    ScannerPreviewDenied()
                }
        }
    }

    return PreviewWrapper()
}

// Helper view for denied permission preview
private struct ScannerPreviewDenied: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 44, height: 44)

                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                MascotView(expression: .encouraging, size: 120)

                Text("Camera Access Required")
                    .font(.nunito(24, weight: .bold))
                    .foregroundColor(.white)

                Text("Please enable camera access in Settings to scan mushrooms.")
                    .font(.nunito(14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)

                AppButton("Open Settings", style: .primary) {
                    // No-op in preview
                }
                .padding(.horizontal, 48)
                .padding(.top, 8)

                Button(action: { dismiss() }) {
                    Text("Go Back")
                        .font(.nunito(16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 8)

                Spacer()
            }
        }
    }
}
