// lib/core/services/api_key_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class ApiKeysState {
  final String rapidApiKey;
  final String rapidApiHost;
  final bool isLoading;

  ApiKeysState({
    required this.rapidApiKey,
    required this.rapidApiHost,
    this.isLoading = false,
  });
}

class ApiKeysNotifier extends StateNotifier<ApiKeysState> {
  ApiKeysNotifier() : super(ApiKeysState(rapidApiKey: '', rapidApiHost: '', isLoading: true)) {
    fetchKeys();
  }

  final _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> fetchKeys() async {
    state = ApiKeysState(rapidApiKey: state.rapidApiKey, rapidApiHost: state.rapidApiHost, isLoading: true);
    try {
      await _remoteConfig.fetchAndActivate();
      final rapidApiKey = _remoteConfig.getString('rapidapi_key');
      final rapidApiHost = _remoteConfig.getString('rapidapi_host');

      state = ApiKeysState(
        rapidApiKey: rapidApiKey,
        rapidApiHost: rapidApiHost,
        isLoading: false,
      );
    } catch (e) {
      // Handle error fetching keys
      print('Failed to fetch Remote Config keys: $e');
      state = ApiKeysState(rapidApiKey: '', rapidApiHost: '', isLoading: false);
    }
  }
}

final apiKeysProvider = StateNotifierProvider<ApiKeysNotifier, ApiKeysState>((ref) => ApiKeysNotifier());