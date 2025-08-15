// lib/features/downloads/domain/models/downloaded_video_model.dart
import 'package:hive/hive.dart';
import 'package:tik_saver/features/home/domain/models/video_model.dart';

part 'downloaded_video_model.g.dart'; // This line will be generated

@HiveType(typeId: 0) // Unique typeId for Hive
class DownloadedVideo extends HiveObject {
  @HiveField(0)
  final String awemeId;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String coverUrl;
  @HiveField(3)
  final String filePath; // Local path where video is saved
  @HiveField(4)
  final DateTime downloadDate;
  @HiveField(5)
  final String authorUniqueId; // To display in downloads list

  DownloadedVideo({
    required this.awemeId,
    required this.title,
    required this.coverUrl,
    required this.filePath,
    required this.downloadDate,
    required this.authorUniqueId,
  });

  // Factory constructor to create from VideoModel
  factory DownloadedVideo.fromVideoModel(VideoModel video, String filePath) {
    return DownloadedVideo(
      awemeId: video.awemeId,
      title: video.title ?? 'No Title',
      coverUrl: video.cover,
      filePath: filePath,
      downloadDate: DateTime.now(),
      authorUniqueId: video.author.uniqueId,
    );
  }
}