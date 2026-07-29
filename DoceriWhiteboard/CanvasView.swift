// CanvasView.swift
// DoceriWhiteboard
//
// UIViewRepresentable wrapper around PKCanvasView.
// Passes the canvas reference back to SessionStore so other
// views (toolbar, export) can interact with it.

import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {

    @Binding var drawing: PKDrawing
    @EnvironmentObject var session: SessionStore

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .white
        canvas.isOpaque = true
        canvas.alwaysBounceVertical = false
        canvas.delegate = context.coordinator

        let toolPicker = PKToolPicker()
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()

        session.canvas = canvas
        session.toolPicker = toolPicker

        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView
        init(_ parent: CanvasView) { self.parent = parent }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}
