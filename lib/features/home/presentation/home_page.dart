// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tik_saver/features/home/presentation/widgets/utils.dart';
import 'package:tik_saver/features/search/pages/search_page.dart';
import 'package:tik_saver/features/profile/pages/profile_page.dart';

import '../../downloads/presentation/downloads_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _pageTitles = [
    'Home',
    'Search',
    'Downloads',
    'Profile',
  ];

  final List<Widget> _pages = [
    const VideoFeedWidget(),
    const SearchPage(),
    const DownloadsPage(),
    const ProfilePage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_pageTitles[_pageIndex]), // ⭐ MODIFIED: Dynamic title
        centerTitle: true,
        leading: _pageIndex == 0
            ? null // Hide back button on the home page
            : IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            // This back button can navigate to the previous screen if needed
            // For a tab navigation, you might not need this
            _pageController.jumpToPage(0);
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Theme.of(context).primaryColor,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        index: _pageIndex,
        height: 60.0,
        animationDuration: const Duration(milliseconds: 300),
        items: <Widget>[
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.search, 'Search', 1),
          _buildNavItem(Icons.download, 'Downloads', 2),
          _buildNavItem(Icons.person, 'Profile', 3),
        ],
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String text, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: _pageIndex == index ? Colors.white : Colors.white70,
        ),
        // Text(
        //   text,
        //   style: TextStyle(
        //     fontSize: 10,
        //     color: _pageIndex == index ? Colors.white : Colors.white70,
        //   ),
        // ),
      ],
    );
  }
}