package com.jhoogstraat.fast_barcode_scanner.types

import android.util.Size
import com.google.mlkit.vision.barcode.common.Barcode

data class ScannerConfiguration(val types: IntArray, val resolution: Resolution, val framerate: Framerate, val position: CameraPosition, val detectionMode: DetectionMode)

enum class Framerate {
    Fps30, Fps60, Fps120, Fps240;
}

enum class Resolution {
    Sd480, Hd720, Hd1080, Hd4k;

    private fun width() : Int = when(this) {
        Sd480 -> 640
        Hd720 -> 1280
        Hd1080 -> 1920
        Hd4k -> 3840
    }

    private fun height() : Int = when(this) {
        Sd480 -> 480
        Hd720 -> 720
        Hd1080 -> 1080
        Hd4k -> 2160
    }

    fun landscape() : Size = Size(width(), height())
    fun portrait() : Size = Size(height(), width())
}

enum class DetectionMode {
    PauseDetection, PauseVideo, Continuous;
}

enum class CameraPosition {
    Front, Back;
}

val barcodeFormatMap = hashMapOf(
    "aztec" to Barcode.FORMAT_AZTEC,
    "code128" to Barcode.FORMAT_CODE_128,
    "code39" to Barcode.FORMAT_CODE_39,
    "code93" to Barcode.FORMAT_CODE_93,
    "codabar" to Barcode.FORMAT_CODABAR,
    "dataMatrix" to Barcode.FORMAT_DATA_MATRIX,
    "ean13" to Barcode.FORMAT_EAN_13,
    "ean8" to Barcode.FORMAT_EAN_8,
    "itf" to Barcode.FORMAT_ITF,
    "pdf417" to Barcode.FORMAT_PDF417,
    "qr" to Barcode.FORMAT_QR_CODE,
    "upcA" to Barcode.FORMAT_UPC_A,
    "upcE" to Barcode.FORMAT_UPC_E
)

val barcodeStringMap = barcodeFormatMap.entries.associateBy({ it.value }) { it.key }