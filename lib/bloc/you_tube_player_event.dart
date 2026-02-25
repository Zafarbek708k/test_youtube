part of 'you_tube_player_bloc.dart';

sealed class YouTubePlayerEvent extends Equatable {
  const YouTubePlayerEvent();
}

class PlayerInitialized extends YouTubePlayerEvent {
  @override
  List<Object?> get props => [];
}

class PlayPauseToggled extends YouTubePlayerEvent {
  @override
  List<Object?> get props => [];
}

class MuteToggled extends YouTubePlayerEvent {
  @override
  List<Object?> get props => [];
}

class VolumeChanged extends YouTubePlayerEvent {
  final double volume;

  const VolumeChanged(this.volume);

  @override
  List<Object?> get props => [volume];
}

class VideoEnded extends YouTubePlayerEvent {
  final String videoId;

  const VideoEnded(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class NextVideo extends YouTubePlayerEvent {
  @override
  List<Object?> get props => [];
}

class PreviousVideo extends YouTubePlayerEvent {
  @override
  List<Object?> get props => [];
}

class MetadataUpdated extends YouTubePlayerEvent {
  final YoutubeMetaData metaData;
  final PlayerState playerState;
  final String? quality;
  final double? playbackRate;

  const MetadataUpdated({required this.metaData, required this.playerState, this.quality, this.playbackRate});

  @override
  List<Object?> get props => [metaData, playerState, quality ?? '', playbackRate ?? 0.0];
}
