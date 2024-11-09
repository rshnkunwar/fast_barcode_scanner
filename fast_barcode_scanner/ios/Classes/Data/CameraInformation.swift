struct CameraInformation {
  let videoWidth: Int32
  let videoHeight: Int32

  let analysisWidth: Double
  let analysisHeight: Double

  init(videoWidth: Int32, videoHeight: Int32, analysisWidth: Int32, analysisHeight: Int32) {
    self.videoWidth = videoWidth
    self.videoHeight = videoHeight
    self.analysisWidth = Double(analysisWidth)
    self.analysisHeight = Double(analysisHeight)
  }
  var serialized: [String: Any] {
    let offsetX = Double(videoWidth) - Double(analysisWidth)
    let offsetY = Double(videoHeight) - Double(analysisHeight)

    return [
      "video_size": [Double(videoWidth), Double(videoHeight)],
      "analysis_frame": [offsetX / 2, offsetY / 2, Double(analysisWidth), Double(analysisHeight)],
    ]
  }
}
