/// The currently supported barcode types.
///
/// Sources:
///
/// - https://developer.apple.com/documentation/vision/vnbarcodesymbology
/// - https://developer.apple.com/documentation/avfoundation/avmetadatamachinereadablecodeobject/machine-readable_object_types
/// - https://developers.google.com/android/reference/com/google/mlkit/vision/barcode/common/Barcode.BarcodeFormat
enum BarcodeType {
  /// iOS, Android
  aztec,

  /// iOS, Android
  codabar,

  /// iOS, Android
  code128,

  /// iOS, Android
  code39,

  /// iOS, Android
  code93,

  /// iOS, Android
  dataMatrix,

  /// iOS, Android
  ean13,

  /// iOS, Android
  ean8,

  /// iOS
  gs1DataBar,

  /// iOS, Android
  itf,

  /// iOS
  msi,

  /// iOS, Android
  pdf417,

  /// iOS, Android
  qr,

  /// iOS, Android
  upcA,

  /// iOS, Android
  upcE
}
