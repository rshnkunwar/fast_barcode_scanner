import 'package:fast_barcode_scanner_platform_interface/fast_barcode_scanner_platform_interface.dart';

/// The configuration of the camera and scanner.
///
/// Holds detailed information about the running camera session.
class ScannerConfiguration {
  const ScannerConfiguration(
    this.types,
    this.mode,
    this.position,
    this.detectionMode,
  );

  /// The types the scanner should look out for.
  ///
  /// If a barcode type is not in this list, it will not be detected.
  final List<BarcodeType> types;

  /// The target mode of the camera.
  final PerformanceMode mode;

  /// The physical position of the camera being used.
  final CameraPosition position;

  /// Determines how the camera reacts to detected barcodes.
  final DetectionMode detectionMode;

  ScannerConfiguration copyWith({
    List<BarcodeType>? types,
    PerformanceMode? mode,
    DetectionMode? detectionMode,
    CameraPosition? position,
  }) {
    return ScannerConfiguration(
      types ?? this.types,
      mode ?? this.mode,
      position ?? this.position,
      detectionMode ?? this.detectionMode,
    );
  }
}
