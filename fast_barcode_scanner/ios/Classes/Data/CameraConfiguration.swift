import AVFoundation
import Vision

struct CameraConfiguration {

  init(
    position: AVCaptureDevice.Position,
    framerate: Framerate,
    resolution: Resolution,
    mode: DetectionMode,
    codes: [String],
    apiOptions: ApiOptions
  ) {
    self.position = position
    self.framerate = framerate
    self.resolution = resolution
    detectionMode = mode
    self.codes = codes
    self.apiOptions = apiOptions
  }

  init?(_ args: Any?) {
    guard
      let dict = args as? [String: Any],
      let position = cameraPositions[dict["pos"] as? String ?? ""],
      let resolution = Resolution(rawValue: dict["res"] as? String ?? ""),
      let framerate = Framerate(rawValue: dict["fps"] as? String ?? ""),
      let detectionMode = DetectionMode(rawValue: dict["mode"] as? String ?? ""),
      let codes = dict["types"] as? [String],
      let api = dict["api"] as? String,
      let options = dict["options"] as? [String: Any]
    else {
      return nil
    }

    let apiOptions: ApiOptions
    switch api {
    case "avfoundation":
      apiOptions = .avFoundation
    case "vision":
      guard let confidence = options["confidence"] as? Float else {
        return nil
      }

      apiOptions = .vision(confidence: confidence)
    default:
      return nil
    }

    self.init(
      position: position,
      framerate: framerate,
      resolution: resolution,
      mode: detectionMode,
      codes: codes,
      apiOptions: apiOptions
    )
  }

  let position: AVCaptureDevice.Position
  let framerate: Framerate
  let resolution: Resolution
  let detectionMode: DetectionMode
  let codes: [String]
  let apiOptions: ApiOptions

  func copy(with args: Any?) -> CameraConfiguration? {
    guard let dict = args as? [String: Any] else {
      return nil
    }

    var apiOptions: ApiOptions? = nil
    if let api = dict["api"] as? String, let options = dict["options"] as? [String: Any] {
      switch api {
      case "avfoundation":
        apiOptions = .avFoundation
      case "vision":
        guard let confidence = options["confidence"] as? Float else {
          return nil
        }

        apiOptions = .vision(confidence: confidence)
      default:
        return nil
      }
    }

    return CameraConfiguration.init(
      position: cameraPositions[dict["pos"] as? String ?? ""] ?? position,
      framerate: Framerate(rawValue: dict["fps"] as? String ?? "") ?? framerate,
      resolution: Resolution(rawValue: dict["res"] as? String ?? "") ?? resolution,
      mode: DetectionMode(rawValue: dict["mode"] as? String ?? "") ?? detectionMode,
      codes: dict["types"] as? [String] ?? codes,
      apiOptions: apiOptions ?? self.apiOptions
    )
  }
}

// Flutter -> AVFoundation
let avMetadataObjectTypes: [String: AVMetadataObject.ObjectType] =
  [
    "aztec": .aztec,
    "code128": .code128,
    "code39": .code39,
    "code39mod43": .code39Mod43,
    "code93": .code93,
    "dataMatrix": .dataMatrix,
    "ean13": .ean13,
    "ean8": .ean8,
    "itf": .itf14,
    "pdf417": .pdf417,
    "qr": .qr,
    "upcE": .upce,
    "interleaved": .interleaved2of5,
  ]

// Flutter -> Vision
let vnBarcodeSymbols: [String: VNBarcodeSymbology] =
  [
    "aztec": .aztec,
    "code128": .code128,
    "code39": .code39,  // Which one?
    "code93": .code93,  // Which one?
    "dataMatrix": .dataMatrix,
    "ean13": .ean13,
    "ean8": .ean8,
    "itf": .itf14,
    "pdf417": .pdf417,
    "qr": .qr,
    "upcE": .upce,
    "interleaved": .i2of5,  // Which one?
  ]

// AVFoundation -> Flutter
let flutterMetadataObjectTypes = Dictionary(
  uniqueKeysWithValues: avMetadataObjectTypes.map { ($1, $0) })

// Vision -> Flutter
let flutterVNSymbols = Dictionary(uniqueKeysWithValues: vnBarcodeSymbols.map { ($1, $0) })

let cameraPositions: [String: AVCaptureDevice.Position] =
  [
    "front": .front,
    "back": .back,
  ]

enum Resolution: String {
  case sd480, hd720, hd1080, hd4k

  var size: (width: Int32, height: Int32) {
    switch self {
    case .sd480: return (720, 480)
    case .hd720: return (1280, 720)
    case .hd1080: return (1920, 1080)
    case .hd4k: return (3840, 2160)
    }
  }
}

enum Framerate: String {
  case fps30, fps60, fps120, fps240

  var numberValue: Double {
    switch self {
    case .fps30: return 30
    case .fps60: return 60
    case .fps120: return 120
    case .fps240: return 240
    }
  }
}

enum DetectionMode: String {
  case pauseDetection, pauseVideo, continuous
}

enum ApiOptions {
  case avFoundation
  case vision(confidence: Float)
}
