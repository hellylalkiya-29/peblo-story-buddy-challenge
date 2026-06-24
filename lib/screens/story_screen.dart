import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_provider.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);
    final notifier = ref.read(quizProvider.notifier);

    // 🎉 Confetti trigger karo jab correct answer ho
    if (state == QuizState.correct) {
      _confettiController.play();
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── 1. GRADIENT BACKGROUND ──────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD6E0), // pink top-left
                  Color(0xFFD6F0FF), // light blue
                  Color(0xFFD6FFE8), // mint green bottom
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── 2. DECORATIVE BACKGROUND CIRCLES (depth effect) ─────
          Positioned(
            top: -60,
            left: -60,
            child: _pastelCircle(180, const Color(0xFFFFB3C6)),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _pastelCircle(220, const Color(0xFFB3D9FF)),
          ),

          // ── 3. CONFETTI ─────────────────────────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
              ],
            ),
          ),

          // ── 4. MAIN CONTENT ─────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ── ROBOT MASCOT ─────────────────────────────────
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow ring behind robot
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.25),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    // Robot face card
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const _RobotFace(),
                    ),
                    // Success star badge
                    if (state == QuizState.correct)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 14),
                              SizedBox(width: 2),
                              Text(
                                "Success!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(
                              begin: const Offset(0, 0),
                              end: const Offset(1, 1),
                            ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── APP TITLE ────────────────────────────────────
                if (state == QuizState.idle)
                  const Text(
                    "Peblo Story Buddy",
                    style: TextStyle(
                      fontSize: 32,
                        fontWeight: FontWeight.w900,
                      color: Color(0xFF3A3A5C),
                      letterSpacing: 0.5,
                    ),
                  ),

                const SizedBox(height: 20),

                // ── QUIZ / IDLE CARD ─────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: state == QuizState.idle
                          ? _IdleContent(notifier: notifier)
                          : _QuizContent(state: state, notifier: notifier),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pastelCircle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.35),
        ),
      );
}

// ── ROBOT FACE (drawn with widgets, no image needed) ──────────────────────────
class _RobotFace extends StatelessWidget {
  const _RobotFace();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _RobotPainter());
  }
}

class _RobotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF8EA8C3);
    final w = size.width;
    final h = size.height;

    // Head
    final headRect =
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.2, w * 0.7, h * 0.55), const Radius.circular(12));
    canvas.drawRRect(headRect, paint);

    // Antenna
    final antennaPaint = Paint()
      ..color = const Color(0xFF8EA8C3)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.2), Offset(w * 0.5, h * 0.1), antennaPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.08), 4, Paint()..color = Colors.redAccent);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.35, h * 0.42), 8, eyePaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.42), 8, eyePaint);
    final pupilPaint = Paint()..color = const Color(0xFF3A3A5C);
    canvas.drawCircle(Offset(w * 0.35, h * 0.42), 4, pupilPaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.42), 4, pupilPaint);

    // Smile
    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(w * 0.35, h * 0.62)
      ..quadraticBezierTo(w * 0.5, h * 0.72, w * 0.65, h * 0.62);
    canvas.drawPath(smilePath, smilePaint);

    // Ear bolts
    canvas.drawCircle(Offset(w * 0.15, h * 0.47), 5, Paint()..color = const Color(0xFF6A8FAF));
    canvas.drawCircle(Offset(w * 0.85, h * 0.47), 5, Paint()..color = const Color(0xFF6A8FAF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── IDLE STATE: "Read Me a Story" button ──────────────────────────────────────
class _IdleContent extends StatelessWidget {
  final dynamic notifier;
  const _IdleContent({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => notifier.startAudio(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7EC8E3),
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text("Read Me a Story"),
        ),
      ],
    );
  }
}

// ── QUIZ STATE: question + options ────────────────────────────────────────────
class _QuizContent extends StatelessWidget {
  final QuizState state;
  final dynamic notifier;
  const _QuizContent({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Robot intro line
        const Text(
          "Hi! I'm Pip.",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6A8FAF),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        // Question
        Text(
          notifier.quizData.question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3A3A5C),
          ),
        ),

        const SizedBox(height: 6),

        // "Incorrect!" label
        if (state == QuizState.wrong)
          const Text(
            "Incorrect!",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ).animate().shake(),

        const SizedBox(height: 12),

        // Answer options
        ...notifier.quizData.options.map<Widget>((opt) {
          Color bgColor = const Color(0xFFECF0F1); // default grey
          Color borderColor = Colors.transparent;
          Widget? trailingIcon;

          if (state == QuizState.correct && opt == notifier.quizData.answer) {
            // ✅ Correct answer
            bgColor = Colors.white;
            borderColor = const Color(0xFFFFD700); // gold border
            trailingIcon = const Icon(Icons.check, color: Color(0xFFFFD700));
          } else if (state == QuizState.wrong && opt == "Red") {
            // ❌ Wrong answer (jo unhone chuna)
            bgColor = const Color(0xFFFFCDD2);
            borderColor = Colors.redAccent;
            trailingIcon = const Icon(Icons.close, color: Colors.redAccent);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                dense: true,
                title: Text(
                  opt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A3A5C),
                  ),
                ),
                trailing: trailingIcon,
                onTap: () => notifier.checkAnswer(opt),
              ),
            ),
          );
        }),

        // Story excerpt at bottom
        const SizedBox(height: 16),
        Text(
          "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}