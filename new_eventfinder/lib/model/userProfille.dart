class UserProfile {
  final String name;
  final String phone;
  final String profileImage;
  final String address;

  UserProfile({

    required this.name,
    
    required this.phone,
    required this.profileImage,
    required this.address,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      phone: json['phone'],
      profileImage: json['profileImage'],
      address: json['address'],
    );
  }
}
