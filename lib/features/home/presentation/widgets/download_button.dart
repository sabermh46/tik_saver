import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tik_saver/features/downloads/provider/download_provider.dart';
import 'package:shimmer/shimmer.dart';

class DownloadButton extends StatelessWidget {
  final DownloadState state;
  final VoidCallback onDownload;

  const DownloadButton({
    super.key,
    required this.state,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == DownloadStatus.downloading) {
      // Download in progress
      return _buildProgressButton(context, state.progress);
    } else if (state.status == DownloadStatus.completed) {
      // Download completed
      return _buildCompletedButton(context);
    } else if (state.status == DownloadStatus.failed ||
        state.status == DownloadStatus.permissionDenied ||
        state.status == DownloadStatus.userCanceled) {
      // Download failed/canceled
      return _buildFailedButton(context, state.error);
    } else {
      // Idle state
      return _buildIdleButton(context);
    }
  }

  Widget _buildProgressButton(BuildContext context, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 50,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedButton(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(25),
      ),
      alignment: Alignment.center,
      child: Text(
        'Download Completed',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildFailedButton(BuildContext context, String? error) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(25),
      ),
      alignment: Alignment.center,
      child: Text(
        error ?? 'Download Failed',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildIdleButton(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: InkWell(
        onTap: onDownload,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Download',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}