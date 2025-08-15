import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // ⭐ NEW: Import Google Fonts
import 'package:tik_saver/features/downloads/domain/models/downloaded_video_model.dart';
import 'package:tik_saver/features/downloads/provider/download_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(downloadProvider);
    final downloadedVideos = downloadState.downloadedVideos;

    return Scaffold(
      backgroundColor: Colors.white, // ⭐ MODIFIED: White background
      body: downloadedVideos.isEmpty
          ? Center(
        child: Text(
          'No videos downloaded yet.',
          style: GoogleFonts.poppins(color: Colors.grey[700]), // ⭐ MODIFIED: Add Poppins
        ),
      )
          : ListView.builder(
        itemCount: downloadedVideos.length,
        itemBuilder: (context, index) {
          final video = downloadedVideos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // ⭐ MODIFIED: Increased margin
            child: Card(
              color: Colors.white, // ⭐ MODIFIED: White card background
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2, // Spreads the shadow out
                    blurRadius: 8, // Blurs the shadow, making it softer
                    offset: const Offset(0, 0), // ⭐ KEY CHANGE: Set offset to (0, 0)
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(video.coverUrl),
                        radius: 30,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1, // ⭐ MODIFIED: Max 1 line
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'By @${video.authorUniqueId}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1, // ⭐ MODIFIED: Max 1 line
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'On: ${video.downloadDate.toLocal().toString().split(' ')[0]}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1, // ⭐ MODIFIED: Max 1 line
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () {
                              _playLocalVideo(context, video.filePath);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              ref.read(downloadProvider.notifier).deleteDownloadedVideo(video);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _playLocalVideo(BuildContext context, String filePath) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 1.0,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                color: Colors.black,
                child: LocalVideoPlayerSheet(filePath: filePath),
              ),
            );
          },
        );
      },
    );
  }
}

// NOTE: The LocalVideoPlayerSheet widget remains the same as in your original code.
// No changes are needed there as it is a separate component for video playback.

class LocalVideoPlayerSheet extends StatefulWidget {
  final String filePath;

  const LocalVideoPlayerSheet({required this.filePath, super.key});

  @override
  State<LocalVideoPlayerSheet> createState() => _LocalVideoPlayerSheetState();
}

class _LocalVideoPlayerSheetState extends State<LocalVideoPlayerSheet> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController!.initialize();

    if (mounted) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
      );
      setState(() {});
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
    return _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
        ? Chewie(
      controller: _chewieController!,
    )
        : const Center(
      child: CircularProgressIndicator(),
    );
  }
}