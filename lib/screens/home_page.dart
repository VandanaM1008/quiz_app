// lib/screens/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

enum QuizCategory { Technology, GeneralKnowledge, CinemaTV, Sports }

extension QuizCategoryExt on QuizCategory {
  String get title {
    switch (this) {
      case QuizCategory.Technology:
        return 'Technology';
      case QuizCategory.GeneralKnowledge:
        return 'General Knowledge';
      case QuizCategory.CinemaTV:
        return 'Cinema & TV';
      case QuizCategory.Sports:
        return 'Sports';
    }
  }

  List<Color> get gradient {
    switch (this) {
      case QuizCategory.Technology:
        return [Color(0xFF2E7DFF), Color(0xFF7C4DFF)];
      case QuizCategory.GeneralKnowledge:
        return [Color(0xFF00C853), Color(0xFF64DD17)];
      case QuizCategory.CinemaTV:
        return [Color(0xFFFF5252), Color(0xFFFF8A65)];
      case QuizCategory.Sports:
        return [Color(0xFF2979FF), Color(0xFF00B8D4)];
    }
  }

  IconData get icon {
    switch (this) {
      case QuizCategory.Technology:
        return Icons.memory;
      case QuizCategory.GeneralKnowledge:
        return Icons.public;
      case QuizCategory.CinemaTV:
        return Icons.movie;
      case QuizCategory.Sports:
        return Icons.sports_soccer;
    }
  }
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  QuizCategory? _selected;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _startQuiz() {
    final name = _nameCtrl.text.trim();
    final age = _ageCtrl.text.trim();
    if (name.isEmpty || age.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter name and age before starting.'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Select a category first.'),
        backgroundColor: Colors.orangeAccent,
      ));
      return;
    }

    Navigator.pushNamed(context, '/quiz', arguments: {
      'name': name,
      'age': age,
      'category': _selected!.title,
    });
  }

  Widget _categoryChip(QuizCategory c) {
    final selected = _selected == c;
    final colors = c.gradient;
    return GestureDetector(
      onTap: () => setState(() => _selected = c),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: selected ? colors : [Colors.white, Colors.white]),
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: selected ? colors.last.withOpacity(0.22) : Colors.black12,
              blurRadius: selected ? 12 : 6,
              offset: Offset(0, selected ? 8 : 4),
            )
          ],
          border: Border.all(color: selected ? Colors.transparent : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(c.icon, color: selected ? Colors.white : Colors.deepPurple, size: 18),
            SizedBox(width: 8),
            Text(
              c.title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Background image with subtle dark overlay
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/quiz_bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.28), BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 28),
            child: Card(
              color: Colors.white.withOpacity(0.92),
              elevation: 14,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.quiz, color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Quiz App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Pick a category & press Start', style: TextStyle(color: Colors.grey[700])),
                        ]),
                      )
                    ],
                  ),
                  SizedBox(height: 18),

                  // name/age
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Your name',
                      prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.cake, color: Colors.deepPurple),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 18),

                  // small colorful category chips
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: QuizCategory.values.map((c) => _categoryChip(c)).toList(),
                  ),

                  SizedBox(height: 18),
                  // Start button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startQuiz,
                      icon: Icon(Icons.play_arrow),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Start Quiz', style: TextStyle(fontSize: 16)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 8,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
