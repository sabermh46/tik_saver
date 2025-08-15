import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tik_saver/features/search/pages/user_details_page.dart';
import 'package:tik_saver/features/search/providers/search_provider.dart';
import 'package:tik_saver/features/home/presentation/widgets/video_card.dart';
import 'package:tik_saver/features/search/presentation/widgets/search_shimmers.dart'; // ⭐ NEW: Import shimmer widgets

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final searchState = ref.read(searchProvider);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      if (!searchState.isLoading && !searchState.isPaginating && searchState.hasMore) {
        ref.read(searchProvider.notifier).search(
          _searchController.text,
          cursor: searchState.nextCursor,
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: Colors.white, // ⭐ MODIFIED: White background
      appBar: AppBar(
        title: const SizedBox.shrink(), // ⭐ MODIFIED: Remove title
        toolbarHeight: 0, // ⭐ MODIFIED: Reduce appbar height
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0), // ⭐ MODIFIED: Cute padding
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for videos or users...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0), // ⭐ MODIFIED: Add content padding
                filled: false, // ⭐ MODIFIED: No background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      ref.read(searchProvider.notifier).resetSearch();
                      ref.read(searchProvider.notifier).search(_searchController.text);
                    }
                  },
                ),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  ref.read(searchProvider.notifier).resetSearch();
                  ref.read(searchProvider.notifier).search(query);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (searchState.searchType != SearchType.videos) {
                        ref.read(searchProvider.notifier).setSearchType(SearchType.videos);
                        if (_searchController.text.isNotEmpty) {
                          ref.read(searchProvider.notifier).search(_searchController.text);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: searchState.searchType == SearchType.videos ? Theme.of(context).primaryColor : Colors.grey[300],
                      foregroundColor: searchState.searchType == SearchType.videos ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Videos'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (searchState.searchType != SearchType.users) {
                        ref.read(searchProvider.notifier).setSearchType(SearchType.users);
                        if (_searchController.text.isNotEmpty) {
                          ref.read(searchProvider.notifier).search(_searchController.text);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: searchState.searchType == SearchType.users ? Theme.of(context).primaryColor : Colors.grey[300],
                      foregroundColor: searchState.searchType == SearchType.users ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Users'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildResultsList(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(SearchState searchState) {
    if (searchState.isLoading) {
      if (searchState.searchType == SearchType.videos) {
        return const VideoShimmerGrid(); // ⭐ MODIFIED: Use video shimmer
      } else {
        return const UserShimmerList(); // ⭐ MODIFIED: Use user shimmer
      }
    }

    if (searchState.error != null) {
      return Center(child: Text(searchState.error!));
    }

    if (searchState.searchType == SearchType.videos) {
      if (searchState.videos.isEmpty) {
        return const Center(child: Text('No videos found.'));
      }
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.7,
        ),
        itemCount: searchState.videos.length + (searchState.isPaginating ? 1 : 0), // ⭐ MODIFIED: Check for isPaginating
        itemBuilder: (context, index) {
          if (index == searchState.videos.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final video = searchState.videos[index];
          return VideoCard(video: video);
        },
      );
    } else { // SearchType.users
      if (searchState.users.isEmpty) {
        return const Center(child: Text('No users found.'));
      }
      return ListView.builder(
        controller: _scrollController,
        itemCount: searchState.users.length + (searchState.isPaginating ? 1 : 0), // ⭐ MODIFIED: Check for isPaginating
        itemBuilder: (context, index) {
          if (index == searchState.users.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = searchState.users[index];
          return ListTile(
            onTap: (){
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => UserDetailsPage(user: user)
                  )
              );
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatar),
            ),
            title: Text(user.nickname),
            subtitle: Text('@${user.uniqueId}'),
            trailing: Text(
              '${user.followerCount} followers',
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      );
    }
  }
}