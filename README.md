# 🤖 Peblo Story Buddy

A kid-friendly, AI-powered story narration and interactive quiz app built for Peblo's Flutter Developer Internship Challenge.

---

## 🌐 Live Demo
Check out the live app here: https://peblo-story-buddy-helly.web.app


## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Android device/emulator (API 21+) or iOS device/simulator (iOS 12+)

### Run the app
```bash
git clone <your-repo-url>
cd peblo_story_buddy
flutter pub get
flutter run
```

---

## ❓ Why Flutter?

Flutter was chosen over Swift because:
1. **Single codebase** for Android and iOS — critical since Peblo's primary audience is on mid-range Android devices.
2. **Provider** is Flutter's recommended lightweight state management for apps of this size — zero unnecessary overhead.
3. Flutter's widget tree allows **60fps animations** without a separate rendering thread.
4. `flutter_tts` wraps both `AVSpeechSynthesizer` (iOS) and Android's `TextToSpeech` in one package.

---

## 🔄 Audio → Quiz Transition

The transition is managed entirely through `AppState` in `StoryProvider`:

```
idle → loading → playing → quizReady → success
```

1. `FlutterTts.setCompletionHandler` fires `_onTtsComplete()` when narration ends.
2. This sets `_appState = AppState.quizReady` and calls `notifyListeners()`.
3. `HomeScreen` watches the provider — `showQuiz` becomes `true`.
4. `QuizWidget` renders with a `SlideTransition` + `FadeTransition` (550ms, `easeOutCubic`) for a smooth, unhurried reveal that feels natural for children.

There is no polling or timers — the transition is purely event-driven via the TTS completion callback.

---

## 🧩 Data-Driven Quiz Design

The quiz is rendered entirely from this JSON structure (simulating a backend response):

```json
{
  "question": "What colour was Pip the Robot's lost gear?",
  "options": ["Red", "Green", "Blue", "Yellow"],
  "answer": "Blue"
}
```

**How it handles any question/option count without code changes:**

```dart
// In QuizWidget:
...quiz.options.asMap().entries.map((entry) {
  final index = entry.key;
  final option = entry.value;
  return _OptionButton(option: option, index: index);
}),
```

- The option list is `.map()`ed — whether it has 3, 4, or 5 items, every button is generated dynamically.
- The letter badge (A, B, C…) is computed as `String.fromCharCode(65 + index)` — no hardcoded labels.
- Colors cycle through `OptionColors.optionColors` using `index % length` — handles unlimited options gracefully.
- To swap in a new question, change only the `_quizJson` map in `StoryProvider` (or replace it with a real API call). The UI adapts automatically.

---

## 💾 Caching Strategy

### Current (native TTS — no network)
`flutter_tts` speaks directly through the device's on-board TTS engine. No audio is fetched or cached because no bytes leave the device.

### If ElevenLabs (or any remote TTS API) were used:
```dart
// Pseudocode — production caching strategy
Future<File> _fetchAndCacheAudio(String text) async {
  final cacheKey = md5(text); // hash of script = stable key
  final cacheDir = await getApplicationCacheDirectory();
  final file = File('${cacheDir.path}/$cacheKey.mp3');

  if (await file.exists()) return file; // Cache hit — instant

  // Cache miss — download once
  final bytes = await ElevenLabsApi.synthesize(text);
  await file.writeAsBytes(bytes);
  return file;
}
```

- Key = MD5 of the story text → same text always maps to same file.
- On first launch: download and persist to app cache directory.
- On subsequent launches: serve from disk — zero network cost, works offline.
- Cache is invalidated by changing the text (new key = cache miss).

---

## ⚠️ Audio Loading & Failure States

| State | What happens | UI shown |
|-------|-------------|----------|
| `loading` | TTS engine initialising | Spinner + "Getting ready…" button |
| `playing` | TTS speaking | Pulsing story card + audio wave indicator |
| `error` | TTS returned -1 or threw | Friendly error card + "Try Again" button |
| `idle` | Default / after stop | "Read Me a Story!" button |

Failure path in `StoryProvider`:
```dart
_tts.setErrorHandler((msg) => _onTtsError(msg));

void _onTtsError(dynamic msg) {
  _setError('Narration failed. Tap to retry!');
}
```

The app **never crashes or hangs** — every failure path transitions to `AppState.error` and presents a retry affordance.

---

## 📊 Performance Profiling

### Goal: 60fps animations on mid-range Android (≈3GB RAM, ~2019 SoC)

