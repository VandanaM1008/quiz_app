// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/quiz_page.dart';
import 'screens/result_page.dart';

void main() => runApp(QuizApp());

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibrant Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: false,
      ),
      // Use named routes so we can pass arguments easily
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/quiz': (context) => QuizPage(),
        '/result': (context) => ResultPage(),
      },
    );
  }
}
