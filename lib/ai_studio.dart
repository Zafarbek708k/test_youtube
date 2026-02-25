import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'bloc/you_tube_player_bloc.dart';

// --- (Keep your existing main(), CinemaApp, YoutubePlayerScreen, and Bloc/Event/State classes here) ---

class CinemaScaffold extends StatelessWidget {
  final Widget player;

  const CinemaScaffold({required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // True OLED Black
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Premium App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE8C97A), Color(0xFFB8943A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [BoxShadow(color: Color(0x44E8C97A), blurRadius: 12, offset: Offset(0, 4))],
                        ),
                        child: const Icon(Icons.movie_creation_rounded, color: Color(0xFF080810), size: 20),
                      ),
                      const SizedBox(width: 14),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'ABSOLUTE\n',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.5,
                                height: 1.1,
                              ),
                            ),
                            TextSpan(
                              text: 'LOGISTICS',
                              style: TextStyle(
                                color: Color(0xFFE8C97A),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 4.5,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.cast_rounded, color: Colors.white, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ── The Video Player ──
            Container(
              decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: Color(0x33E8C97A), blurRadius: 40, offset: Offset(0, 5))],
              ),
              child: player,
            ),

            // ── Scrollable Details & Up Next ──
            Expanded(
              child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: _VideoInfoPanel()),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  INFO PANEL (Scrollable Content)
// ─────────────────────────────────────────────
class _VideoInfoPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YouTubePlayerBloc, YouTubePlayerState>(
      builder: (context, state) {
        final bloc = context.read<YouTubePlayerBloc>();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Tags
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.metaData.title.isEmpty ? 'Loading Premium Content...' : state.metaData.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '#Premium #Cinematic #Logistics',
                      style: TextStyle(color: Color(0xFFE8C97A), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Channel Meta Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1A1A24),
                        border: Border.all(color: const Color(0xFFE8C97A), width: 1.5),
                        image: const DecorationImage(
                          image: NetworkImage('https://ui-avatars.com/api/?name=A+L&background=1A1A24&color=E8C97A'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.metaData.author.isEmpty ? 'Absolute Media' : state.metaData.author,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${state.currentIndex + 1} of ${state.ids.length}  ·  ${state.playbackQuality ?? '4K HD'}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    // Action Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Text(
                        'Follow',
                        style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Floating Controls Island ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ControlsIsland(state: state, bloc: bloc),
              ),

              const SizedBox(height: 28),

              // ── Sleek Volume Control ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _VolumeBar(state: state, bloc: bloc),
              ),

              const SizedBox(height: 32),

              const Divider(color: Color(0x22FFFFFF), height: 1, thickness: 1),

              const SizedBox(height: 24),

              // ── Up Next Section ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'UP NEXT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Icon(Icons.format_list_bulleted_rounded, color: Colors.white38, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _UpNextList(state: state, bloc: bloc),

              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  GLASSMORPHIC CONTROLS ISLAND
// ─────────────────────────────────────────────
class _ControlsIsland extends StatelessWidget {
  final YouTubePlayerState state;
  final YouTubePlayerBloc bloc;

  const _ControlsIsland({required this.state, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: const [BoxShadow(color: Color(0x11E8C97A), blurRadius: 30, spreadRadius: 5)],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlBtn(
            icon: Icons.skip_previous_rounded,
            enabled: state.isPlayerReady,
            onTap: () => bloc.add(PreviousVideo()),
          ),
          _ControlBtn(
            icon: state.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            enabled: state.isPlayerReady,
            onTap: () => bloc.add(MuteToggled()),
          ),
          // Play/Pause Big Center Button
          GestureDetector(
            onTap: state.isPlayerReady ? () => bloc.add(PlayPauseToggled()) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: state.isPlayerReady
                    ? const LinearGradient(
                        colors: [Color(0xFFE8C97A), Color(0xFFB8943A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(colors: [Color(0x33FFFFFF), Color(0x22FFFFFF)]),
                boxShadow: state.isPlayerReady
                    ? const [BoxShadow(color: Color(0x66E8C97A), blurRadius: 15, offset: Offset(0, 4))]
                    : [],
              ),
              child: Icon(
                state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: const Color(0xFF000000),
                size: 32,
              ),
            ),
          ),
          _ControlBtn(
            icon: Icons.fullscreen_rounded,
            enabled: state.isPlayerReady,
            onTap: () => bloc.controller.toggleFullScreenMode(),
          ),
          _ControlBtn(icon: Icons.skip_next_rounded, enabled: state.isPlayerReady, onTap: () => bloc.add(NextVideo())),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ControlBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon),
      color: enabled ? Colors.white : Colors.white24,
      iconSize: 28,
      splashColor: const Color(0xFFE8C97A).withOpacity(0.2),
      highlightColor: Colors.transparent,
    );
  }
}

// ─────────────────────────────────────────────
//  VOLUME BAR (Sleek minimalist design)
// ─────────────────────────────────────────────
class _VolumeBar extends StatelessWidget {
  final YouTubePlayerState state;
  final YouTubePlayerBloc bloc;

  const _VolumeBar({required this.state, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.volume_mute_rounded, color: Colors.white54, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFE8C97A),
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: const Color(0xFFE8C97A),
              overlayColor: const Color(0xFFE8C97A).withOpacity(0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: state.volume,
              min: 0,
              max: 100,
              onChanged: state.isPlayerReady ? (v) => bloc.add(VolumeChanged(v)) : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${state.volume.round()}%',
            style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  UP NEXT LIST (With Real Thumbnails!)
// ─────────────────────────────────────────────
class _UpNextList extends StatelessWidget {
  final YouTubePlayerState state;
  final YouTubePlayerBloc bloc;

  const _UpNextList({required this.state, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: state.ids.length,
      itemBuilder: (context, i) {
        final isActive = i == state.currentIndex;
        final videoId = state.ids[i];
        final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

        return GestureDetector(
          onTap: () {
            if (!isActive) bloc.controller.load(videoId);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Thumbnail ──
                Container(
                  width: 140,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF111118),
                    image: DecorationImage(image: NetworkImage(thumbnailUrl), fit: BoxFit.cover),
                    boxShadow: isActive
                        ? [const BoxShadow(color: Color(0x66E8C97A), blurRadius: 10, offset: Offset(0, 4))]
                        : [],
                  ),
                  child: isActive
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Icon(Icons.equalizer_rounded, color: Color(0xFFE8C97A), size: 28)),
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // ── Video Info ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Up Next Video ${i + 1}', // You can swap this with API title if available
                        style: TextStyle(
                          color: isActive ? const Color(0xFFE8C97A) : Colors.white,
                          fontSize: 15,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text('Absolute Logistics', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          videoId,
                          style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Options menu icon
                const Icon(Icons.more_vert_rounded, color: Colors.white38, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension on YouTubePlayerBloc {
  YoutubePlayerController get controller => (this as dynamic).controller;
}
