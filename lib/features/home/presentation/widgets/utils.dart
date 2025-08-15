import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tik_saver/features/home/domain/models/video_model.dart';
import 'package:tik_saver/features/home/provider/video_provider.dart';
import 'package:tik_saver/features/home/presentation/widgets/video_card.dart';
import 'package:tik_saver/features/home/presentation/widgets/skeleton_loader.dart'; // ⭐ NEW: Import SkeletonLoader

// This is the widget for the main video feed grid view
class VideoFeedWidget extends ConsumerStatefulWidget {
  const VideoFeedWidget({super.key});

  @override
  ConsumerState<VideoFeedWidget> createState() => _VideoFeedWidgetState();
}

class _VideoFeedWidgetState extends ConsumerState<VideoFeedWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final videoState = ref.read(videoFeedProvider);
    if (videoState.value == null || videoState.value!.loadingMore) return;

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      ref.read(videoFeedProvider.notifier).fetchMoreVideos();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollController as VoidCallback);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(videoFeedProvider.notifier).fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    final videoFeed = ref.watch(videoFeedProvider);
    final error = ref.watch(errorProvider);

    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
        ref.read(errorProvider.notifier).state = null;
      });
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: videoFeed.when(
        data: (feedData) {
          final videos = feedData.videos;
          if (videos.isEmpty) {
            return const Center(child: Text('No videos found. Pull to refresh.'));
          }
          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: videos.length + (feedData.loadingMore ? 2 : 0),
            itemBuilder: (context, index) {
              if (index < videos.length) {
                return VideoCard(video: videos[index]);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
        loading: () => const SkeletonLoader(), // ⭐ MODIFIED: Use the new skeleton loader
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}