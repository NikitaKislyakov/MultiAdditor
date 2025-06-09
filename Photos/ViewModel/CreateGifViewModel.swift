//
//  CreateGifViewModel.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 07.06.2025.
//

import Foundation
import AVFoundation
import PhotosUI
import UniformTypeIdentifiers
import SwiftUI
import MobileCoreServices
import Photos

enum CurrentView {
    case pickVideo
    case trimVideo
    case previewGif
}

class CreateGifViewModel: ObservableObject {

    @Published var selectedVideo: PhotosPickerItem? = nil
    @Published var videoURL: URL? = nil
    @Published var gifURL: URL? = nil
    @Published var isProcessing: Bool = false
    @Published var startTime: Double = 0.0
    @Published var endTime: Double = 0.0

    @Published var currentView: CurrentView = .pickVideo

    func loadVideo(item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let data):
                if let data = data {
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempVideo.mov")
                    do {
                        try data.write(to: tempURL)
                        DispatchQueue.main.async {
                            self.videoURL = tempURL
                            self.startTime = 0
                            self.endTime = self.videoDuration(for: tempURL) ?? 0
                            self.currentView = .trimVideo
                        }
                    } catch {
                        print("Не удалось сохранить видео: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Ошибка загрузки видео: \(error.localizedDescription)")
            }
        }
    }

    func videoDuration(for url: URL) -> Double? {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }

    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { _ in }
        }
    }

    func trimAndConvertToGif() {
        guard let videoURL else { return }
        isProcessing = true
        gifURL = nil
        let asset = AVAsset(url: videoURL)
        let startTime = CMTime(seconds: self.startTime, preferredTimescale: 600)
        let endTime = CMTime(seconds: self.endTime, preferredTimescale: 600)
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.gif")

        DispatchQueue.global(qos: .userInitiated).async {
            let exporter = AVAssetImageGenerator(asset: asset)
            exporter.appliesPreferredTrackTransform = true
            exporter.requestedTimeToleranceAfter = .zero
            exporter.requestedTimeToleranceBefore = .zero

            let frameRate = 30.0
            let duration = CMTimeGetSeconds(timeRange.duration)
            let frameCount = max(1, Int(duration * frameRate))
            var frames: [CGImage] = []
            for i in 0..<frameCount {
                let time = CMTime(seconds: Double(i) / frameRate + CMTimeGetSeconds(startTime), preferredTimescale: 600)
                do {
                    let image = try exporter.copyCGImage(at: time, actualTime: nil)
                    frames.append(image)
                } catch {
                    print("Ошибка кадра \(i): \(error.localizedDescription)")
                }
            }
            guard !frames.isEmpty else {
                DispatchQueue.main.async { self.isProcessing = false }
                return
            }
            guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, kUTTypeGIF, frames.count, nil) else {
                DispatchQueue.main.async { self.isProcessing = false }
                return
            }
            let frameProperties = [
                kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1.0 / frameRate]
            ]
            let gifProperties = [
                kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]
            ]
            CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
            for frame in frames {
                CGImageDestinationAddImage(destination, frame, frameProperties as CFDictionary)
            }
            if CGImageDestinationFinalize(destination) {
                DispatchQueue.main.async {
                    self.gifURL = outputURL
                    self.currentView = .previewGif
                    self.isProcessing = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
            }
        }
    }

    func generateGifFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return "gif_\(formatter.string(from: Date())).gif"
    }
}
