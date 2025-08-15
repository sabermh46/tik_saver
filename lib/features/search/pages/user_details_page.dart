import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tik_saver/core/utils/count_utils.dart';
import 'package:tik_saver/features/search/domain/models/user_model.dart';
import 'package:tik_saver/features/search/providers/user_videos_provider.dart';
import 'package:tik_saver/features/home/presentation/widgets/video_card.dart';
import 'package:tik_saver/features/search/presentation/widgets/user_videos_shimmer.dart'; // ⭐ NEW: Import shimmer widget

class UserDetailsPage extends ConsumerStatefulWidget {
  final UserModel user;

  const UserDetailsPage({required this.user, super.key});

  @override
  ConsumerState<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends ConsumerState<UserDetailsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userVideosProvider(widget.user.uniqueId).notifier).fetchUserVideos(widget.user.uniqueId, widget.user.id);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final videosState = ref.read(userVideosProvider(widget.user.uniqueId));
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      if (!videosState.isLoading && videosState.hasMore) {
        ref.read(userVideosProvider(widget.user.uniqueId).notifier).fetchUserVideos(
          widget.user.uniqueId,
          widget.user.id,
          cursor: videosState.nextCursor,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videosState = ref.watch(userVideosProvider(widget.user.uniqueId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.nickname),
        centerTitle: true,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.user.avatar),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.user.nickname,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${widget.user.uniqueId}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.user.signature,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Followers', formatNumber(widget.user.followerCount)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Videos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (videosState.isLoading && videosState.videos.isEmpty)
            const SliverToBoxAdapter(child: UserVideosShimmer())
          else if (videosState.error != null)
            SliverToBoxAdapter(child: Center(child: Text(videosState.error!)))
          else if (videosState.videos.isEmpty)
              const SliverToBoxAdapter(child: Center(child: Text('No videos found for this user.')))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index < videosState.videos.length) {
                        final video = videosState.videos[index];
                        return VideoCard(video: video);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                    childCount: videosState.videos.length + (videosState.hasMore ? 1 : 0),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}