// lib/features/home/provider/video_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tik_saver/features/home/domain/models/video_model.dart';
import 'package:tik_saver/features/home/domain/repositories/video_repository.dart';
import 'package:tik_saver/core/services/api_key_service.dart';

// State definition for the video feed
class VideoFeedData {
  final List<VideoModel> videos;
  final bool loadingMore;

  VideoFeedData({
    this.videos = const [],
    this.loadingMore = false,
  });
}

// Provider for the video repository
final videoRepositoryProvider = Provider((ref) => VideoRepository(ref));

// AsyncNotifier to handle video feed state
class VideoFeedNotifier extends StateNotifier<AsyncValue<VideoFeedData>> {
  final Ref _ref;
  final int _count = 20;
  final String _defaultRegion = 'BD';

  VideoFeedNotifier(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen<ApiKeysState>(apiKeysProvider, (previous, next) {
      if (!next.isLoading && next.rapidApiKey.isNotEmpty) {
        // If keys are fetched, do initial video fetch
        fetchVideos();
      }
    }, fireImmediately: true);
  }

  Future<void> fetchVideos() async {
    state = const AsyncValue.loading();
    try {
      final videos = await _ref.read(videoRepositoryProvider).fetchFeedVideos(_defaultRegion, _count);
      state = AsyncValue.data(VideoFeedData(videos: videos));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchMoreVideos() async {
    // Check if we are already loading or if the data is not ready
    final currentData = state.value;
    if (currentData == null || currentData.loadingMore) return;

    state = AsyncValue.data(VideoFeedData(videos: currentData.videos, loadingMore: true));
    try {
      final newVideos = await _ref.read(videoRepositoryProvider).fetchFeedVideos(_defaultRegion, _count);
      final updatedVideos = [...currentData.videos, ...newVideos];
      state = AsyncValue.data(VideoFeedData(videos: updatedVideos, loadingMore: false));
    } catch (e, st) {
      state = AsyncValue.data(VideoFeedData(videos: currentData.videos, loadingMore: false));
      // You might want to show a SnackBar or Toast for this error
      _ref.read(errorProvider.notifier).state = e.toString();
    }
  }
}

// Separate provider to notify errors to the UI
final errorProvider = StateProvider<String?>((ref) => null);

// Provider to manage the video feed
final videoFeedProvider = StateNotifierProvider<VideoFeedNotifier, AsyncValue<VideoFeedData>>((ref) {
  return VideoFeedNotifier(ref);
});