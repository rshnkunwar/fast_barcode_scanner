package com.jhoogstraat.fast_barcode_scanner.types

data class CameraInformation(val videoWidth: Double,
                             val videoHeight: Double,
                             val analysisWidth: Double,
                             val analysisHeight: Double) {
    fun serialized() {
        val offsetX = videoWidth - analysisWidth
        val offsetY = videoHeight - analysisHeight

        hashMapOf(
            "video_size" to arrayOf(videoWidth, videoHeight),
            "analysis_frame" to arrayOf(offsetX / 2, offsetY / 2, analysisWidth, analysisHeight)
        )
    }
}
