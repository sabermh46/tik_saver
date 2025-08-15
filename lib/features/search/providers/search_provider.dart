import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:tik_saver/features/home/domain/models/video_model.dart';
import 'package:tik_saver/features/search/domain/models/user_model.dart';
import 'package:tik_saver/core/services/api_key_service.dart';

enum SearchType { videos, users }

class SearchState {
  final List<VideoModel> videos;
  final List<UserModel> users;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final String? nextCursor;
  final SearchType searchType;
  final bool isPaginating;

  SearchState({
    this.videos = const [],
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = false,
    this.nextCursor,
    this.searchType = SearchType.videos,
    this.isPaginating = false,
  });

  SearchState copyWith({
    List<VideoModel>? videos,
    List<UserModel>? users,
    bool? isLoading,
    String? error,
    bool? hasMore,
    String? nextCursor,
    SearchType? searchType,
    bool? isPaginating,
  }) {
    return SearchState(
      videos: videos ?? this.videos,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      searchType: searchType ?? this.searchType,
      isPaginating: isPaginating ?? this.isPaginating,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;

  SearchNotifier(this._ref) : super(SearchState());

  void setSearchType(SearchType type) {
    state = state.copyWith(searchType: type, videos: [], users: [], nextCursor: '0');
  }

  Future<void> search(String query, {String? cursor}) async {
    if (state.isLoading || state.isPaginating) return;
    if (query.isEmpty) {
      state = SearchState(searchType: state.searchType);
      return;
    }

    if (cursor == null) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isPaginating: true, error: null);
    }

    final apiKeys = _ref.read(apiKeysProvider);
    if (apiKeys.rapidApiKey.isEmpty || apiKeys.rapidApiHost.isEmpty) {
      state = state.copyWith(
          isLoading: false, error: 'API keys are not available.');
      return;
    }

    final String path;
    final Map<String, dynamic> queryParameters;

    if (state.searchType == SearchType.videos) {
      path = '/feed/search';
      queryParameters = {
        'keywords': query,
        'count': '10',
        'cursor': cursor ?? '0',
        'region': 'BD',
        'publish_time': '0',
        'sort_type': '0',
      };
    } else {
      path = '/user/search';
      queryParameters = {
        'keywords': query,
        'count': '10',
        'cursor': cursor ?? '0',
      };
    }

    final uri = Uri.https(apiKeys.rapidApiHost, path, queryParameters);

    try {
      final response = await http.get(
        uri,
        headers: {
          'x-rapidapi-key': apiKeys.rapidApiKey,
          'x-rapidapi-host': apiKeys.rapidApiHost,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (state.searchType == SearchType.videos) {
          final List<dynamic> videosJson = data['data']['videos'];
          final List<VideoModel> newVideos = videosJson
              .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
              .toList();

          final updatedVideos = [...state.videos, ...newVideos];
          final bool hasMore = data['data']['hasMore'] ?? false;
          final String? newCursor = data['data']['cursor']?.toString();

          state = state.copyWith(
            videos: updatedVideos,
            isLoading: false,
            isPaginating: false,
            hasMore: hasMore,
            nextCursor: newCursor,
          );
        } else {
          final List<dynamic> usersJson = data['data']['user_list'];
          final List<UserModel> newUsers = usersJson
              .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
              .toList();

          final updatedUsers = [...state.users, ...newUsers];
          final bool hasMore = data['data']['hasMore'] ?? false;
          final String? newCursor = data['data']['cursor']?.toString();

          state = state.copyWith(
            users: updatedUsers,
            isLoading: false,
            isPaginating: false,
            hasMore: hasMore,
            nextCursor: newCursor,
          );
        }
      } else {
        state = state.copyWith(
            isLoading: false,
            isPaginating: false,
            error: 'Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isPaginating: false, error: e.toString());
    }
  }

  void resetSearch() {
    state = SearchState(searchType: state.searchType);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});