part of 'you_tube_player_bloc.dart';

class YouTubePlayerState extends Equatable {
  final bool isPlayerReady;
  final bool isPlaying;
  final bool isMuted;
  final double volume;
  final int currentIndex;
  final YoutubeMetaData metaData;
  final PlayerState playerState;
  final String? playbackQuality;
  final double playbackRate;
  final List<String> ids;

  const YouTubePlayerState({
    this.isPlayerReady = false,
    this.isPlaying = false,
    this.isMuted = false,
    this.volume = 100,
    this.currentIndex = 0,
    this.metaData = const YoutubeMetaData(),
    this.playerState = PlayerState.unknown,
    this.playbackQuality,
    this.playbackRate = 1.0,
    required this.ids,
  });

  YouTubePlayerState copyWith({
    bool? isPlayerReady,
    bool? isPlaying,
    bool? isMuted,
    double? volume,
    int? currentIndex,
    YoutubeMetaData? metaData,
    PlayerState? playerState,
    String? playbackQuality,
    double? playbackRate,
  }) => YouTubePlayerState(
    ids: ids,
    isPlayerReady: isPlayerReady ?? this.isPlayerReady,
    isPlaying: isPlaying ?? this.isPlaying,
    isMuted: isMuted ?? this.isMuted,
    volume: volume ?? this.volume,
    currentIndex: currentIndex ?? this.currentIndex,
    metaData: metaData ?? this.metaData,
    playerState: playerState ?? this.playerState,
    playbackQuality: playbackQuality ?? this.playbackQuality,
    playbackRate: playbackRate ?? this.playbackRate,
  );

  @override
  List<Object?> get props => [
    isPlayerReady,
    isPlaying,
    isMuted,
    volume,
    currentIndex,
    metaData,
    playerState,
    playbackQuality ?? '',
    playbackRate,
    ids,
  ];
}
