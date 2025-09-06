class Prediction {
  final double bfPercent;
  Prediction({required this.bfPercent});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(bfPercent: (json['bfPercent'] as num).toDouble());
  }
}
