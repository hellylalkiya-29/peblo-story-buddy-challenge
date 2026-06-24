import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BuddyMood {
  idle,
  speaking,
  happy,
  sad,
}

class BuddyNotifier extends StateNotifier<BuddyMood> {
  BuddyNotifier() : super(BuddyMood.idle);

  void setIdle() {
    state = BuddyMood.idle;
  }

  void setSpeaking() {
    state = BuddyMood.speaking;
  }

  void setHappy() {
    state = BuddyMood.happy;
  }

  void setSad() {
    state = BuddyMood.sad;
  }
}

final buddyProvider =
    StateNotifierProvider<BuddyNotifier, BuddyMood>(
  (ref) => BuddyNotifier(),
);