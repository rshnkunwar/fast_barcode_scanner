import AVFoundation

class Camera: NSObject {

  // MARK: Session Management

  let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "fast_barcode_scanner.session.serial")
  private var deviceInput: AVCaptureDeviceInput!
  private var captureDevice: AVCaptureDevice { deviceInput.device }
  private var scanner: BarcodeScanner

  private(set) var targetConfiguration: CameraConfiguration
  private(set) var cameraInformation: CameraInformation!

  private var wasUsingTorch = false
    
  init(configuration: CameraConfiguration, scanner: BarcodeScanner) async throws {
    self.scanner = scanner
    self.targetConfiguration = configuration
    super.init()

    let authorizationGranted: Bool
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      authorizationGranted = true
    default:
        authorizationGranted = await AVCaptureDevice.requestAccess(for: .video)
    }

    if authorizationGranted {
      try self.configureSession(configuration: configuration)
      self.addObservers()
    } else {
      throw ScannerError.unauthorized
    }
  }

  deinit {
    removeObservers()
  }

  func configureSession(configuration: CameraConfiguration)  throws {
    let requestedDevice: AVCaptureDevice?

    // Grab the requested camera device, otherwise toggle the position and try again.
    if let device = AVCaptureDevice.default(
      .builtInWideAngleCamera,
      for: .video,
      position: configuration.position)
    {
      requestedDevice = device
    } else if let device = AVCaptureDevice.default(
      .builtInWideAngleCamera,
      for: .video,
      position: configuration.position == .back ? .front : .back)
    {
      requestedDevice = device
    } else {
      requestedDevice = nil
    }

    guard let device = requestedDevice else {
      throw ScannerError.noInputDeviceForConfig(configuration)
    }

    session.beginConfiguration()

    session.inputs.forEach(session.removeInput)

    let deviceInput = try AVCaptureDeviceInput(device: device)

    if session.canAddInput(deviceInput) {
      session.addInput(deviceInput)
      self.deviceInput = deviceInput
    } else {
      throw ScannerError.configurationError("Could not add video device input to session")
    }

    self.scanner.session = session

    self.scanner.symbologies = configuration.codes

    self.scanner.onDetection = { [unowned self] in
      switch configuration.detectionMode {
      case .pauseDetection:
        self.scanner.stop()
      case .pauseVideo:
          Task { await self.stop() }
      case .continuous: break
      }
    }

    session.commitConfiguration()

    // Find the optimal settings for the requested resolution and frame rate.
    guard
      let optimalFormat = captureDevice.formats.first(where: {
        let dimensions = CMVideoFormatDescriptionGetDimensions($0.formatDescription)
        let mediaSubType = CMFormatDescriptionGetMediaSubType($0.formatDescription).toString()

        return $0.videoSupportedFrameRateRanges.first!.maxFrameRate
          >= configuration.framerate.numberValue
          && dimensions.height >= configuration.resolution.size.width
          && dimensions.width >= configuration.resolution.size.width
          && mediaSubType == "420f"  // maybe 420v is also ok? Who knows...
      })
    else {
      throw ScannerError.cameraNotSuitable(configuration.resolution, configuration.framerate)
    }

    do {
      try captureDevice.lockForConfiguration()
      captureDevice.activeFormat = optimalFormat
      captureDevice.activeVideoMaxFrameDuration =
        optimalFormat.videoSupportedFrameRateRanges.first!.minFrameDuration
      captureDevice.unlockForConfiguration()
    } catch {
      throw ScannerError.configurationError(error.localizedDescription)
    }

    self.targetConfiguration = configuration

    let videoSize = CMVideoFormatDescriptionGetDimensions(
      captureDevice.activeFormat.formatDescription
    )

    self.cameraInformation = CameraInformation(
      videoWidth: videoSize.width, videoHeight: videoSize.height,
      analysisWidth: videoSize.width, analysisHeight: videoSize.height
    )
  }

  func start() async throws {
    guard !session.isRunning else {
      return
    }

    scanner.start()
      
      let task = Task {
          self.session.startRunning()
      }
      await task.value

    if wasUsingTorch {
      try toggleTorch()
    }
  }

  func stop() async {
    guard session.isRunning else {
      return
    }

    wasUsingTorch = captureDevice.isTorchActive
      
      let task = Task {
          self.session.stopRunning()
      }
      await task.value
  }

  @discardableResult
  func toggleTorch() throws -> Bool {
    guard captureDevice.isTorchAvailable else { return false }

    try captureDevice.lockForConfiguration()
    captureDevice.torchMode = captureDevice.isTorchActive ? .off : .on
    captureDevice.unlockForConfiguration()

    return captureDevice.torchMode == .on
  }

  func startScanner() {
    scanner.start()
  }

  func stopScanner() {
    scanner.stop()
  }

  // MARK: KVO and Notifications

  func addObservers() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError,
      object: session)
  }

  func removeObservers() {
    NotificationCenter.default.removeObserver(
      self, name: .AVCaptureSessionRuntimeError, object: session)
  }

  // MARK: AVError handling

  @objc
  func sessionRuntimeError(notification: NSNotification) {
    guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }

    // Try to restart, if session was running
    if error.code == .mediaServicesWereReset && session.isRunning {
      self.session.startRunning()
    }
  }
}
