// lib/features/downloads/provider/download_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tik_saver/features/home/domain/models/video_model.dart';
import 'package:tik_saver/features/downloads/domain/models/downloaded_video_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import the new package

enum DownloadStatus { idle, downloading, completed, failed, permissionDenied, userCanceled }

class DownloadState {
  final DownloadStatus status;
  final double progress;
  final String? error;
  final List<DownloadedVideo> downloadedVideos;

  DownloadState({
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.error,
    this.downloadedVideos = const [],
  });

  DownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    String? error,
    List<DownloadedVideo>? downloadedVideos,
  }) {
    return DownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error,
      downloadedVideos: downloadedVideos ?? this.downloadedVideos,
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  DownloadNotifier() : super(DownloadState()) {
    _initHive();
  }

  late Box<DownloadedVideo> _downloadBox;

  Future<void> _initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DownloadedVideoAdapter());
    _downloadBox = await Hive.openBox<DownloadedVideo>('downloads');
    _loadDownloadedVideos();
  }

  void _loadDownloadedVideos() {
    state = state.copyWith(downloadedVideos: _downloadBox.values.toList());
  }

  void resetStatus() {
    state = DownloadState(downloadedVideos: state.downloadedVideos);
  }

  Future<void> downloadVideo(VideoModel video) async {
    state = state.copyWith(status: DownloadStatus.downloading, progress: 0.0, error: null);

    // 1. Check for a previously saved download path
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedDirectory = prefs.getString('download_path');

    // If no path is saved, prompt the user to select one
    if (selectedDirectory == null) {
      // Request permissions
      PermissionStatus permissionStatus;
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          permissionStatus = await Permission.photos.request();
        } else {
          permissionStatus = await Permission.storage.request();
        }
      } else {
        permissionStatus = await Permission.storage.request();
      }

      if (!permissionStatus.isGranted) {
        state = state.copyWith(status: DownloadStatus.permissionDenied, error: 'Storage permission denied');
        return;
      }

      // Prompt user to select a directory
      selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        state = state.copyWith(status: DownloadStatus.userCanceled, error: 'Download canceled by user');
        return;
      }

      // ⭐ Save the selected directory for future use ⭐
      await prefs.setString('download_path', selectedDirectory);
    }

    try {
      final fileName = '${video.title?.replaceAll(RegExp(r'[^\w\s.-]'), '')}.mp4';
      final filePath = '$selectedDirectory/$fileName';

      final dio = Dio();
      await dio.download(
        video.playUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            state = state.copyWith(progress: received / total);
          }
        },
      );

      final downloadedVideo = DownloadedVideo.fromVideoModel(video, filePath);
      await _downloadBox.add(downloadedVideo);
      _loadDownloadedVideos();

      state = state.copyWith(status: DownloadStatus.completed);
    } catch (e, st) {
      print('Download error: $e\n$st');
      state = state.copyWith(status: DownloadStatus.failed, error: e.toString());
    }
  }

  Future<void> deleteDownloadedVideo(DownloadedVideo video) async {
    try {
      final file = File(video.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      await video.delete();
      _loadDownloadedVideos();
    } catch (e) {
      print('Error deleting video: $e');
    }
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>((ref) => DownloadNotifier());