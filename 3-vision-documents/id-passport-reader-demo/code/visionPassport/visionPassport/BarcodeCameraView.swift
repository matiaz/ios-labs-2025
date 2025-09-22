//
//  BarcodeCameraView.swift
//  visionPassport
//
//  Created by matiaz on 21/9/25.
//

import SwiftUI
import AVFoundation
import Vision

struct BarcodeCameraView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let documentType: DocumentType
    let onBarcodeScanned: (String) -> Void
    let onError: (DocumentProcessingError) -> Void

    func makeUIViewController(context: Context) -> BarcodeCameraViewController {
        let controller = BarcodeCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: BarcodeCameraViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, BarcodeCameraViewControllerDelegate {
        var parent: BarcodeCameraView

        init(_ parent: BarcodeCameraView) {
            self.parent = parent
        }

        func barcodeCameraViewController(_ controller: BarcodeCameraViewController, didScanBarcode barcodeString: String) {
            parent.onBarcodeScanned(barcodeString)
            parent.dismiss()
        }

        func barcodeCameraViewController(_ controller: BarcodeCameraViewController, didFailWithError error: DocumentProcessingError) {
            parent.onError(error)
            parent.dismiss()
        }

        func barcodeCameraViewControllerDidCancel(_ controller: BarcodeCameraViewController) {
            parent.dismiss()
        }
    }
}

protocol BarcodeCameraViewControllerDelegate: AnyObject {
    func barcodeCameraViewController(_ controller: BarcodeCameraViewController, didScanBarcode barcodeString: String)
    func barcodeCameraViewController(_ controller: BarcodeCameraViewController, didFailWithError error: DocumentProcessingError)
    func barcodeCameraViewControllerDidCancel(_ controller: BarcodeCameraViewController)
}

class BarcodeCameraViewController: UIViewController {
    weak var delegate: BarcodeCameraViewControllerDelegate?

    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var overlayView: BarcodeOverlayView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.barcodeCameraViewController(self, didFailWithError: .cameraAccessDenied)
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.barcodeCameraViewController(self, didFailWithError: .cameraAccessDenied)
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.barcodeCameraViewController(self, didFailWithError: .cameraAccessDenied)
            return
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            delegate?.barcodeCameraViewController(self, didFailWithError: .cameraAccessDenied)
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }

    private func setupUI() {
        overlayView = BarcodeOverlayView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.widthAnchor.constraint(equalToConstant: 80),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func cancelTapped() {
        delegate?.barcodeCameraViewControllerDidCancel(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

extension BarcodeCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.barcodeCameraViewController(self, didFailWithError: .textRecognitionFailed)
                }
                return
            }

            guard let observations = request.results as? [VNBarcodeObservation],
                  let barcodeObservation = observations.first,
                  let barcodeString = barcodeObservation.payloadStringValue else {
                return
            }

            DispatchQueue.main.async {
                self.captureSession.stopRunning()
                self.delegate?.barcodeCameraViewController(self, didScanBarcode: barcodeString)
            }
        }

        request.symbologies = [.pdf417]

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.barcodeCameraViewController(self, didFailWithError: .textRecognitionFailed)
                }
            }
        }
    }
}

class BarcodeOverlayView: UIView {
    private let scanningAreaView = UIView()
    private let instructionLabel = UILabel()
    private let scanningLineView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
    }

    private func setupOverlay() {
        backgroundColor = UIColor.clear

        scanningAreaView.layer.borderColor = UIColor.white.cgColor
        scanningAreaView.layer.borderWidth = 2
        scanningAreaView.layer.cornerRadius = 8
        scanningAreaView.backgroundColor = UIColor.clear
        scanningAreaView.translatesAutoresizingMaskIntoConstraints = false

        instructionLabel.text = "Scan the PDF417 barcode on the back of your US driver's license"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        instructionLabel.layer.cornerRadius = 8
        instructionLabel.layer.masksToBounds = true
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false

        scanningLineView.backgroundColor = UIColor.systemBlue
        scanningLineView.alpha = 0.8
        scanningLineView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scanningAreaView)
        addSubview(instructionLabel)
        addSubview(scanningLineView)

        NSLayoutConstraint.activate([
            scanningAreaView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scanningAreaView.centerYAnchor.constraint(equalTo: centerYAnchor),
            scanningAreaView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            scanningAreaView.heightAnchor.constraint(equalToConstant: 120),

            instructionLabel.bottomAnchor.constraint(equalTo: scanningAreaView.topAnchor, constant: -32),
            instructionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            scanningLineView.leadingAnchor.constraint(equalTo: scanningAreaView.leadingAnchor),
            scanningLineView.trailingAnchor.constraint(equalTo: scanningAreaView.trailingAnchor),
            scanningLineView.topAnchor.constraint(equalTo: scanningAreaView.topAnchor),
            scanningLineView.heightAnchor.constraint(equalToConstant: 2)
        ])

        startScanningAnimation()
    }

    private func startScanningAnimation() {
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.scanningLineView.transform = CGAffineTransform(translationX: 0, y: 118)
        }, completion: nil)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }

        let scanningRect = CGRect(
            x: rect.width * 0.1,
            y: rect.height * 0.5 - 60,
            width: rect.width * 0.8,
            height: 120
        )

        context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        context.fill(rect)

        context.setBlendMode(.clear)
        context.fill(scanningRect)
    }
}

struct BarcodeCameraWrapperView: View {
    @ObservedObject var dataManager: SecureDataManager
    let documentType: DocumentType
    @State private var showingScanner = false
    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: documentType.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Scan \(documentType.rawValue)")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Position the PDF417 barcode on the back of your US driver's license within the camera frame")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 16) {
                barcodeInstructions

                Button(action: {
                    showingScanner = true
                }) {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Text("Start Barcode Scanning")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isProcessing)
            }
            .padding(.horizontal)

            if isProcessing {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Processing barcode...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showingScanner) {
            BarcodeCameraView(
                documentType: documentType,
                onBarcodeScanned: { barcodeString in
                    processBarcodeData(barcodeString: barcodeString)
                },
                onError: { error in
                    dataManager.appState = .error(error)
                }
            )
        }
    }

    private var barcodeInstructions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Barcode Scanning Instructions:")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 6) {
                instructionRow(icon: "doc.badge.arrow.up", text: "Flip your license to the back side")
                instructionRow(icon: "barcode", text: "Locate the PDF417 barcode (rectangular barcode)")
                instructionRow(icon: "viewfinder", text: "Align barcode within the scanning area")
                instructionRow(icon: "light.max", text: "Ensure good lighting for best results")
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private func instructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
        }
    }

    private func processBarcodeData(barcodeString: String) {
        isProcessing = true
        dataManager.appState = .processing

        DispatchQueue.global(qos: .userInitiated).async {
            let document = PDF417Parser.parseUSDriversLicense(from: barcodeString)
            let result = DocumentProcessingResult(
                document: document,
                confidence: document != nil ? 1.0 : 0.0,
                processingTime: 0.1,
                errors: document == nil ? [.invalidDocumentFormat] : []
            )

            DispatchQueue.main.async {
                isProcessing = false
                dataManager.processingResult = result

                if result.isSuccessful {
                    dataManager.setDocument(result.document)
                    dataManager.appState = .displayingResults
                } else {
                    let error = result.errors.first ?? .textRecognitionFailed
                    dataManager.appState = .error(error)
                }
            }
        }
    }
}

#Preview {
    BarcodeCameraWrapperView(
        dataManager: SecureDataManager(),
        documentType: .usDLCode
    )
}