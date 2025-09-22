//
//  DocumentProcessor.swift
//  visionPassport
//
//  Created by matiaz on 21/9/25.
//

import Foundation
import Vision
import UIKit
import CoreImage

class DocumentProcessor {

    static let shared = DocumentProcessor()

    private init() {}

    func processDocument(image: UIImage, documentType: DocumentType, completion: @escaping (DocumentProcessingResult) -> Void) {
        let startTime = Date()

        guard let cgImage = image.cgImage else {
            let result = DocumentProcessingResult(
                document: nil,
                confidence: 0.0,
                processingTime: Date().timeIntervalSince(startTime),
                errors: [.textRecognitionFailed]
            )
            completion(result)
            return
        }

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                let result = DocumentProcessingResult(
                    document: nil,
                    confidence: 0.0,
                    processingTime: Date().timeIntervalSince(startTime),
                    errors: [.textRecognitionFailed]
                )
                completion(result)
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                let result = DocumentProcessingResult(
                    document: nil,
                    confidence: 0.0,
                    processingTime: Date().timeIntervalSince(startTime),
                    errors: [.documentNotDetected]
                )
                completion(result)
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            let averageConfidence = observations.compactMap { observation in
                observation.topCandidates(1).first?.confidence
            }.reduce(0, +) / Float(max(observations.count, 1))

            DispatchQueue.main.async {
                let document = self.parseDocument(from: recognizedStrings, documentType: documentType)
                let result = DocumentProcessingResult(
                    document: document,
                    confidence: averageConfidence,
                    processingTime: Date().timeIntervalSince(startTime),
                    errors: document == nil ? [.invalidDocumentFormat] : []
                )
                completion(result)
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.revision = VNRecognizeTextRequestRevision3

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    let result = DocumentProcessingResult(
                        document: nil,
                        confidence: 0.0,
                        processingTime: Date().timeIntervalSince(startTime),
                        errors: [.textRecognitionFailed]
                    )
                    completion(result)
                }
            }
        }
    }

    private func parseDocument(from strings: [String], documentType: DocumentType) -> PersonalDocument? {
        switch documentType {
        case .passport:
            return PassportParser.parsePassport(from: strings)
        case .driversLicense, .nationalID:
            return IDParser.parseID(from: strings, documentType: documentType)
        }
    }

    func validateImageQuality(_ image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return false }

        let width = cgImage.width
        let height = cgImage.height

        let minResolution = 800 * 600
        return (width * height) >= minResolution
    }

    func preprocessImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()

        let filters = [
            CIFilter(name: "CIColorControls")?.apply { filter in
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(1.2, forKey: kCIInputContrastKey)
                filter.setValue(0.1, forKey: kCIInputBrightnessKey)
            },
            CIFilter(name: "CIUnsharpMask")?.apply { filter in
                filter.setValue(0.5, forKey: kCIInputIntensityKey)
                filter.setValue(2.5, forKey: kCIInputRadiusKey)
            }
        ].compactMap { $0 }

        var processedImage = ciImage
        for filter in filters {
            if let outputImage = filter.outputImage {
                processedImage = outputImage
                filter.setValue(processedImage, forKey: kCIInputImageKey)
            }
        }

        guard let outputCGImage = context.createCGImage(processedImage, from: processedImage.extent) else {
            return nil
        }

        return UIImage(cgImage: outputCGImage)
    }
}

private extension CIFilter {
    func apply(_ configuration: (CIFilter) -> Void) -> CIFilter {
        configuration(self)
        return self
    }
}