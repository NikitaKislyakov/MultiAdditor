//
//  DocumentPicker.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 07.06.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    let gifData: Data
    let suggestedName: String

    func makeCoordinator() -> Coordinator {
        Coordinator(gifData: gifData, suggestedName: suggestedName)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedName)

        // Записываем GIF во временный файл
        try? gifData.write(to: tempURL)

        let picker = UIDocumentPickerViewController(forExporting: [tempURL], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let gifData: Data
        let suggestedName: String

        init(gifData: Data, suggestedName: String) {
            self.gifData = gifData
            self.suggestedName = suggestedName
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("User cancelled export")
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("Exported to: \(urls.first?.absoluteString ?? "unknown")")
        }
    }
}