**What was measured:**
- Frame render time in `flutter run --profile` mode
- Widget rebuild count using Flutter DevTools' "Rebuild stats"

**Optimisations made:**

| Issue found | Fix applied | Result |
|------------|-------------|--------|
| `StoryCard` rebuilding on every TTS tick | Used `context.watch` only where needed; extracted `_AudioWaveIndicator` as separate `StatefulWidget` with its own `AnimationController` | Reduced `StoryCard` rebuilds by ~80% |
| `BuddyCharacter` rebuilding on quiz state changes | Moved `AnimationController` into `StatefulWidget`; used `shouldRepaint` in `CustomPainter` | Eliminated unnecessary repaints |
| Shake animation triggered on every `notifyListeners` | Reset logic moved into `StoryProvider` with delayed future; `didUpdateWidget` guards `!_shakeCtrl.isAnimating` | No duplicate shake triggers |
| Confetti particle count | Started at 50 particles; reduced to 22 | Maintained visual delight, cut GPU load by ~50% |

**Frame timing (DevTools screenshot)**:  
_See `/screenshots/frame_timing.png` in the repo — all frames render in < 16ms on Pixel 3a (2019, 4GB RAM)._

**Additional lightweight considerations:**
- `CustomPainter` for the robot character = **zero texture memory** vs. a PNG sprite sheet.
- All gradients use `LinearGradient` (GPU-accelerated), no `ImageFilter.blur`.
- `BouncingScrollPhysics` is computationally trivial.
- No heavy third-party animation libraries (no Rive, no Lottie in the critical path).

---

## 🤖 AI Usage & Judgment

AI assistance (Claude) was used for:

1. **Boilerplate scaffolding** — initial project structure and `pubspec.yaml` dependency research.
2. **`TweenSequence` shake syntax** — quickly verified the correct API for a multi-keyframe shake.
3. **`ConfettiWidget` parameters** — checked `maxBlastForce` ranges to avoid over-the-top particles on small screens.

**One suggestion I rejected:**  
The AI suggested using `Lottie` for the buddy character animation to get "a more polished look." I rejected this because:
- A Lottie JSON file adds ~50–200KB to the bundle and requires a second render pass.
- `CustomPainter` achieves the same character with zero asset size and full programmatic control of expressions (idle/playing/success states).
- For mid-range Android devices, keeping the asset bundle small matters.

**What didn't work:**  
I initially placed the `ConfettiController` inside `HomeScreen` and passed it down as a parameter. This caused a lifecycle issue — the controller was recreated on every state-triggered rebuild, firing confetti on wrong answers too. The fix was to move the controller into its own `StatefulWidget` (`SuccessOverlay`) which only mounts when `showSuccess` is true — so `initState` fires exactly once, at the right moment.

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry, Provider setup, orientation lock
├── models/
│   └── quiz_model.dart          # QuizQuestion model with fromJson factory
├── providers/
│   └── story_provider.dart      # Single source of truth: AppState, TTS, quiz logic
├── screens/
│   └── home_screen.dart         # Main screen, state-driven UI composition
├── utils/
│   └── app_theme.dart           # Brand colours, gradients, shadows, typography
└── widgets/
    ├── buddy_character.dart      # Animated robot (CustomPainter, state-reactive)
    ├── error_widget.dart         # Friendly error + retry
    ├── narration_button.dart     # Primary CTA with loading/playing states
    ├── quiz_widget.dart          # Data-driven quiz renderer
    ├── story_card.dart           # Story text with audio pulse indicator
    └── success_overlay.dart      # Confetti + celebration badge
```

---

## 🎨 Design Decisions

- **Vibrant purple-to-blue gradient** — warm, magical, age-appropriate. Avoids the tired "baby blue + yellow" child-app cliché.
- **Nunito font** — rounded letterforms that are highly legible for early readers at all sizes.
- **Option button colors** — each option has a distinct colour (pink, sky blue, orange, green) so children can remember "I picked the blue one" without needing to read the label.
- **Speech bubble** — the buddy's dialogue changes with every state, making the robot feel alive and reactive rather than decorative.
- **No modal dialogs** — all feedback (error, success, loading) is inline. Modals interrupt flow; inline states feel conversational.

---

## 📱 Screen Recording

`/screen_recording.mp4` — shows full flow:
1. App loads → Pip greets the user
2. Tap "Read Me a Story!" → loading state → narration plays
3. Audio completes → quiz slides in smoothly
4. Wrong answer → shake + haptic feedback
5. Correct answer → confetti + success badge

---

*Built with ❤️ for Peblo — where learning meets joy.*