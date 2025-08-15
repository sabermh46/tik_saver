// lib/features/profile/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tik_saver/features/auth/provider/auth_provider.dart';
import 'package:tik_saver/features/downloads/presentation/downloads_page.dart'; // Import the DownloadsPage

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authProvider to get the current user state
    final authState = ref.watch(authProvider);

    // Get the user from the state; it can be null if not logged in
    final user = authState.user;
    final userEmail = user?.email ?? 'Not Logged In';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://www.gravatar.com/avatar?d=mp'),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              userEmail,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // This is correct as it is
                ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}