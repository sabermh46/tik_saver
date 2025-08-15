// lib/features/home/domain/models/video_model.dart

class VideoModel {
  final String awemeId;
  final String? title;
  final String cover;
  final int duration;
  final String playUrl;
  final int playCount;
  final int diggCount;
  final int commentCount;
  final int shareCount;
  final int downloadCount;
  final Author author;
  final String? musicTitle;

  VideoModel({
    required this.awemeId,
    this.title,
    required this.cover,
    required this.duration,
    required this.playUrl,
    required this.playCount,
    required this.diggCount,
    required this.commentCount,
    required this.shareCount,
    required this.downloadCount,
    required this.author,
    this.musicTitle
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    // Handle nested 'music_info' and potentially null 'title'
    final musicTitle = json['music_info'] != null
        ? json['music_info']['title'] as String?
        : null;

    return VideoModel(
      awemeId: json['aweme_id'] as String,
      title: json['title'] as String?, // ⭐ CORRECTED: Use nullable cast
      cover: json['cover'] as String,
      duration: json['duration'] as int,
      playUrl: json['play'] as String,
      playCount: json['play_count'] as int,
      diggCount: json['digg_count'] as int,
      commentCount: json['comment_count'] as int,
      shareCount: json['share_count'] as int,
      downloadCount: json['download_count'] as int,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      musicTitle: musicTitle,
    );
  }
}

class Author {
  final String uniqueId;
  final String nickname;
  final String avatar;

  Author({
    required this.uniqueId,
    required this.nickname,
    required this.avatar,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      uniqueId: json['unique_id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
    );
  }
}

class ApiResponse {
  final int code;
  final String msg;
  final double processedTime;
  final List<VideoModel> data;

  ApiResponse({
    required this.code,
    required this.msg,
    required this.processedTime,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] as List<dynamic>;
    final List<VideoModel> videoList = dataList.map((item) => VideoModel.fromJson(item as Map<String, dynamic>)).toList();

    return ApiResponse(
      code: json['code'] as int,
      msg: json['msg'] as String,
      processedTime: (json['processed_time'] as num).toDouble(),
      data: videoList,
    );
  }
}