import 'package:fast_barcode_scanner_platform_interface/fast_barcode_scanner_platform_interface.dart';
import 'package:fast_barcode_scanner_platform_interface/src/method_channel_fast_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'resources/load_resources.dart';
import 'utils/method_channel_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelMock mockChannel;
  late MethodChannelFastBarcodeScanner scanner;

  group('Initialization and disposing', () {
    setUp(() {
      mockChannel = MethodChannelMock(
          channelName: 'com.jhoogstraat/fast_barcode_scanner',
          methods: {
            'init': {
              'textureId': 0,
              'targetRotation': 0,
              'analysisWidth': 0,
              'analysisHeight': 0,
            }
          });

      scanner = MethodChannelFastBarcodeScanner();
    });

    test('Should initialize camera and return a `CameraInformation`', () async {
      // Act
      final response = await scanner.init(
          [BarcodeType.ean13],
          PerformanceMode.system,
          DetectionMode.pauseDetection,
          CameraPosition.back,
          const ApiMode());

      // Assert
      expect(mockChannel.log, [
        isMethodCall('init', arguments: {
          'types': ['ean13'],
          'mode': 'pauseDetection',
          'res': 'hd1080',
          'fps': 'fps60',
          'pos': 'back',
        }),
      ]);

      expect(
        response,
        CameraInformation({
          'textureId': 0,
          'targetRotation': 0,
          'analysisWidth': 0,
          'analysisHeight': 0,
        }),
      );
    });

    test('Should forward PlatformException when init throws', () {
      // Arrange
      mockChannel.methods['init'] = PlatformException(
        code: 'TESTING_ERROR_CODE',
        message: 'Mock error message used during testing.',
      );

      // Assert
      expect(
        () => scanner.init(
          [BarcodeType.ean13],
          PerformanceMode.system,
          DetectionMode.pauseDetection,
          CameraPosition.back,
          ApiMode(),
        ),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', 'TESTING_ERROR_CODE')
            .having((e) => e.message, 'description',
                'Mock error message used during testing.')
            .having((e) => e.details, 'details', isNull)),
      );
    });
  });

  group('Event tests', () {
    setUp(() async {
      mockChannel = MethodChannelMock(
          channelName: 'com.jhoogstraat/fast_barcode_scanner',
          methods: {
            'init': {
              'textureId': 0,
              'targetRotation': 0,
              'analysisWidth': 0,
              'analysisHeight': 0,
            }
          });

      scanner = MethodChannelFastBarcodeScanner();

      await scanner.init(
        [BarcodeType.ean13],
        PerformanceMode.system,
        DetectionMode.pauseDetection,
        CameraPosition.back,
        ApiMode(),
      );
    });

    test('Should call handler once with detected barcode', () async {
      // Arrange
      // late Barcode actualBarcode;
      // int invocations = 0;

      // scanner.setOnDetectHandler((code) {
      //   actualBarcode = code;
      //   invocations++;
      // });

      // Act
      // scanner.handlePlatformMethodCall(
      //   const MethodCall('s', ['ean13', '1234']),
      // );

      // Assert
      // expect(actualBarcode, Barcode(['ean13', '1234']));
      // expect(invocations, 1);
    });

    test('Should not call handler with invalid barcode', () async {
      // Arrange
      List<Barcode>? actualBarcode;
      scanner.setOnDetectionHandler((code) => actualBarcode = code);

      // Act
      // scanner.handlePlatformMethodCall(
      //   const MethodCall('s', ['invalid_type', null]),
      // );

      // Assert
      expect(actualBarcode, null);
    });
  });

  group('Function tests', () {
    setUp(() async {
      mockChannel = MethodChannelMock(
          channelName: 'com.jhoogstraat/fast_barcode_scanner',
          methods: {
            'init': {
              'textureId': 0,
              'targetRotation': 0,
              'analysisWidth': 0,
              'analysisHeight': 0,
            },
          });

      scanner = MethodChannelFastBarcodeScanner();

      await scanner.init(
        [BarcodeType.ean13],
        PerformanceMode.system,
        DetectionMode.pauseDetection,
        CameraPosition.back,
        ApiMode(),
      );
    });

    test('Should toggle torch and return the torch state', () async {
      // Arrange
      mockChannel = MethodChannelMock(
        channelName: 'com.jhoogstraat/fast_barcode_scanner',
        methods: {'torch': true},
      );

      // Act
      final response = await scanner.toggleTorch();

      // Assert
      expect(mockChannel.log, [isMethodCall('torch', arguments: null)]);
      expect(true, response);
    });

    test('Should change configuration', () async {
      // Arrange
      mockChannel = MethodChannelMock(
        channelName: 'com.jhoogstraat/fast_barcode_scanner',
        methods: {
          'config': {
            'textureId': 0,
            'targetRotation': 0,
            'analysisWidth': 0,
            'analysisHeight': 0,
          }
        },
      );

      // Act
      final response = await scanner.changeConfiguration(
        detectionMode: DetectionMode.continuous,
        mode: PerformanceMode.system,
        position: CameraPosition.front,
      );

      // Assert
      expect(mockChannel.log, [
        isMethodCall('config', arguments: {
          'mode': 'system',
          'detectionMode': 'continuous',
          'pos': 'front'
        })
      ]);
      expect(
        CameraInformation({
          'textureId': 0,
          'targetRotation': 0,
          'analysisWidth': 0,
          'analysisHeight': 0,
        }),
        response,
      );
    });

    test('Should invoke `scan` with picker and respond with a detected barcode',
        () async {
      mockChannel = MethodChannelMock(
          channelName: 'com.jhoogstraat/fast_barcode_scanner',
          methods: {
            'scan': [
              ["ean13", "1234"]
            ]
          });

      final actualBarcode = await scanner.scanImage(ImageSource.picker());

      expect(mockChannel.log, [isMethodCall('scan', arguments: null)]);
      expect(actualBarcode, [
        Barcode(["ean13", "1234"])
      ]);
    });

    test(
        'Should invoke `scan` with picker and return null if null is responded from the platform',
        () async {
      mockChannel = MethodChannelMock(
          channelName: 'com.jhoogstraat/fast_barcode_scanner',
          methods: {'scan': null});

      final actualBarcode = await scanner.scanImage(ImageSource.picker());

      expect(mockChannel.log, [isMethodCall('scan', arguments: null)]);
      expect(actualBarcode, null);
    });

    test(
        'Should invoke `scan` with image and return null if null is responded from the platform',
        () async {
      mockChannel = MethodChannelMock(
          channelName: 'com.jhoogstraat/fast_barcode_scanner',
          methods: {'scan': null});

      final image = await loadBarcodeImage();
      final bytes = await image.toByteData();
      final source = ImageSource.binary(bytes!, rotation: 10);

      final actualBarcode = await scanner.scanImage(source);

      expect(mockChannel.log, [
        isMethodCall('scan', arguments: [bytes.buffer.asUint8List(), 10])
      ]);
      expect(actualBarcode, null);
    });

    test('Should invoke `start`', () async {
      // Arrange
      mockChannel = MethodChannelMock(
          channelName: 'com.jhoogstraat/fast_barcode_scanner',
          methods: {'start': null});

      // Act
      await scanner.start();

      // Assert
      expect(
        mockChannel.log,
        [isMethodCall('start', arguments: null)],
      );
    });

    test('Should invoke `stop`', () async {
      // Arrange
      mockChannel = MethodChannelMock(
          channelName: 'com.jhoogstraat/fast_barcode_scanner',
          methods: {'stop': null});

      // Act
      await scanner.stop();

      // Assert
      expect(
        mockChannel.log,
        [isMethodCall('stop', arguments: null)],
      );
    });
  });

  group('Error test', () {
    test('Should forward platform errors', () async {
      mockChannel = MethodChannelMock(
        channelName: 'com.jhoogstraat/fast_barcode_scanner',
        methods: {
          'start': PlatformException(
            code: 'TESTING_ERROR_CODE',
            message: 'Mock error message used during testing.',
          ),
          'torch': PlatformException(
            code: 'TESTING_ERROR_CODE',
            message: 'Mock error message used during testing.',
          ),
          'stop': PlatformException(
            code: 'TESTING_ERROR_CODE',
            message: 'Mock error message used during testing.',
          ),
          'config': PlatformException(
            code: 'TESTING_ERROR_CODE',
            message: 'Mock error message used during testing.',
          )
        },
      );

      scanner = MethodChannelFastBarcodeScanner();

      // Assert
      expect(
        () => scanner.start(),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', 'TESTING_ERROR_CODE')
            .having((e) => e.message, 'description',
                'Mock error message used during testing.')
            .having((e) => e.details, 'details', isNull)),
      );
      expect(
        () => scanner.stop(),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', 'TESTING_ERROR_CODE')
            .having((e) => e.message, 'description',
                'Mock error message used during testing.')
            .having((e) => e.details, 'details', isNull)),
      );
      expect(
        () => scanner.toggleTorch(),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', 'TESTING_ERROR_CODE')
            .having((e) => e.message, 'description',
                'Mock error message used during testing.')
            .having((e) => e.details, 'details', isNull)),
      );
      expect(
        () => scanner.changeConfiguration(),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', 'TESTING_ERROR_CODE')
            .having((e) => e.message, 'description',
                'Mock error message used during testing.')
            .having((e) => e.details, 'details', isNull)),
      );
    });
  });
}
