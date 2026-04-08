class UserProfile {
  int? id;
  String fullName;
  String cin;
  String address;
  String dob;
  String phone;

  UserProfile({
    this.id,
    required this.fullName,
    required this.cin,
    required this.address,
    required this.dob,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'cin': cin,
      'address': address,
      'dob': dob,
      'phone': phone,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      fullName: map['fullName'],
      cin: map['cin'],
      address: map['address'],
      dob: map['dob'],
      phone: map['phone'],
    );
  }
}