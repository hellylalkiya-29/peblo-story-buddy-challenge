import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'screens/story_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Story Buddy',
        theme: AppTheme.lightTheme,
        home: const StoryScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}