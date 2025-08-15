// lib/features/home/domain/repositories/video_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tik_saver/core/services/api_key_service.dart';
import 'package:tik_saver/features/home/domain/models/video_model.dart';

class VideoRepository {
  final Ref ref;

  VideoRepository(this.ref);

  Future<List<VideoModel>> fetchFeedVideos(String region, int count) async {
    final apiKeys = ref.read(apiKeysProvider);

    if (apiKeys.rapidApiKey.isEmpty || apiKeys.rapidApiHost.isEmpty) {
      throw Exception('API keys are not available.');
    }

    final url = Uri.https(
      apiKeys.rapidApiHost,
      '/feed/list',
      {'region': region, 'count': count.toString()},
    );

    final headers = {
      'x-rapidapi-key': apiKeys.rapidApiKey,
      'x-rapidapi-host': apiKeys.rapidApiHost,
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Check if the response body is not empty before decoding
      if (response.body.isNotEmpty) {
        final jsonResponse = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonResponse);
        return apiResponse.data;
      } else {
        // Handle empty body gracefully, returning an empty list
        return [];
      }
    } else {
      // Handle non-200 status codes
      throw Exception('Failed to load videos. Status code: ${response.statusCode}');
    }
  }
}