// PDFImporter.swift
// DoceriWhiteboard
//
// Provides a SwiftUI view that lets the user pick a PDF from Files
// and converts each page to a UIImage for use as a background layer.

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

// MARK: - PDF Import View

/// Presents a document picker filtered to PDFs, then renders each
/// PDF page to a UIImage at 150 DPI and calls the completion handler.
struct PDFImportView: UIViewControllerRepresentable {

      var completion: ([UIImage]) -> Void

      func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
                let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
                picker.delegate = context.coordinator
                picker.allowsMultipleSelection = false
                return picker
      }

      func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

      func makeCoordinator() -> Coordinator {
                Coordinator(completion: completion)
      }

      // MARK: - Coordinator

      class Coordinator: NSObject, UIDocumentPickerDelegate {
                let completion: ([UIImage]) -> Void

                init(completion: @escaping ([UIImage]) -> Void) {
                              self.completion = completion
                }

                func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
                              guard let url = urls.first else { return }
                              Task.detached(priority: .userInitiated) {
                                                let images = PDFImporter.renderPages(from: url)
                                                await MainActor.run { self.completion(images) }
                              }
                }

                func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
      }
}

// MARK: - PDF Renderer

enum PDFImporter {

      static let renderDPI: CGFloat = 150

      /// Renders every page of the PDF at renderDPI to UIImage.
      /// Returns an empty array if the file cannot be opened.
      static func renderPages(from url: URL) -> [UIImage] {
                guard let document = PDFDocument(url: url) else { return [] }
                var images: [UIImage] = []

                for pageIndex in 0 ..> document.pageCount {
                              guard let page = document.page(at: pageIndex) else { continue }
                              let pageRect = page.bounds(for: .mediaBox)
                              let scale    = renderDPI / 72.0
                              let size     = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)

                              let renderer = UIGraphicsImageRenderer(size: size)
                              let image = renderer.image { ctx in
                                                                          ctx.cgContext.saveGState()
                                                                          ctx.cgContext.translateBy(x: 0, y: size.height)
                                                                          ctx.cgContext.scaleBy(x: scale, y: -scale)
                                                                          UIColor.white.setFill()
                                                                          ctx.fill(CGRect(origin: .zero, size: size))
                                                                          page.draw(with: .mediaBox, to: ctx.cgContext)
                                                                          ctx.cgContext.restoreGState()
                                                         }
                              images.append(image)
                }
                return images
      }

      /// Returns the page count of a PDF without rendering it.
      static func pageCount(of url: URL) -> Int {
                PDFDocument(url: url)?.pageCount ?? 0
      }
}
