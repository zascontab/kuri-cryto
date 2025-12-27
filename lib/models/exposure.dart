/// Exposure Information Model
class ExposureInfo {
  final double currentExposure;
  final double maxExposure;
  final double exposurePercent;
  final double availableExposure;

  ExposureInfo({
    required this.currentExposure,
    required this.maxExposure,
    required this.exposurePercent,
    required this.availableExposure,
  });

  factory ExposureInfo.fromJson(Map<String, dynamic> json) {
    return ExposureInfo(
      currentExposure: (json['current_exposure']).toDouble(),
      maxExposure: (json['max_exposure']).toDouble(),
      exposurePercent: (json['exposure_percent']).toDouble(),
      availableExposure: (json['available_exposure']).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_exposure': currentExposure,
      'max_exposure': maxExposure,
      'exposure_percent': exposurePercent,
      'available_exposure': availableExposure,
    };
  }
}
