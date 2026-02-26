class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? nickname;
  final bool gmailConnected;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.nickname,
    this.gmailConnected = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      nickname: json['nickname'] as String?,
      gmailConnected: json['gmailConnected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'nickname': nickname,
      'gmailConnected': gmailConnected,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? nickname,
    bool? gmailConnected,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      nickname: nickname ?? this.nickname,
      gmailConnected: gmailConnected ?? this.gmailConnected,
    );
  }

  /// Display name to show in greeting, falls back through nickname → displayName → email
  String get greeting => nickname ?? displayName ?? email.split('@').first;
}
