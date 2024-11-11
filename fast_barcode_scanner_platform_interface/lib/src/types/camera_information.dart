import 'dart:ui';

import 'package:flutter/foundation.dart';

///
enum PerformanceMode {
  /// Let the underlying system decide
  system,

  /// Favor battery live
  economic,

  /// Favor high resolution and shutter speed
  high
}

/// Dictates how the camera reacts to detections
enum DetectionMode {
  /// Pauses the detection of further barcodes when a barcode is detected.
  ///
  /// The preview continues.
  pauseDetection,

  /// Pauses the preview on detection.
  ///
  /// This, of cause, also stops the detector.
  pauseVideo,

  /// Does nothing on detection.
  ///
  /// Throttling detections is recommended using this mode.
  continuous
}

/// The position of the camera to use.
enum CameraPosition { front, back }

/// The configuration by which the camera feed can be laid out in the UI.
class CameraInformation {
  /// The height of the camera feed in points.
  final Size videoSize;

  /// The frame inside of [videoSize] where barcodes are detected.
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

sealed class AppleApiMode {
  const AppleApiMode();
  String get name;
  Map<String, dynamic> get options;
}

class AVFoundationApiMode extends AppleApiMode {
  const AVFoundationApiMode();

  static const avFoundation = AVFoundationApiMode();

  @override
  String get name => "avfoundation";

  @override
  Map<String, dynamic> get options => {};
}

class VisionApiMode extends AppleApiMode {
  final double confidence;

  const VisionApiMode({required this.confidence});

  @override
  String get name => "vision";

  @override
  Map<String, dynamic> get options => {'confidence': confidence};
}

enum AndroidApiMode { mlKit }

class ApiMode {
  final AppleApiMode apple;
  final AndroidApiMode android;

  const ApiMode({
    this.apple = const AVFoundationApiMode(),
    this.android = AndroidApiMode.mlKit,
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
