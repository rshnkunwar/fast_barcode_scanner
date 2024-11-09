import 'dart:ui';

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
class CameraInformation {
  /// The height of the camera feed in points.
  final Size videoSize;

  /// The frame inside of `videoSize` where barcodes are detected.
  final Rect analysisFrame;

  CameraInformation(Map<dynamic, dynamic> response)
      : videoSize = Size(
          response["video_size"][0],
          response["video_size"][1],
        ),
        analysisFrame = Rect.fromLTWH(
          response["analysis_frame"][0],
          response["analysis_frame"][1],
          response["analysis_frame"][2],
          response["analysis_frame"][3],
        );

  @override
  bool operator ==(Object other) =>
      other is CameraInformation &&
      other.videoSize == videoSize &&
      other.analysisFrame == analysisFrame;

  @override
  int get hashCode => videoSize.hashCode ^ analysisFrame.hashCode;

  @override
  String toString() {
    return 'CameraInformation{videoSize: $videoSize, analysisFrame: $analysisFrame}';
  }
}

// abstract class ApiMode {
//   const ApiMode();

//   String get name;

//   Map<String, dynamic> get configMap => {
//         "apiMode": name,
//         ...config,
//       };

//   Map<String, dynamic> get config => {};
// }

sealed class AppleApiOption {
  const AppleApiOption();
  String get name;
  Map<String, dynamic> get options;
}

class AVFoundationApiOptions extends AppleApiOption {
  const AVFoundationApiOptions();

  @override
  String get name => "avfoundation";

  @override
  Map<String, dynamic> get options => {};
}

class VisionApiMode extends AppleApiOption {
  final double confidence;
  VisionApiMode({required double confidence})
      : confidence = clampDouble(confidence, 0, 1);

  @override
  String get name => "vision";

  @override
  Map<String, dynamic> get options => {'confidence': confidence};
}

enum AndroidApiOptions { mlKit }

class ApiOptions {
  final AppleApiOption apple;
  final AndroidApiOptions android;

  const ApiOptions({
    this.apple = const AVFoundationApiOptions(),
    this.android = AndroidApiOptions.mlKit,
  });

  Map<String, dynamic> get map {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return {'name': android.name};
      case TargetPlatform.iOS:
        return {'api': apple.name, 'options': apple.options};
      default:
        throw UnsupportedError("Unsupported platform");
    }
  }
}
