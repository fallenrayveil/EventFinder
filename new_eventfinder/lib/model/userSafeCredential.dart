class UserSafeCredential {
  late String uid;
  late String accessToken;
  late String refreshToken;
  late String email;
  late bool emailVerified;
  late String lastLoginAt;
  late String createdAt;

  UserSafeCredential({
    required this.uid,
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    required this.emailVerified,
    required this.lastLoginAt,
    required this.createdAt,
  });

  UserSafeCredential.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    email = json['email'];
    emailVerified = json['emailVerified'];
    lastLoginAt = json['lastLoginAt'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['email'] = this.email;
    data['emailVerified'] = this.emailVerified;
    data['lastLoginAt'] = this.lastLoginAt;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
