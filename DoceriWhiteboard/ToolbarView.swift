// ToolbarView.swift
// DoceriWhiteboard
//
// Compact iPad toolbar: page nav, undo/redo, clear, export, PDF import.

import SwiftUI

struct ToolbarView: View {
    let onUndo:       () -> Void
    let onRedo:       () -> Void
    let onClear:      () -> Void
    let onExport:     () -> Void
    let onImportPDF:  () -> Void
    let onNewPage:    () -> Void
    let onPageChange: (Int) -> Void
    let pageCount:    Int
    let currentPage:  Int
    @State private var showClearConfirm = false

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onNewPage) { Label("New Page", systemImage: "plus.rectangle") }
            Divider().frame(height: 24)
            Button(action: { if currentPage > 0 { onPageChange(currentPage - 1) } }) {
                Image(systemName: "chevron.left")
            }.disabled(currentPage == 0)
            Text("Page \(currentPage + 1) / \(pageCount)")
                .font(.caption).monospacedDigit().frame(minWidth: 80)
            Button(action: { if currentPage < pageCount - 1 { onPageChange(currentPage + 1) } }) {
                Image(systemName: "chevron.right")
            }.disabled(currentPage >= pageCount - 1)
            Divider().frame(height: 24)
            Button(action: onUndo) { Image(systemName: "arrow.uturn.backward") }
                .keyboardShortcut("z", modifiers: .command)
            Button(action: onRedo) { Image(systemName: "arrow.uturn.forward") }
                .keyboardShortcut("z", modifiers: [.command, .shift])
            Divider().frame(height: 24)
            Button(role: .destructive) { showClearConfirm = true } label: {
                Image(systemName: "trash")
            }
            .confirmationDialog("Clear this page?", isPresented: $showClearConfirm, titleVisibility: .visible) {
                Button("Clear Page", role: .destructive, action: onClear)
                Button("Cancel", role: .cancel) {}
            }
            Button(action: onImportPDF) { Image(systemName: "doc.badge.plus") }
            Button(action: onExport)    { Image(systemName: "square.and.arrow.up") }
            Spacer()
            Text("DoceriWhiteboard").font(.headline).foregroundColor(.secondary).padding(.trailing, 8)
        }
        .padding(.horizontal, 16)
        .background(Material.bar)
        .buttonStyle(.borderless)
    }
}
