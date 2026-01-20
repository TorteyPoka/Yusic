import 'package:equatable/equatable.dart';

enum UserType { artist, studio }

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserType userType;
  final String? profileImage;
  final String? bio;
  final int privateFolderCount;
  final int privateFolderLimit;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    this.profileImage,
    this.bio,
    this.privateFolderCount = 0,
    this.privateFolderLimit = 10,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      userType: UserType.values.firstWhere(
        (e) =>
            e.toString() == 'UserType.${json['usertype'] ?? json['userType']}',
      ),
      profileImage:
          json['profileimage'] as String? ?? json['profileImage'] as String?,
      bio: json['bio'] as String?,
      privateFolderCount: json['privatefoldercount'] as int? ??
          json['privateFolderCount'] as int? ??
          0,
      privateFolderLimit: json['privatefolderlimit'] as int? ??
          json['privateFolderLimit'] as int? ??
          10,
      createdAt: DateTime.parse(
          json['createdat'] as String? ?? json['createdAt'] as String),
      lastLogin: (json['lastlogin'] ?? json['lastLogin']) != null
          ? DateTime.parse((json['lastlogin'] ?? json['lastLogin']) as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'userType': userType.toString().split('.').last,
      'profileImage': profileImage,
      'bio': bio,
      'privateFolderCount': privateFolderCount,
      'privateFolderLimit': privateFolderLimit,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserType? userType,
    String? profileImage,
    String? bio,
    int? privateFolderCount,
    int? privateFolderLimit,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      privateFolderCount: privateFolderCount ?? this.privateFolderCount,
      privateFolderLimit: privateFolderLimit ?? this.privateFolderLimit,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        userType,
        profileImage,
        bio,
        privateFolderCount,
        privateFolderLimit,
        createdAt,
        lastLogin,
      ];
}
