import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class AudioPlayerButton extends StatefulWidget {
  final String? audioUrl;
  final double size;

  const AudioPlayerButton({
    super.key,
    this.audioUrl,
    this.size = 64,
  });

  @override
  State<AudioPlayerButton> createState() => _AudioPlayerButtonState();
}

class _AudioPlayerButtonState extends State<AudioPlayerButton> {
  bool _isPlaying = false;

  Future<void> _togglePlay() async {
    if (widget.audioUrl == null) return;
    if (_isPlaying) {
      await AudioService.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await AudioService.playUrl(widget.audioUrl!);
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAudio = widget.audioUrl != null;
    return GestureDetector(
      onTap: hasAudio ? _togglePlay : null,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: hasAudio ? AppColors.primary : Colors.grey.shade300,
          shape: BoxShape.circle,
          boxShadow: hasAudio
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          _isPlaying ? Icons.stop : Icons.volume_up,
          color: Colors.white,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}
