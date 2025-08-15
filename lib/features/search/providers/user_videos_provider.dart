// lib/features/search/providers/user_videos_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:tik_saver/features/home/domain/models/video_model.dart';
import 'package:tik_saver/core/services/api_key_service.dart';
import 'dart:developer';

class UserVideosState {
  final List<VideoModel> videos;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final String? nextCursor;

  UserVideosState({
    this.videos = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = false,
    this.nextCursor,
  });

  UserVideosState copyWith({
    List<VideoModel>? videos,
    bool? isLoading,
    String? error,
    bool? hasMore,
    String? nextCursor,
  }) {
    return UserVideosState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
    );
  }
}

class UserVideosNotifier extends StateNotifier<UserVideosState> {
  final Ref _ref;

  UserVideosNotifier(this._ref) : super(UserVideosState());

  Future<void> fetchUserVideos(String uniqueId, String userId, {String? cursor}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    final apiKeys = _ref.read(apiKeysProvider);
    if (apiKeys.rapidApiKey.isEmpty || apiKeys.rapidApiHost.isEmpty) {
      log('❌ ERROR: API keys are not available.');
      state = state.copyWith(
          isLoading: false, error: 'API keys are not available.');
      return;
    }

    final queryParameters = {
      'unique_id': uniqueId,
      'count': '10',
      'user_id': userId,
      'cursor': cursor ?? '0',
    };

    final uri = Uri.https(apiKeys.rapidApiHost, '/user/posts', queryParameters);

    log('🌎 Fetching user videos from: $uri');
    log('🔑 Headers: x-rapidapi-key: ${apiKeys.rapidApiKey}, x-rapidapi-host: ${apiKeys.rapidApiHost}');

    try {
      final response = await http.get(
        uri,
        headers: {
          'x-rapidapi-key': apiKeys.rapidApiKey,
          'x-rapidapi-host': apiKeys.rapidApiHost,
        },
      );

      log('✅ API Response Status Code: ${response.statusCode}');
      log('📦 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          log('⚠️ WARNING: API response body is empty.');
          state = state.copyWith(isLoading: false, error: 'Empty response from API.');
          return;
        }

        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['code'] != 0) {
          log('❌ API Error: ${data['msg']}');
          state = state.copyWith(
            isLoading: false,
            error: data['msg'] ?? 'An unknown API error occurred.',
          );
          return;
        }

        final List<dynamic> videosJson = data['data']['videos'];
        final List<VideoModel> newVideos = videosJson
            .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final updatedVideos = [...state.videos, ...newVideos];
        final bool hasMore = data['data']['hasMore'] ?? false;
        final String? newCursor = data['data']['cursor']?.toString();

        log('🎉 Successfully fetched ${newVideos.length} videos.');

        state = state.copyWith(
          videos: updatedVideos,
          isLoading: false,
          hasMore: hasMore,
          nextCursor: newCursor,
        );
      } else {
        log('❌ HTTP Error: ${response.statusCode}');
        state = state.copyWith(
            isLoading: false, error: 'Failed to fetch user videos: ${response.statusCode}');
      }
    } catch (e) {
      log('💥 Exception caught: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void resetVideos() {
    state = UserVideosState(); // ⭐ FIX: Ensure this is calling the constructor
  }
}

final userVideosProvider = StateNotifierProvider.family<UserVideosNotifier, UserVideosState, String>((ref, uniqueId) {
  return UserVideosNotifier(ref);
});