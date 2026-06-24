import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_provider.dart';
import '../services/tts_service.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  final TtsService _tts = TtsService();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);
    final notifier = ref.read(quizProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFB3E5FC), // Light Blue Background
      body: Stack(
        children: [
          // Background Elements
          Align(alignment: Alignment.topCenter, child: Padding(padding: const EdgeInsets.only(top: 50), child: Icon(Icons.smart_toy, size: 100))),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Peblo Story Buddy", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                
                // Card for Story/Quiz
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      if (state == QuizState.idle)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
                          onPressed: () {
                            notifier.startAudio();
                            _tts.speak("Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods.", () => notifier.showQuiz());
                          },
                          child: const Text("Read Me a Story", style: TextStyle(fontSize: 18)),
                        ),

                      if (state != QuizState.idle) ...[
                        Text(notifier.quizData.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        ...notifier.quizData.options.map((opt) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: state == QuizState.wrong && opt == "Red" ? Colors.red : Colors.blueGrey.shade100),
                            onPressed: () => notifier.checkAnswer(opt),
                            child: Text(opt),
                          ).animate(target: state == QuizState.wrong && opt == "Red" ? 1 : 0).shake(),
                        )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (state == QuizState.correct) 
            Align(alignment: Alignment.center, child: ConfettiWidget(confettiController: _confettiController..play())),
        ],
      ),
    );
  }
}