import 'package:flutter/material.dart';
import 'package:test_youtube/cinema_gemini.dart';

void main() => runApp(const StandaloneApp());

/// Standalone runner for local testing only.
///
/// The Sarbon app consumes this package by importing `YoutubePlayerScreen`
/// (from `cinema_gemini.dart`) directly and passing its own `initialSource`
/// and `sources`.
class StandaloneApp extends StatelessWidget {
  const StandaloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sarbon Video',
      home: const YoutubePlayerScreen(
        initialSource: '-l8-B2MtF84',
        sources: ['-l8-B2MtF84', 'AnVO_pFyz7o', 'EZ7dZklX81U'],
      ),
    );
  }
}
