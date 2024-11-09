//
//  NativeDataScanner.swift
//  fast_barcode_scanner
//
//  Created by HOOGSTRAAT, JOSHUA on 08.05.24.
//

import AVFoundation
import VisionKit

@available(iOS 16, *)
@MainActor
class NativeDataScanner: BarcodeScanner, DataScannerViewControllerDelegate {
  let scanner: DataScannerViewController

  var session: AVCaptureSession? = nil

  var symbologies: [String] = []

  var onDetection: (() -> Void)?

  func start() {
    do {
      try scanner.startScanning()
    } catch {
      print(error)
    }
  }

  func stop() {
    scanner.stopScanning()
  }

  init() {
    scanner = DataScannerViewController(
      recognizedDataTypes: [.barcode(symbologies: [.ean13, .code128])], qualityLevel: .accurate,
      recognizesMultipleItems: true, isHighFrameRateTrackingEnabled: true,
      isPinchToZoomEnabled: true, isGuidanceEnabled: true, isHighlightingEnabled: true)
    scanner.delegate = self
  }

  func dataScanner(
    _ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem],
    allItems: [RecognizedItem]
  ) {
    onDetection?()
  }
}
