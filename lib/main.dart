import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_youtube/bloc/you_tube_player_bloc.dart';
import 'package:test_youtube/cinema_gemini.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
  );
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // which is horizontal
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const CinemaApp());
}

// class CinemaApp extends StatelessWidget {
//   const CinemaApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Cinema Player',
//       theme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: const Color(0xFF080810),
//         colorScheme: const ColorScheme.dark(primary: Color(0xFFE8C97A), surface: Color(0xFF0F0F1A)),
//       ),
//       home: const YoutubePlayerScreen(),
//     );
//   }
// }

class YoutubePlayerScreen extends StatefulWidget {
  const YoutubePlayerScreen({super.key});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;
  late YouTubePlayerBloc _bloc;

  final List<String> _ids = const ['-l8-B2MtF84', 'AnVO_pFyz7o', 'EZ7dZklX81U'];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: _ids.first,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
    _bloc = YouTubePlayerBloc(_controller);
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
          progressIndicatorColor: const Color(0xFFE8C97A),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xFFE8C97A),
            handleColor: Color(0xFFFFE4A3),
            bufferedColor: Color(0x55E8C97A),
            backgroundColor: Color(0x22FFFFFF),
          ),
          topActions: [
            const SizedBox(width: 12),
            Expanded(
              child: BlocBuilder<YouTubePlayerBloc, YouTubePlayerState>(
                builder: (context, state) => Text(
                  state.metaData.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
              onPressed: () {},
            ),
          ],
          onReady: () => _bloc.add(PlayerInitialized()),
          onEnded: (data) => _bloc.add(VideoEnded(data.videoId)),
        ),
        builder: (context, player) => _CinemaScaffold(player: player),
      ),
    );
  }
}

class _CinemaScaffold extends StatelessWidget {
  final Widget player;

  const _CinemaScaffold({required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 0,
            floating: true,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: const Color(0x88080810)),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: const Color(0xFFE8C97A), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.play_arrow, color: Color(0xFF080810), size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Absolute',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 4),
                ),
                const Text(
                  'Logistics',
                  style: TextStyle(
                    color: Color(0xFFE8C97A),
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),

          // Player
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: Color(0x66E8C97A), blurRadius: 30, offset: Offset(0, 10))],
              ),
              child: player,
            ),
          ),

          // Info & Controls
          SliverToBoxAdapter(child: _VideoInfoPanel()),

          // Queue hint
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  INFO PANEL
// ─────────────────────────────────────────────
class _VideoInfoPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YouTubePlayerBloc, YouTubePlayerState>(
      builder: (context, state) {
        final bloc = context.read<YouTubePlayerBloc>();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                state.metaData.title.isEmpty ? 'Loading...' : state.metaData.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  letterSpacing: -0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // Channel + Meta row
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFE8C97A), Color(0xFFB8943A)]),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.person, color: Color(0xFF080810), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.metaData.author.isEmpty ? '—' : state.metaData.author,
                          style: const TextStyle(
                            color: Color(0xFFE8C97A),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          '${state.currentIndex + 1} of ${state.ids.length}  ·  ${state.playbackQuality ?? 'HD'}  ·  ${state.playbackRate}x',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _GoldenChip(label: state.playerState == PlayerState.playing ? '▶ LIVE' : '■ IDLE'),
                ],
              ),

              const SizedBox(height: 28),

              // ── Main Controls ──
              _ControlsBar(state: state, bloc: bloc),

              const SizedBox(height: 28),

              // ── Volume ──
              _VolumeBar(state: state, bloc: bloc),

              const SizedBox(height: 28),

              // ── Video ID chip ──
              Row(
                children: [
                  const Icon(Icons.tag, color: Colors.white24, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    state.metaData.videoId.isEmpty ? '—' : state.metaData.videoId,
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Divider ──
              Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.transparent, Color(0x44E8C97A), Colors.transparent]),
                ),
              ),

              const SizedBox(height: 24),

              // ── Up Next ──
              const Text(
                'UP NEXT',
                style: TextStyle(color: Color(0xFFE8C97A), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 3),
              ),
              const SizedBox(height: 16),
              _UpNextList(state: state, bloc: bloc),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  CONTROLS BAR
