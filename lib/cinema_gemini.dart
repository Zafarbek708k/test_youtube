import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'bloc/you_tube_player_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Sarbon palette — primary green, action blue, light surfaces, black/gray text.
// ─────────────────────────────────────────────────────────────────────────────
const _green = Color(0xFF26BD49); // Sarbon primary
const _blue = Color(0xFF007AFF); // Sarbon action/button
const _scaffold = Color(0xFFF3F6FB);
const _card = Colors.white;
const _textPrimary = Color(0xFF1A1A1E);
const _textSecondary = Color(0xFF8E95A5);
const _divider = Color(0xFFE9EDF2);

/// Fallback playlist used when the screen is opened without [sources]
/// (e.g. local/standalone testing).
const _fallbackIds = ['-l8-B2MtF84', 'AnVO_pFyz7o', 'EZ7dZklX81U'];

/// Resolves a source string (a full YouTube URL or a bare video id) to a video
/// id. Returns null for empty/invalid input.
String? _resolveVideoId(String src) {
  final s = src.trim();
  if (s.isEmpty) return null;
  if (s.startsWith('http') || s.contains('youtu')) {
    return YoutubePlayer.convertUrlToId(s);
  }
  return s; // already an id
}

/// Video-instruction screen for the Sarbon app.
///
/// Pass [initialSource] (the video to open first) and [sources] (the full
/// playlist). Each may be a YouTube URL or a bare video id:
///
/// ```dart
/// YoutubePlayerScreen(
///   initialSource: 'https://youtu.be/-l8-B2MtF84',
///   sources: ['-l8-B2MtF84', 'AnVO_pFyz7o'],
/// )
/// ```
class YoutubePlayerScreen extends StatefulWidget {
  const YoutubePlayerScreen({
    super.key,
    this.initialSource = '',
    this.sources = const [],
  });

  final String initialSource;
  final List<String> sources;

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late final YoutubePlayerController _controller;
  late final YouTubePlayerBloc _bloc;

  /// Builds the ordered playlist: [initialSource] first, then the rest of
  /// [sources] (de-duplicated), falling back to a sample list if both are empty.
  List<String> _buildIds() {
    final resolved = widget.sources.map(_resolveVideoId).whereType<String>().toList();
    final initial = _resolveVideoId(widget.initialSource);
    final ids = <String>[
      if (initial != null) initial,
      ...resolved.where((id) => id != initial),
    ];
    return ids.isEmpty ? List<String>.from(_fallbackIds) : ids;
  }

