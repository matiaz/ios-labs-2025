//
//  TextExtractor.swift
//  invoice
//
//  Created by matiaz on 21/9/25.
//

import Vision
import UIKit
import Foundation
import Combine

class TextExtractor: ObservableObject {
    @Published var isProcessing = false
    @Published var extractedText = ""

    func extractText(from image: UIImage, completion: @escaping (String) -> Void) {
        isProcessing = true
        extractedText = ""

        guard let cgImage = image.cgImage else {
            isProcessing = false
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.isProcessing = false

                if let error = error {
                    print("Text recognition error: \(error)")
                    completion("")
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    completion("")
                    return
                }

                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                self?.extractedText = recognizedText
                completion(recognizedText)
            }
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    print("Failed to perform text recognition: \(error)")
                    completion("")
                }
            }
        }
    }
}