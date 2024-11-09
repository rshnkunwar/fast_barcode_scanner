import 'package:fast_barcode_scanner_platform_interface/src/types/image_source.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_fast_barcode_scanner.dart';
import 'types/barcode.dart';
import 'types/barcode_type.dart';
import 'types/camera_information.dart';

/// A callback that receives all uniquely scanned barcodes in an image.
typedef OnDetectionHandler = void Function(List<Barcode>);

/// The interface for implementations of fast_barcode_scanner.
///
/// Platform implementations should `extend` this class
/// rather than to `implement` it. This ensures that the subclass
/// gets the default implementations.
abstract class FastBarcodeScannerPlatform extends PlatformInterface {
  FastBarcodeScannerPlatform() : super(token: _token);

  static const Object _token = Object();

  static FastBarcodeScannerPlatform _instance =
      MethodChannelFastBarcodeScanner();

  /// The instance of [FastBarcodeScannerPlatform] in use.
  ///
  /// Defaults to [MethodChannelFastBarcodeScanner].
  static FastBarcodeScannerPlatform get instance => _instance;

  /// Platform specific plugins should set this with their own platform-specific
  /// class that extends [FastBarcodeScannerPlatform] when they register themselves.
  static set instance(FastBarcodeScannerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes and starts the native camera interface.
  ///
  /// Returns the [CameraInformation] the camera is setup with.
  Future<CameraInformation> init(
    List<BarcodeType> types,
    Resolution resolution,
    Framerate framerate,
    DetectionMode detectionMode,
    CameraPosition position,
    ApiOptions api,
  ) {
    throw UnimplementedError('Missing init() implementation');
  }

  /// Starts the camera and detector, if in stopped state.
  ///
  /// TODO: What is the final camera state?
  Future<void> start() {
    throw UnimplementedError('Missing start() implementation');
  }

  /// Stops the camera and detector, if in running state.
  ///
  /// TODO: What is the final camera state?
  Future<void> stop() {
    throw UnimplementedError('Missing stop() implementation');
  }

  /// Starts the detector, if it was paused.
  ///
  /// TODO: What happens when camera is stopped?
  Future<void> startDetector() {
    throw UnimplementedError('Missing startDetector() implementation');
  }

  /// Stops the detector, if it was running.
  ///
  /// The camera and preview keep running.
  Future<void> stopDetector() {
    throw UnimplementedError('Missing stopDetector() implementation');
  }

  /// Stops and clears the camera resources.
  ///
  /// TODO: What happens to the platform interface?
  Future<void> dispose() {
    throw UnimplementedError('Missing dispose() implementation');
  }

  /// Toggles the torch, if available.
  Future<bool> toggleTorch() {
    throw UnimplementedError('Missing toggleTorch() implementation');
  }

  /// Changes the underlying camera configuration.
  ///
  /// `null` values stay unchanged.
  Future<CameraInformation> changeConfiguration({
    List<BarcodeType>? types,
    Resolution? resolution,
    Framerate? framerate,
    DetectionMode? detectionMode,
    CameraPosition? position,
  }) {
    throw UnimplementedError('Missing changeConfiguration() implementation');
  }

  /// Set the method to be called when a barcode is detected.
  void setOnDetectionHandler(OnDetectionHandler handler) {
    throw UnimplementedError('Missing setOnDetectionHandler() implementation');
  }

  ///
  Future<List<Barcode>?> scanImage(ImageSource source) {
    throw UnimplementedError('Missing scanImage() implementation');
  }
}
