import AVFoundation
import VisionKit
import Flutter

public class FastBarcodeScannerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  let commandChannel: FlutterMethodChannel
  let barcodeEventChannel: FlutterEventChannel
  let factory: PreviewViewFactory

  var camera: Camera?
  var picker: ImagePicker?
  var detectionsSink: FlutterEventSink?

  init(
    commands: FlutterMethodChannel,
    events: FlutterEventChannel,
    factory: PreviewViewFactory
  ) {
    commandChannel = commands
    barcodeEventChannel = events
    self.factory = factory
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let commandChannel = FlutterMethodChannel(
      name: "com.jhoogstraat/fast_barcode_scanner",
      binaryMessenger: registrar.messenger()
    )

    let barcodeEventChannel = FlutterEventChannel(
      name: "com.jhoogstraat/fast_barcode_scanner/detections",
      binaryMessenger: registrar.messenger()
    )

    let instance = FastBarcodeScannerPlugin(
      commands: commandChannel,
      events: barcodeEventChannel,
      factory: PreviewViewFactory()
    )

    registrar.register(instance.factory, withId: "fast_barcode_scanner.preview")
    registrar.addMethodCallDelegate(instance, channel: commandChannel)
    barcodeEventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    Task {
      do {
        var response: Any?

        switch call.method {
        case "init": response = try await initialize(args: call.arguments).serialized
        case "start": try await start()
        case "stop": try await stop()
        case "startScanner": try startScanner()
        case "stopScanner": try stopScanner()
        case "torch": response = try toggleTorch()
        case "config": response = try updateConfiguration(call: call).serialized
        case "scan": response = try await analyzeImage(args: call.arguments)
        case "dispose": dispose()
        default: response = FlutterMethodNotImplemented
        }

        result(response)
      } catch {
        print(call.method, error)
        result(error.flutterError)
      }
    }
  }

  func initialize(args: Any?) async throws -> CameraInformation {
    guard camera == nil else {
      throw ScannerError.alreadyInitialized
    }

    guard let cameraConfiguration = CameraConfiguration(args) else {
      throw ScannerError.invalidArguments(args)
    }

    let scanner: BarcodeScanner
    switch cameraConfiguration.apiOptions {
    case .avFoundation:
      scanner = AVFoundationBarcodeScanner { [unowned self] barcodes in
        self.factory.preview?.videoPreviewLayer.transformedMetadataObject(for: barcodes)
      } resultHandler: { [unowned self] barcodes in
        self.detectionsSink?(barcodes)
      }
    case .vision(let confidence):
      scanner = VisionBarcodeScanner(confidence: confidence) { observation in
        self.factory.preview?.videoPreviewLayer.layerRectConverted(
          fromMetadataOutputRect: observation.boundingBox)
      } resultHandler: { [unowned self] result in
        self.detectionsSink?(result)
      }
    }

    let camera = try await Camera(configuration: cameraConfiguration, scanner: scanner)

    factory.session = camera.session

    try await camera.start()

    self.camera = camera

    return camera.cameraInformation
  }

  func start() async throws {
    guard let camera = camera else {
      throw ScannerError.notInitialized
    }
    try await camera.start()
  }

  func stop() async throws {
    guard let camera = camera else {
      throw ScannerError.notInitialized
    }
    await camera.stop()
  }

  func dispose() {
      if !(camera?.session.isRunning ?? false) {
          camera = nil
      }
  }

  func startScanner() throws {
    guard let camera = camera else {
      throw ScannerError.notInitialized
    }
    camera.startScanner()
  }

  func stopScanner() throws {
    guard let camera = camera else {
      throw ScannerError.notInitialized
    }
    camera.stopScanner()
  }

  func toggleTorch() throws -> Bool {
    guard let camera = camera else {
      throw ScannerError.notInitialized
    }
    return try camera.toggleTorch()
  }

  func updateConfiguration(call: FlutterMethodCall) throws -> CameraInformation {
    guard let camera = camera else {
      throw ScannerError.notInitialized
    }

    guard let config = camera.targetConfiguration.copy(with: call.arguments) else {
      throw ScannerError.invalidArguments(call.arguments)
    }

    try camera.configureSession(configuration: config)

    return camera.cameraInformation
  }

  func analyzeImage(args: Any?) async throws -> Any? {
    let image: UIImage?

    if let container = args as? [Any] {
      guard
        let byteBuffer = container[0] as? FlutterStandardTypedData
      else {
        throw ScannerError.loadingDataFailed
      }

      image = UIImage(data: byteBuffer.data)
    } else {
      guard let root = await UIApplication.shared.delegate?.window??.rootViewController else {
        return nil
      }

      let picker: ImagePicker
      if #available(iOS 14, *) {
        picker = await PHImagePicker()
      } else {
        picker = await UIImagePicker()
      }

      image = await picker.show(over: root)
    }

    guard let uiImage = image,
      let cgImage = uiImage.cgImage
    else {
      throw ScannerError.loadingDataFailed
    }
    
    return try await withCheckedThrowingContinuation { (continuation) in
        do {
            let scanner = VisionBarcodeScanner(confidence: 0.6, resultHandler: continuation.resume)
            try scanner.process(cgImage)
        } catch {
            continuation.resume(throwing: error)
        }
    }
  }
    
    @MainActor @available(iOS 16.0, *)
    func nativeScanner(args: Any?) {
        let nativeScanner = DataScannerViewController(recognizedDataTypes: [.barcode(symbologies: [.ean8, .ean13, .code128])], qualityLevel: .balanced, recognizesMultipleItems: true, isHighFrameRateTrackingEnabled: true, isPinchToZoomEnabled: true, isGuidanceEnabled: true, isHighlightingEnabled: true)
        
        
    }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    detectionsSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    detectionsSink = nil
    return nil
  }
}


