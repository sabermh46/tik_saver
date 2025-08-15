import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tik_saver/core/utils/count_utils.dart';
import 'package:tik_saver/features/home/domain/models/video_model.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:tik_saver/features/downloads/provider/download_provider.dart';
import 'package:shimmer/shimmer.dart'; // ⭐ NEW: Import Shimmer
import 'package:tik_saver/features/home/presentation/widgets/download_button.dart'; // ⭐ NEW: Import DownloadButton

class VideoDetailsSheet extends ConsumerStatefulWidget {
  final VideoModel video;

  const VideoDetailsSheet({required this.video, super.key});

  @override
  ConsumerState<VideoDetailsSheet> createState() => _VideoDetailsSheetState();
}

class _VideoDetailsSheetState extends ConsumerState<VideoDetailsSheet> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(downloadProvider.notifier).resetStatus();
    });
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.video.playUrl));
    await _videoPlayerController!.initialize();

    if (mounted) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        placeholder: const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(downloadProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isLoading || _chewieController == null || !_chewieController!.videoPlayerController.value.isInitialized)
                        SizedBox(
                          height: 200, // Placeholder height while loading
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        AspectRatio(
                          aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
                          child: Chewie(
                            controller: _chewieController!,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.video.title ?? "No Title",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.video.author.avatar),
                      radius: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '@${widget.video.author.uniqueId}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(Icons.play_arrow, formatNumber(widget.video.playCount)),
                    _buildStatColumn(Icons.favorite, formatNumber(widget.video.diggCount)),
                    _buildStatColumn(Icons.comment, formatNumber(widget.video.commentCount)),
                    _buildStatColumn(Icons.share, formatNumber(widget.video.shareCount)),
                  ],
                ),
                const SizedBox(height: 24),
                // ⭐ NEW: Use the custom download button widget ⭐
                DownloadButton(
                  state: downloadState,
                  onDownload: () {
                    ref.read(downloadProvider.notifier).downloadVideo(widget.video);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}