// SessionStore.swift
// DoceriWhiteboard
//
// ObservableObject: owns all mutable app state, multi-page store, autosave.

import SwiftUI
import PencilKit
import Combine

final class SessionStore: ObservableObject {

    @Published var pages: [PKDrawing] = [PKDrawing()]
    @Published var currentPageIndex: Int = 0

    weak var canvas: PKCanvasView?
    var toolPicker: PKToolPicker?

    private let autosaveURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("session.dw")
    }()

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadSession()
        setupAutosave()
    }

    func addPage() {
        pages.append(PKDrawing())
        currentPageIndex = pages.count - 1
    }

    func deletePage(at index: Int) {
        guard pages.count > 1 else { return }
        pages.remove(at: index)
        currentPageIndex = max(0, min(currentPageIndex, pages.count - 1))
    }

    func clearCanvas() {
        pages[currentPageIndex] = PKDrawing()
        canvas?.drawing = PKDrawing()
    }

    func importPDFPages(_ images: [UIImage]) {
        // Sprint 2: attach images as background layers.
        let newPages = images.map { _ in PKDrawing() }
        pages.append(contentsOf: newPages)
    }

    private func setupAutosave() {
        $pages
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.saveSession() }
            .store(in: &cancellables)
    }

    private func saveSession() {
        do {
            let data = try StrokeSerializer.encode(pages: pages)
            try data.write(to: autosaveURL, options: .atomic)
        } catch { print("[SessionStore] Save failed: \(error)") }
    }

    private func loadSession() {
        guard FileManager.default.fileExists(atPath: autosaveURL.path) else { return }
        do {
            let data = try Data(contentsOf: autosaveURL)
            pages = try StrokeSerializer.decode(data: data)
        } catch { print("[SessionStore] Load failed, starting fresh: \(error)") }
    }
}
