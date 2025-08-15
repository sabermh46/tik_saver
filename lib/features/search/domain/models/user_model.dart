// lib/features/search/domain/models/user_model.dart

class UserModel {
  final String id;
  final String uniqueId;
  final String nickname;
  final String avatar;
  final String signature;
  final int followerCount;

  UserModel({
    required this.id,
    required this.uniqueId,
    required this.nickname,
    required this.avatar,
    required this.signature,
    required this.followerCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user']['id'] as String,
      uniqueId: json['user']['uniqueId'] as String,
      nickname: json['user']['nickname'] as String,
      avatar: json['user']['avatarLarger'] as String,
      signature: json['user']['signature'] as String,
      followerCount: json['stats']['followerCount'] as int,
    );
  }
}