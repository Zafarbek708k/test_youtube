import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

part 'you_tube_player_event.dart';

part 'you_tube_player_state.dart';

class YouTubePlayerBloc extends Bloc<YouTubePlayerEvent, YouTubePlayerState> {
  final YoutubePlayerController controller;

  YouTubePlayerBloc(this.controller) : super(YouTubePlayerState(ids: ['-l8-B2MtF84', 'AnVO_pFyz7o', 'EZ7dZklX81U'])) {
    on<YouTubePlayerEvent>((event, emit) {});
    on<PlayerInitialized>(_onPlayerInitialized);
    on<PlayPauseToggled>(_onPlayPauseToggled);
    on<MuteToggled>(_onMuteToggled);
    on<VolumeChanged>(_onVolumeChanged);
    on<VideoEnded>(_onVideoEnded);
    on<NextVideo>(_onNextVideo);
    on<PreviousVideo>(_onPreviousVideo);
    on<MetadataUpdated>(_onMetadataUpdated);
  }

  void _onPlayerInitialized(PlayerInitialized event, Emitter<YouTubePlayerState> emit) {
    emit(state.copyWith(isPlayerReady: true));
  }

  void _onPlayPauseToggled(PlayPauseToggled event, Emitter<YouTubePlayerState> emit) {
    if (state.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    emit(state.copyWith(isPlaying: !state.isPlaying));
  }

  void _onMuteToggled(MuteToggled event, Emitter<YouTubePlayerState> emit) {
    if (state.isMuted) {
      controller.unMute();
    } else {
      controller.mute();
    }
    emit(state.copyWith(isMuted: !state.isMuted));
  }

  void _onVolumeChanged(VolumeChanged event, Emitter<YouTubePlayerState> emit) {
    controller.setVolume(event.volume.round());
    emit(state.copyWith(volume: event.volume));
  }

  void _onVideoEnded(VideoEnded event, Emitter<YouTubePlayerState> emit) {
    final nextIndex = (state.currentIndex + 1) % state.ids.length;
    controller.load(state.ids[nextIndex]);
    emit(state.copyWith(currentIndex: nextIndex, isPlaying: true));
  }

  void _onNextVideo(NextVideo event, Emitter<YouTubePlayerState> emit) {
    final nextIndex = (state.currentIndex + 1) % state.ids.length;
    controller.load(state.ids[nextIndex]);
    emit(state.copyWith(currentIndex: nextIndex, isPlaying: true));
  }

  void _onPreviousVideo(PreviousVideo event, Emitter<YouTubePlayerState> emit) {
    final prevIndex = (state.currentIndex - 1 + state.ids.length) % state.ids.length;
    controller.load(state.ids[prevIndex]);
    emit(state.copyWith(currentIndex: prevIndex, isPlaying: true));
  }

  void _onMetadataUpdated(MetadataUpdated event, Emitter<YouTubePlayerState> emit) {
    emit(
      state.copyWith(
        metaData: event.metaData,
        playerState: event.playerState,
        playbackQuality: event.quality,
        playbackRate: event.playbackRate,
        isPlaying: event.playerState == PlayerState.playing,
      ),
    );
  }
}
