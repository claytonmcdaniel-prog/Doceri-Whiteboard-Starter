// ExportManager.swift
// DoceriWhiteboard
//
// Renders PKCanvasView to UIImage or PDF, provides SwiftUI export sheet.

import SwiftUI
import PencilKit
import PDFKit

enum ExportManager {

    static func renderToImage(canvas: PKCanvasView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: canvas.bounds)
        return renderer.image { ctx in
            canvas.drawHierarchy(in: canvas.bounds, afterScreenUpdates: true)
        }
    }

    static func renderToPDF(images: [UIImage], pageSize: CGSize = CGSize(width: 792, height: 612)) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return pdfRenderer.pdfData { ctx in
            for image in images {
                ctx.beginPage()
                image.draw(in: CGRect(origin: .zero, size: pageSize))
            }
        }
    }

    static func exportStrokesJSON(pages: [PKDrawing]) throws -> Data {
        try StrokeSerializer.encode(pages: pages)
    }
}

struct ExportSheet: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(uiImage: image)
                    .resizable().scaledToFit()
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12).padding()
                Button { shareImage(image) } label: {
                    Label("Share / Save", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .navigationTitle("Export Page")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func shareImage(_ image: UIImage) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = windowScene.windows.first?.rootViewController else { return }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        root.present(vc, animated: true)
    }
}
