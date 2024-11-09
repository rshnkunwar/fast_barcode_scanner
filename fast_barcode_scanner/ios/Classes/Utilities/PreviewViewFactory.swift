import AVFoundation
import VisionKit
import Flutter

class PreviewViewFactory: NSObject, FlutterPlatformViewFactory {
  var session: AVCaptureSession?

  var preview: PreviewView?

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView
  {
    let view = PreviewView(frame: frame)
    view.session = session
    preview = view
    return view
  }
}

@available(iOS 16, *)
class NativeScannerViewFactory: NSObject, FlutterPlatformViewFactory {
    @MainActor func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
        return NativeScannerViewController(frame: frame)
    }
}

@available(iOS 16.0, *)
class NativeScannerViewController: NSObject, FlutterPlatformView {
    var controller: DataScannerViewController
    
    @MainActor
    init(frame: CGRect) {
        controller = DataScannerViewController(recognizedDataTypes: [.barcode(symbologies: [.ean8, .ean13, .code128])], qualityLevel: .balanced, recognizesMultipleItems: true, isHighFrameRateTrackingEnabled: true, isPinchToZoomEnabled: true, isGuidanceEnabled: true, isHighlightingEnabled: true)
        controller.loadViewIfNeeded()
        controller.view.frame = frame
    
    }
    
    func view() -> UIView {
        controller.view
    }
    
}
