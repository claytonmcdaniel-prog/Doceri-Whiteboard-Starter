// StrokeSerializer.swift
// DoceriWhiteboard
//
// Encodes / decodes an array of PKDrawing to/from JSON-compatible Data
// using PKDrawing's built-in data(forEncoding:) API.
// The outer envelope is a simple JSON array of Base64 strings so the
// format is human-inspectable and easy to sync to a backend later.

import Foundation
import PencilKit

enum StrokeSerializer {

      // MARK: - Errors

      enum SerializerError: LocalizedError {
                case encodingFailed(Int)
                case decodingFailed(Int)
                case invalidEnvelope

                var errorDescription: String? {
                              switch self {
                                            case .encodingFailed(let i):   return "Failed to encode drawing at index \(i)."
                                            case .decodingFailed(let i):   return "Failed to decode drawing at index \(i)."
                                            case .invalidEnvelope:         return "Session data envelope is malformed."
                              }
                }
      }

      // MARK: - Encode

      /// Encode an array of PKDrawing to JSON Data (array of Base64 strings).
      static func encode(pages: [PKDrawing]) throws -> Data {
                let base64Pages: [String] = try pages.enumerated().map { (i, drawing) in
                                                                                    do {
                                                                                                      let drawingData = try drawing.dataRepresentation()
                                                                                                      return drawingData.base64EncodedString()
                                                                                    } catch {
                                                                                                      throw SerializerError.encodingFailed(i)
                                                                                    }
                                                                       }
                let envelope = SessionEnvelope(version: 1, pages: base64Pages)
                return try JSONEncoder().encode(envelope)
      }

      // MARK: - Decode

      /// Decode JSON Data to array of PKDrawing.
      static func decode(data: Data) throws -> [PKDrawing] {
                let envelope: SessionEnvelope
                do {
                              envelope = try JSONDecoder().decode(SessionEnvelope.self, from: data)
                } catch {
                              throw SerializerError.invalidEnvelope
                }

                return try envelope.pages.enumerated().map { (i, base64) in
                                                                        guard let drawingData = Data(base64Encoded: base64) else {
                                                                                          throw SerializerError.decodingFailed(i)
                                                                        }
                                                                        do {
                                                                                          return try PKDrawing(data: drawingData)
                                                                        } catch {
                                                                                          throw SerializerError.decodingFailed(i)
                                                                        }
                                                           }
      }

      // MARK: - Private Types

      private struct SessionEnvelope: Codable {
                let version: Int
                let pages: [String]   // Base64-encoded PKDrawing data per page
      }
}
