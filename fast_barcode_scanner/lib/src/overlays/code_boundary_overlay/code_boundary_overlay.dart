import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';
import 'package:fast_barcode_scanner/src/overlays/code_boundary_overlay/code_border_painter.dart';
import 'package:flutter/material.dart';

typedef CodeBorderPaintBuilder = Paint Function(Barcode);

/// Draws a boundary around detected `Barcode`s.
class CodeBoundaryOverlay extends StatefulWidget {
  final Paint Function(Barcode)? codeBorderPaintBuilder;
  final TextStyle Function(Barcode)? barcodeValueStyle;

  const CodeBoundaryOverlay({
    super.key,
    this.codeBorderPaintBuilder,
    this.barcodeValueStyle,
  });

  @override
  State<CodeBoundaryOverlay> createState() => _CodeBoundaryOverlayState();
}

class _CodeBoundaryOverlayState extends State<CodeBoundaryOverlay> {
  final _cameraController = CameraController.shared;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Barcode>>(
      valueListenable: _cameraController.resultNotifier,
      builder: (context, barcodes, child) {
        final previewSize =
            _cameraController.state.value.cameraInformation?.videoSize;

        if (previewSize == null || barcodes.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(
          painter: CodeBorderPainter(
            imageSize: previewSize,
            barcodes: barcodes,
            barcodePaintSelector: widget.codeBorderPaintBuilder,
            barcodeValueStyle: widget.barcodeValueStyle,
          ),
        );
      },
    );
  }
}
