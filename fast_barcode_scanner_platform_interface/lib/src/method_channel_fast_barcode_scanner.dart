import 'dart:async';

import 'package:fast_barcode_scanner_platform_interface/src/types/image_source.dart';
import 'package:flutter/services.dart';

import 'fast_barcode_scanner_platform_interface.dart';
import 'types/barcode.dart';
import 'types/barcode_type.dart';
import 'types/camera_information.dart';

class MethodChannelFastBarcodeScanner extends FastBarcodeScannerPlatform {
  static const MethodChannel _channel =
      MethodChannel('com.jhoogstraat/fast_barcode_scanner');

  static const EventChannel _detectionEventsChannel =
      EventChannel('com.jhoogstraat/fast_barcode_scanner/detections');

  final Stream<dynamic> _detectionEventStream =
      _detectionEventsChannel.receiveBroadcastStream();
  StreamSubscription<dynamic>? _barcodeEventStreamSubscription;
  OnDetectionHandler? _onDetectionHandler;

  @override
  Future<CameraInformation> init(
    List<BarcodeType> types,
    PerformanceMode mode,
    DetectionMode detectionMode,
    CameraPosition position,
    ApiMode api,
  ) async {
    final response = await _channel.invokeMethod('init', {
      'types': types.map((e) => e.name).toList(growable: false),
      'mode': mode,
      'pos': position.name,
      'detectionMode': detectionMode.name,
      ...api.map
    });

    return CameraInformation(response);
  }

  @override
  void setOnDetectionHandler(OnDetectionHandler handler) {
    _onDetectionHandler = handler;
    _barcodeEventStreamSubscription ??=
        _detectionEventStream.listen(_handlePlatformBarcodeEvent);
  }

  @override
  Future<void> start() => _channel.invokeMethod('start');

  @override
  Future<void> stop() => _channel.invokeMethod('stop');

  @override
  Future<void> startDetector() => _channel.invokeMethod('startDetector');

  @override
  Future<void> stopDetector() => _channel.invokeMethod('stopDetector');

  @override
  Future<bool> toggleTorch() =>
      _channel.invokeMethod('torch').then((isOn) => isOn);

  @override
  Future<CameraInformation> changeConfiguration({
    List<BarcodeType>? types,
    PerformanceMode? mode,
    DetectionMode? detectionMode,
    CameraPosition? position,
  }) async {
    final response = await _channel.invokeMethod('config', {
      if (types != null) 'types': types.map((e) => e.name).toList(),
      if (mode != null) 'mode': mode.name,
      if (detectionMode != null) 'detectionMode': detectionMode.name,
      if (position != null) 'pos': position.name,
    });

    return CameraInformation(response);
  }

  @override
  Future<void> dispose() async {
    await _barcodeEventStreamSubscription?.cancel();
    _barcodeEventStreamSubscription = null;
    _onDetectionHandler = null;
    return _channel.invokeMethod('dispose');
  }

  @override
  Future<List<Barcode>?> scanImage(ImageSource source) async {
    try {
      final List<Object?>? response = await _channel.invokeMethod(
        'scan',
        source.data,
      );
      final barcodes =
          response?.map((e) => Barcode(e as List<dynamic>)).toList();
      return barcodes;
    } catch (e) {
      assert(false, "Error converting barcode to dart type, original: $e");
      rethrow;
    }
  }

  void _handlePlatformBarcodeEvent(dynamic data) {
    // This might fail if the code type is not present in the list of available code types.
    // Barcode() will throw in this case and the error is suppressed in release mode.
    try {
      final barcodes = (data as List<dynamic>).map((e) => Barcode(e)).toList();
      _onDetectionHandler?.call(barcodes);
      // ignore: empty_catches
    } catch (e) {
      assert(false, "Error converting barcode to dart type, original: $e");
    }
  }
}