  @override
  void initState() {
    super.initState();
    final ids = _buildIds();
    _controller = YoutubePlayerController(
      initialVideoId: ids.first,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
    _bloc = YouTubePlayerBloc(_controller, ids: ids);
    _controller.addListener(_listener);
  }

  void _listener() {
    if (_bloc.state.isPlayerReady && mounted && !_controller.value.isFullScreen) {
      _bloc.add(
        MetadataUpdated(
          metaData: _controller.metadata,
          playerState: _controller.value.playerState,
          quality: _controller.value.playbackQuality,
          playbackRate: _controller.value.playbackRate,
        ),
      );
    }
  }

  @override
  void deactivate() {
    // Pause when navigating away so audio doesn't keep playing.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: YoutubePlayerBuilder(
        onExitFullScreen: () => SystemChrome.setPreferredOrientations(DeviceOrientation.values),
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: _green,
          progressColors: const ProgressBarColors(
            playedColor: _green,
            handleColor: _blue,
            bufferedColor: Color(0x5526BD49),
            backgroundColor: Color(0x22000000),
          ),
          onReady: () => _bloc.add(PlayerInitialized()),
          onEnded: (data) => _bloc.add(VideoEnded(data.videoId)),
        ),
        builder: (context, player) => _VideoScaffold(player: player),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Scaffold — green Sarbon-style app bar + light body.
// ─────────────────────────────────────────────────────────────────────────────
class _VideoScaffold extends StatelessWidget {
  const _VideoScaffold({required this.player});

  final Widget player;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffold,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: AppBar(
            backgroundColor: _green,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Video qo‘llanma',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.black,
            child: player,
          ),
          const _InfoPanel(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Info panel — title, meta, controls, volume, up-next.
// ─────────────────────────────────────────────────────────────────────────────
class _InfoPanel extends StatelessWidget {
  const _InfoPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YouTubePlayerBloc, YouTubePlayerState>(
      builder: (context, state) {
        final bloc = context.read<YouTubePlayerBloc>();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title.
              Text(
                state.metaData.title.isEmpty ? 'Yuklanmoqda…' : state.metaData.title,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              // Meta row.
              Row(
                children: [
                  _StatusChip(playing: state.isPlaying),
                  const SizedBox(width: 8),
                  Text(
                    '${state.currentIndex + 1}/${state.ids.length}  ·  ${state.playbackQuality ?? 'HD'}',
                    style: const TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Controls card.
              _ControlsCard(state: state, bloc: bloc),
              const SizedBox(height: 20),
              // Volume.
              _VolumeBar(state: state, bloc: bloc),
              const SizedBox(height: 24),
              const Divider(color: _divider, height: 1),
              const SizedBox(height: 20),
              const Text(
                'Keyingi videolar',
                style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _UpNextList(state: state, bloc: bloc),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.playing});
  final bool playing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(playing ? Icons.play_arrow_rounded : Icons.pause_rounded, color: _green, size: 14),
          const SizedBox(width: 4),
          Text(
            playing ? 'Ijro etilmoqda' : 'To‘xtatilgan',
            style: const TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Controls — green icon buttons + a blue play button.
// ─────────────────────────────────────────────────────────────────────────────
class _ControlsCard extends StatelessWidget {
  const _ControlsCard({required this.state, required this.bloc});
  final YouTubePlayerState state;
  final YouTubePlayerBloc bloc;

  @override
  Widget build(BuildContext context) {
    final ready = state.isPlayerReady;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _IconBtn(icon: Icons.skip_previous_rounded, enabled: ready, onTap: () => bloc.add(PreviousVideo())),
          _IconBtn(
            icon: state.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            enabled: ready,
            onTap: () => bloc.add(MuteToggled()),
          ),
          // Play / pause — blue action button.
          GestureDetector(
            onTap: ready ? () => bloc.add(PlayPauseToggled()) : null,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: ready ? _blue : _divider,
                shape: BoxShape.circle,
                boxShadow: ready
                    ? [BoxShadow(color: _blue.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))]
                    : null,
              ),
              child: Icon(
                state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          _IconBtn(
            icon: Icons.fullscreen_rounded,
            enabled: ready,
            onTap: () => bloc.controller.toggleFullScreenMode(),
          ),
          _IconBtn(icon: Icons.skip_next_rounded, enabled: ready, onTap: () => bloc.add(NextVideo())),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: _green.withValues(alpha: enabled ? 0.10 : 0.04),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: enabled ? _green : _textSecondary.withValues(alpha: 0.4), size: 24),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Volume — green track.
// ─────────────────────────────────────────────────────────────────────────────
class _VolumeBar extends StatelessWidget {
  const _VolumeBar({required this.state, required this.bloc});
  final YouTubePlayerState state;
  final YouTubePlayerBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.volume_mute_rounded, color: _textSecondary, size: 20),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _green,
              inactiveTrackColor: _divider,
              thumbColor: _green,
              overlayColor: _green.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: state.volume,
              min: 0,
              max: 100,
              onChanged: state.isPlayerReady ? (v) => bloc.add(VolumeChanged(v)) : null,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${state.volume.round()}',
            textAlign: TextAlign.end,
            style: const TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Up next — light cards with a green active accent + real thumbnails.
// ─────────────────────────────────────────────────────────────────────────────
class _UpNextList extends StatelessWidget {
  const _UpNextList({required this.state, required this.bloc});
  final YouTubePlayerState state;
  final YouTubePlayerBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(state.ids.length, (i) {
        final isActive = i == state.currentIndex;
        final id = state.ids[i];
        return GestureDetector(
          onTap: isActive ? null : () => bloc.add(VideoSelected(i)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? _green.withValues(alpha: 0.08) : _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isActive ? _green : _divider, width: isActive ? 1.4 : 1),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    'https://img.youtube.com/vi/$id/hqdefault.jpg',
                    width: 96,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 96,
                      height: 60,
                      color: _divider,
                      child: const Icon(Icons.movie_outlined, color: _textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}-video',
                        style: TextStyle(
                          color: isActive ? _green : _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isActive ? 'Hozir ijro etilmoqda' : 'Ko‘rish uchun bosing',
                        style: const TextStyle(color: _textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isActive ? Icons.graphic_eq_rounded : Icons.play_circle_outline_rounded,
                  color: isActive ? _green : _textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Exposes the underlying controller for the fullscreen toggle.
extension on YouTubePlayerBloc {
  YoutubePlayerController get controller => (this as dynamic).controller;
}
