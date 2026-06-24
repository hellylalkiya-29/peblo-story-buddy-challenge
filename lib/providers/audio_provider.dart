import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AudioStatus {
  idle,
  loading,
  playing,
  completed,
  error,
}

class AudioNotifier extends StateNotifier<AudioStatus> {
  AudioNotifier() : super(AudioStatus.idle);

  void setLoading() {
    state = AudioStatus.loading;
  }

  void setPlaying() {
    state = AudioStatus.playing;
  }

  void setCompleted() {
    state = AudioStatus.completed;
  }

  void setError() {
    state = AudioStatus.error;
  }

  void reset() {
    state = AudioStatus.idle;
  }
}

final audioProvider =
    StateNotifierProvider<AudioNotifier, AudioStatus>(
  (ref) => AudioNotifier(),
);