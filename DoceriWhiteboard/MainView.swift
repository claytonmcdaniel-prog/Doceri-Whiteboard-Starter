// MainView.swift
// DoceriWhiteboard
//
// Root view: composes toolbar + canvas, handles import/export sheets.

import SwiftUI
import PencilKit

struct MainView: View {
    @EnvironmentObject var session: SessionStore
    @State private var showExportSheet = false
    @State private var showPDFImporter = false
    @State private var exportImage: UIImage? = nil

    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                ToolbarView(
                    onUndo:       { session.canvas?.undoManager?.undo() },
                    onRedo:       { session.canvas?.undoManager?.redo() },
                    onClear:      { session.clearCanvas() },
                    onExport:     { prepareExport() },
                    onImportPDF:  { showPDFImporter = true },
                    onNewPage:    { session.addPage() },
                    onPageChange: { session.currentPageIndex = $0 },
                    pageCount:    session.pages.count,
                    currentPage:  session.currentPageIndex
                )
                .frame(height: 56)
                CanvasView(drawing: currentDrawingBinding())
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .sheet(isPresented: $showExportSheet) {
            if let img = exportImage { ExportSheet(image: img) }
        }
        .sheet(isPresented: $showPDFImporter) {
            PDFImportView { pages in
                session.importPDFPages(pages)
                showPDFImporter = false
            }
        }
    }

    private func currentDrawingBinding() -> Binding<PKDrawing> {
        Binding(
            get: { session.pages[safe: session.currentPageIndex] ?? PKDrawing() },
            set: { session.pages[session.currentPageIndex] = $0 }
        )
    }

    private func prepareExport() {
        guard let canvas = session.canvas else { return }
        exportImage = ExportManager.renderToImage(canvas: canvas)
        showExportSheet = true
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
