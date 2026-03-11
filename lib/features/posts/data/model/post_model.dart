import '../../domain/entity/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.title,
    required super.body,
    required super.userId,
    required super.tags,
    required super.reactions,
    required super.views,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle reactions - can be int or map with likes/dislikes
    int reactionsCount = 0;
    final reactionsRaw = json['reactions'];
    if (reactionsRaw is int) {
      reactionsCount = reactionsRaw;
    } else if (reactionsRaw is Map) {
      reactionsCount =
          (reactionsRaw['likes'] ?? 0) + (reactionsRaw['dislikes'] ?? 0);
    }

    return PostModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      reactions: reactionsCount,
      views: json['views'] ?? 0,
    );
  }
}
