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

/// Play a specific item from the playlist (e.g. tapping "Up next").
class VideoSelected extends YouTubePlayerEvent {
  final int index;

  const VideoSelected(this.index);

  @override
  List<Object?> get props => [index];
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
