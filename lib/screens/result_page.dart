// lib/screens/result_page.dart
import 'package:flutter/material.dart';
import 'dart:math';

class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final int score = args['score'] as int? ?? 0;
    final int correct = args['correct'] as int? ?? 0;
    final int total = args['total'] as int? ?? 0;
    final String name = args['name'] as String? ?? 'Player';
    final String category = args['category'] as String? ?? 'Quiz';

    final Map<String, List<Color>> theme = {
      'Technology': [Color(0xFF2E7DFF), Color(0xFF7C4DFF)],
      'General Knowledge': [Color(0xFF00C853), Color(0xFF64DD17)],
      'Cinema & TV': [Color(0xFFFF5252), Color(0xFFFF8A65)],
      'Sports': [Color(0xFF2979FF), Color(0xFF00B8D4)],
    };

    final colors = theme[category] ?? [Colors.deepPurple, Colors.blueAccent];

    double percent = total > 0 ? (correct / total) * 100 : 0;
    percent = double.parse(percent.toStringAsFixed(1));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(18),
              child: Card(
                color: Colors.white.withOpacity(0.95),
                elevation: 14,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // Header (interesting)
                    Row(
                      children: [
                        CircleAvatar(backgroundColor: colors.first, radius: 26, child: Icon(Icons.emoji_events, color: Colors.white)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Great job, $name!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.first)),
                            SizedBox(height: 4),
                            Text('Category: $category', style: TextStyle(color: Colors.grey[800])),
                          ]),
                        ),
                        Column(children: [
                          Text('$percent%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.last)),
                          SizedBox(height: 2),
                          Text('$correct / $total', style: TextStyle(color: Colors.grey[700])),
                        ])
                      ],
                    ),

                    SizedBox(height: 18),
                    // Score circle
                    Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: min((correct / (total > 0 ? total : 1)), 1.0),
                          strokeWidth: 10,
                          color: colors.last,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('$score', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.first)),
                        SizedBox(height: 6),
                        Text('points', style: TextStyle(color: Colors.grey[700])),
                      ])
                    ]),

                    SizedBox(height: 22),
                    Text(
                      correct == total
                          ? 'Perfect! You answered all questions correctly 🎉'
                          : (percent >= 75 ? 'Excellent performance!' : percent >= 50 ? 'Good effort!' : 'Keep practicing!'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),

                    SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                        style: ElevatedButton.styleFrom(backgroundColor: colors.first),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Restart same category quickly
                          Navigator.pushNamedAndRemoveUntil(context, '/quiz', (route) => false, arguments: {
                            'name': name,
                            'age': args['age'] ?? '',
                            'category': category,
                          });
                        },
                        icon: Icon(Icons.replay),
                        label: Text('Retry'),
                        style: ElevatedButton.styleFrom(backgroundColor: colors.last),
                      ),
                    ]),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
