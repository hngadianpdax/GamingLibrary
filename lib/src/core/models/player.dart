class Player {
  final String userId;
  final String nickname;
  final DateTime createdAt;

  const Player({
    required this.userId,
    required this.nickname,
    required this.createdAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        userId: json['user_id'] as String,
        nickname: json['nickname'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'nickname': nickname,
      };
}
