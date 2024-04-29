import 'package:flutter/foundation.dart';

/// Supported resolutions. Not all devices support all resolutions!
enum Resolution { sd480, hd720, hd1080, hd4k }

/// Supported Framerates. Not all devices support all framerates!
enum Framerate { fps30, fps60, fps120, fps240 }

/// Dictates how the camera reacts to detections
enum DetectionMode {
  /// Pauses the detection of further barcodes when a barcode is detected.
  /// The camera feed continues.
  pauseDetection,

  /// Pauses the camera feed on detection.
  /// This will inevitably stop the detection of barcodes.
  pauseVideo,

  /// Does nothing on detection. May need to throttle detections using continuous.
  continuous
}

/// The position of the camera.
enum CameraPosition { front, back }

/// The configuration by which the camera feed can be laid out in the UI.
class PreviewConfiguration {
  /// The width of the camera feed in points.
  final int width;

  /// The height of the camera feed in points.
  final int height;

  /// Expresses how many quarters the texture has to be rotated to be upright
  /// in clockwise direction.
  final int targetRotation;

  /// A id of a texture which contains the camera feed.
  ///
  /// Can be consumed by a [Texture] widget.
  final int textureId;

  /// The resolution which is used when scanning for barcodes.
  late final String analysisResolution;

  /// The width of the image used for analysis. This may be different than the preview width
  final int analysisWidth;

  /// The height of the image used for analysis. This may be different than the preview height
  final int analysisHeight;

  PreviewConfiguration(Map<dynamic, dynamic> response)
      : textureId = response["textureId"],
        targetRotation = response["targetRotation"],
        height = response["height"],
        width = response["width"],
        analysisWidth = response["analysisWidth"],
        analysisHeight = response["analysisHeight"] {
    analysisResolution = "${analysisWidth}x$analysisHeight";
  }

  @override
  bool operator ==(Object other) =>
      other is PreviewConfiguration &&
      other.textureId == textureId &&
      other.height == height &&
      other.width == width &&
      other.targetRotation == targetRotation &&
      other.analysisResolution == analysisResolution &&
      other.analysisWidth == analysisWidth &&
      other.analysisHeight == analysisHeight;

  @override
  int get hashCode =>
      super.hashCode ^
      textureId.hashCode ^
      height.hashCode ^
      width.hashCode ^
      targetRotation.hashCode ^
      analysisResolution.hashCode ^
      analysisWidth.hashCode ^
      analysisHeight.hashCode;

  @override
  String toString() {
    return 'PreviewConfiguration{width: $width, height: $height, targetRotation: $targetRotation, textureId: $textureId, analysisResolution: $analysisResolution, analysisWidth: $analysisWidth, analysisHeight: $analysisHeight}';
  }
}

abstract class ApiMode {
  const ApiMode();

  String get name;

  Map<String, dynamic> get configMap => {
        "apiMode": name,
        ...config,
      };

  Map<String, dynamic> get config => {};
}

class AppleApiMode extends ApiMode {
  @override
  final String name;

  @override
  final Map<String, dynamic> config;

  const AppleApiMode.avFoundation()
      : name = "avFoundation",
        config = const {};

  AppleApiMode.vision(double confidence)
      : name = "vision",
        config = {"confidence": clampDouble(confidence, 0, 1)};
}
