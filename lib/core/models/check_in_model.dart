class CheckInModel {
  final String id;
  final String clientId;
  final String trainerId;
  final DateTime date;
  final double weightKg;
  final double? bodyFatPercentage;
  final List<String> photoUrls;
  final String clientNotes;
  final String? trainerFeedback;
  final bool isReviewed;

  CheckInModel({
    required this.id,
    required this.clientId,
    required this.trainerId,
    required this.date,
    required this.weightKg,
    this.bodyFatPercentage,
    this.photoUrls = const [],
    this.clientNotes = '',
    this.trainerFeedback,
    this.isReviewed = false,
  });

  factory CheckInModel.fromMap(Map<String, dynamic> map, String id) {
    return CheckInModel(
      id: id,
      clientId: map['clientId'] ?? '',
      trainerId: map['trainerId'] ?? '',
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : DateTime.now(),
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      bodyFatPercentage: (map['bodyFatPercentage'] as num?)?.toDouble(),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      clientNotes: map['clientNotes'] ?? '',
      trainerFeedback: map['trainerFeedback'],
      isReviewed: map['isReviewed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'trainerId': trainerId,
      'date': date.millisecondsSinceEpoch,
      'weightKg': weightKg,
      'bodyFatPercentage': bodyFatPercentage,
      'photoUrls': photoUrls,
      'clientNotes': clientNotes,
      'trainerFeedback': trainerFeedback,
      'isReviewed': isReviewed,
    };
  }
}
