enum UserRole { client, trainer }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? photoUrl;
  final String? trainerId; // Set if role == client
  final List<String> clientIds; // Set if role == trainer
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoUrl,
    this.trainerId,
    this.clientIds = const [],
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] == 'trainer' ? UserRole.trainer : UserRole.client,
      photoUrl: map['photoUrl'],
      trainerId: map['trainerId'],
      clientIds: List<String>.from(map['clientIds'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role == UserRole.trainer ? 'trainer' : 'client',
      'photoUrl': photoUrl,
      'trainerId': trainerId,
      'clientIds': clientIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? trainerId,
    List<String>? clientIds,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      trainerId: trainerId ?? this.trainerId,
      clientIds: clientIds ?? this.clientIds,
      createdAt: createdAt,
    );
  }
}
