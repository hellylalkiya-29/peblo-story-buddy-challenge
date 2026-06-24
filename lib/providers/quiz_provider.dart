import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz_model.dart';

enum QuizState { idle, audioPlaying, quizVisible, correct, wrong }

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>(
  (ref) => QuizNotifier(),
);

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(QuizState.idle);

  // ── flutter_tts instance ──────────────────────────────────────
  final FlutterTts _tts = FlutterTts();

  final quizData = QuizModel.fromJson({
    "question": "What colour was Pip the Robot's lost gear?",
    "options": ["Red", "Green", "Blue", "Yellow"],
    "answer": "Blue",
  });

  // Story text jo TTS bolega
  static const String _storyText =
      "Once upon a time, a clever little robot named Pip "
      "lost his shiny blue gear in the Whispering Woods. "
      "He searched and searched, but could not find it. "
      "Can you help Pip find the right answer?";

  // ── startAudio: TTS play karo, phir quiz dikhao ──────────────
  Future<void> startAudio() async {
    state = QuizState.audioPlaying;

    // TTS settings
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);   // thoda slow — children ke liye
    await _tts.setPitch(1.2);         // slightly high — friendly voice

    // Jab TTS complete ho, quiz show karo
    _tts.setCompletionHandler(() {
      if (mounted) state = QuizState.quizVisible;
    });

    await _tts.speak(_storyText);
  }

  // ── checkAnswer ───────────────────────────────────────────────
  void checkAnswer(String selected) {
    state = (selected == quizData.answer) ? QuizState.correct : QuizState.wrong;
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