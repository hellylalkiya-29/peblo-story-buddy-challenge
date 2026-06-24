// quiz_provider.dart — TtsService wired in properly

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_model.dart';
import '../services/tts_service.dart';  // ← import karo

enum QuizState { idle, audioPlaying, quizVisible, correct, wrong }

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>(
  (ref) => QuizNotifier(),
);

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(QuizState.idle);

  // ── TtsService instance ──────────────────────────────────────
  final _tts = TtsService();  // ← yahan use karo

  final quizData = QuizModel.fromJson({
    "question": "What colour was Pip the Robot's lost gear?",
    "options": ["Red", "Green", "Blue", "Yellow"],
    "answer": "Blue",
  });

  static const String _storyText =
      "Once upon a time, a clever little robot named Pip "
      "lost his shiny blue gear in the Whispering Woods. "
      "He searched and searched, but could not find it. "
      "Can you help Pip find the right answer?";

  // ── startAudio ───────────────────────────────────────────────
  Future<void> startAudio() async {
    state = QuizState.audioPlaying;

    await _tts.speak(_storyText, () {
      // TTS khatam hone ke baad quiz dikhao
      if (mounted) state = QuizState.quizVisible;
    });
  }

  // ── checkAnswer ───────────────────────────────────────────────
  void checkAnswer(String selected) {
    state = (selected == quizData.answer)
        ? QuizState.correct
        : QuizState.wrong;
  }

  // ── reset ─────────────────────────────────────────────────────
  Future<void> reset() async {
    await _tts.stop();
    state = QuizState.idle;
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}