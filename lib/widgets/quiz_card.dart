import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/quiz_provider.dart';
import 'option_button.dart';

class QuizCard extends ConsumerStatefulWidget {
  const QuizCard({super.key});

  @override
  ConsumerState<QuizCard> createState() =>
      _QuizCardState();
}

class _QuizCardState
    extends ConsumerState<QuizCard> {
  late ConfettiController confettiController;

  bool wrongAnswer = false;

  @override
  void initState() {
    super.initState();

    confettiController =
        ConfettiController(
      duration:
          const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void selectAnswer(String option) {
    final quizNotifier =
        ref.read(
      quizProvider.notifier,
    );

    bool correct =
        quizNotifier.checkAnswer(option);

    if (correct) {
      confettiController.play();
    } else {
      HapticFeedback.mediumImpact();

      setState(() {
        wrongAnswer = true;
      });

      Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
        () {
          if (mounted) {
            setState(() {
              wrongAnswer = false;
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizState =
        ref.watch(quizProvider);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ConfettiWidget(
          confettiController:
              confettiController,
          blastDirectionality:
              BlastDirectionality
                  .explosive,
          shouldLoop: false,
        ),

        AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 300,
          ),
          transform:
              Matrix4.translationValues(
            wrongAnswer ? 12 : 0,
            0,
            0,
          ),
          child: Card(
            elevation: 6,
            child: Padding(
              padding:
                  const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    quizState.quiz.question,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  ...quizState.quiz.options
                      .map(
                    (option) =>
                        Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 12,
                      ),
                      child:
                          OptionButton(
                        text: option,
                        onTap: () =>
                            selectAnswer(
                          option,
                        ),
                      ),
                    ),
                  ),

                  if (quizState
                          .status ==
                      QuizStatus
                          .success)
                    Container(
                      margin:
                          const EdgeInsets
                              .only(
                        top: 20,
                      ),
                      padding:
                          const EdgeInsets
                              .all(16),
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .green
                            .shade100,
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                      ),
                      child:
                          const Column(
                        children: [
                          Text(
                            "🎉 Awesome!",
                            style:
                                TextStyle(
                              fontSize:
                                  22,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          SizedBox(
                              height:
                                  8),
                          Text(
                            "You got it right!",
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}