// ─────────────────────────────────────────────
class _ControlsBar extends StatelessWidget {
  final YouTubePlayerState state;
  final YouTubePlayerBloc bloc;

  const _ControlsBar({required this.state, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlBtn(
          icon: Icons.skip_previous_rounded,
          size: 28,
          enabled: state.isPlayerReady,
          onTap: () => bloc.add(PreviousVideo()),
        ),
        _ControlBtn(
          icon: state.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          size: 26,
          enabled: state.isPlayerReady,
          onTap: () => bloc.add(MuteToggled()),
        ),
        // Play/Pause — gold big button
        GestureDetector(
          onTap: state.isPlayerReady ? () => bloc.add(PlayPauseToggled()) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: state.isPlayerReady
                  ? const LinearGradient(
                      colors: [Color(0xFFE8C97A), Color(0xFFB8943A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(colors: [Color(0x33FFFFFF), Color(0x22FFFFFF)]),
              borderRadius: BorderRadius.circular(34),
              boxShadow: state.isPlayerReady
                  ? const [BoxShadow(color: Color(0x66E8C97A), blurRadius: 20, offset: Offset(0, 6))]
                  : [],
            ),
            child: Icon(
              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: const Color(0xFF080810),
              size: 34,
            ),
          ),
        ),
        _ControlBtn(
          icon: Icons.fullscreen_rounded,
          size: 26,
          enabled: state.isPlayerReady,
          onTap: () => bloc.controller.toggleFullScreenMode(),
        ),
        _ControlBtn(
          icon: Icons.skip_next_rounded,
          size: 28,
          enabled: state.isPlayerReady,
          onTap: () => bloc.add(NextVideo()),
        ),
      ],
    );
  }
}

extension on YouTubePlayerBloc {
  YoutubePlayerController get controller => (this as dynamic).controller;
}

// ─────────────────────────────────────────────
//  VOLUME BAR
// ─────────────────────────────────────────────
class _VolumeBar extends StatelessWidget {
  final YouTubePlayerState state;
  final YouTubePlayerBloc bloc;

  const _VolumeBar({required this.state, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.volume_mute_rounded, color: Colors.white38, size: 18),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFE8C97A),
              inactiveTrackColor: const Color(0x22FFFFFF),
              thumbColor: const Color(0xFFE8C97A),
              overlayColor: const Color(0x22E8C97A),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              trackHeight: 3,
            ),
            child: Slider(
              value: state.volume,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: state.isPlayerReady ? (v) => bloc.add(VolumeChanged(v)) : null,
            ),
          ),
        ),
        const Icon(Icons.volume_up_rounded, color: Colors.white38, size: 18),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${state.volume.round()}',
            style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'monospace'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  UP NEXT LIST
// ─────────────────────────────────────────────
class _UpNextList extends StatelessWidget {
  final YouTubePlayerState state;
  final YouTubePlayerBloc bloc;

  const _UpNextList({required this.state, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(state.ids.length, (i) {
        final isActive = i == state.currentIndex;
        return GestureDetector(
          onTap: () {
            if (!isActive) {
              bloc.controller.load(state.ids[i]);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0x22E8C97A) : const Color(0xFF0F0F1A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isActive ? const Color(0x88E8C97A) : const Color(0x22FFFFFF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFE8C97A) : const Color(0x22FFFFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: isActive
                        ? const Icon(Icons.graphic_eq, color: Color(0xFF080810), size: 18)
                        : Text(
                            '${i + 1}',
                            style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video ${i + 1}',
                        style: TextStyle(
                          color: isActive ? const Color(0xFFE8C97A) : Colors.white70,
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      Text(
                        state.ids[i],
                        style: const TextStyle(color: Colors.white24, fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  const Icon(Icons.play_circle_fill, color: Color(0xFFE8C97A), size: 22)
                else
                  const Icon(Icons.play_circle_outline, color: Colors.white24, size: 22),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback onTap;

  const _ControlBtn({required this.icon, required this.size, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF14141F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Icon(icon, color: enabled ? Colors.white : Colors.white24, size: size),
      ),
    );
  }
}

class _GoldenChip extends StatelessWidget {
  final String label;

  const _GoldenChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x22E8C97A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x66E8C97A)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFFE8C97A), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1),
      ),
    );
  }
}
