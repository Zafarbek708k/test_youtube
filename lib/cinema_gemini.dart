import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_youtube/bloc/you_tube_player_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:ui';

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon Cinema',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C5DD3), // Modern Purple
          secondary: Color(0xFF00C2FF), // Cyber Blue
          surface: Color(0xFF1A1A24),
        ),
      ),
      home: const YoutubePlayerScreen(),
    );
  }
}

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
          progressIndicatorColor: const Color(0xFF6C5DD3),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xFF6C5DD3),
            handleColor: Color(0xFF00C2FF),
            bufferedColor: Colors.white24,
            backgroundColor: Colors.white10,
          ),
          onReady: () => _bloc.add(PlayerInitialized()),
          onEnded: (data) => _bloc.add(VideoEnded(data.videoId)),
        ),
        builder: (context, player) => Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, -0.8),
                radius: 1.5,
                colors: [Color(0xFF1A1A2E), Color(0xFF0D0D12)],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C5DD3).withValues(alpha: 0.2),
                              blurRadius: 40,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: player,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _VideoModernDetails()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          children: [
            TextSpan(
              text: 'Neo',
              style: TextStyle(color: Colors.white),
            ),
            TextSpan(
              text: 'Stream',
              style: TextStyle(color: Color(0xFF6C5DD3)),
            ),
          ],
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          child: const Icon(Icons.search, color: Colors.white70, size: 20),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          child: const Icon(Icons.person_outline, color: Colors.white70, size: 20),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _VideoModernDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YouTubePlayerBloc, YouTubePlayerState>(
      builder: (context, state) {
        final bloc = context.read<YouTubePlayerBloc>();
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.metaData.title.isEmpty ? "Initializing..." : state.metaData.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoBadge(icon: Icons.hd_outlined, label: state.playbackQuality ?? 'Auto'),
                  const SizedBox(width: 8),
                  _InfoBadge(icon: Icons.speed, label: '${state.playbackRate}x'),
                ],
              ),
              const SizedBox(height: 30),

              // New Glassmorphic Control Panel
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TransparentIconButton(
                      icon: Icons.skip_previous_rounded,
                      onPressed: () => bloc.add(PreviousVideo()),
                    ),
                    _PlayButton(isPlaying: state.isPlaying, onPressed: () => bloc.add(PlayPauseToggled())),
                    _TransparentIconButton(icon: Icons.skip_next_rounded, onPressed: () => bloc.add(NextVideo())),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                "UP NEXT",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              _ModernPlaylist(state: state, bloc: bloc),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// UI COMPONENTS
// ─────────────────────────────────────────────

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF00C2FF)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const _PlayButton({required this.isPlaying, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 70,
        width: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF6C5DD3), Color(0xFF8E81EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Color(0x446C5DD3), blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 35),
      ),
    );
  }
}

class _TransparentIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _TransparentIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 28),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}

class _ModernPlaylist extends StatelessWidget {
  final YouTubePlayerState state;
  final YouTubePlayerBloc bloc;

  const _ModernPlaylist({required this.state, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.ids.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        bool isActive = state.currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6C5DD3).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? const Color(0xFF6C5DD3).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 50,
                height: 50,
                color: isActive ? const Color(0xFF6C5DD3) : Colors.white10,
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.white30),
                  ),
                ),
              ),
            ),
            title: Text(
              "Video ID: ${state.ids[index]}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : Colors.white70,
              ),
            ),
            subtitle: Text(
              isActive ? "Now Playing" : "Tap to play",
              style: TextStyle(fontSize: 12, color: isActive ? const Color(0xFF00C2FF) : Colors.white24),
            ),
            trailing: Icon(
              isActive ? Icons.bar_chart_rounded : Icons.play_circle_outline,
              color: isActive ? const Color(0xFF00C2FF) : Colors.white24,
            ),
            onTap: () => bloc.controller.load(state.ids[index]),
          ),
        );
      },
    );
  }
}
