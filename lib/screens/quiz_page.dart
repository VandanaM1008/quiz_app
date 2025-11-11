// lib/screens/quiz_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<Question> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  bool _answered = false;
  int? _selectedIndex;
  int _streak = 0;

  static const int maxTime = 12;
  int _timeLeft = maxTime;
  Timer? _timer;

  String _playerName = '';
  String _playerAge = '';
  String _category = 'Technology';

  // theme colors by category
  final Map<String, List<Color>> theme = {
    'Technology': [Color(0xFF2E7DFF), Color(0xFF7C4DFF)],
    'General Knowledge': [Color(0xFF00C853), Color(0xFF64DD17)],
    'Cinema & TV': [Color(0xFFFF5252), Color(0xFFFF8A65)],
    'Sports': [Color(0xFF2979FF), Color(0xFF00B8D4)],
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    _playerName = args['name'] as String? ?? '';
    _playerAge = args['age'] as String? ?? '';
    _category = args['category'] as String? ?? 'Technology';
    _questions = _questionsForCategory(_category);
    _startTimer();
  }

  List<Question> _questionsForCategory(String cat) {
    switch (cat) {
      case 'General Knowledge':
        return [
          Question(questionText: 'What is the capital of France?', options: ['Madrid', 'Berlin', 'Paris', 'Rome'], correctAnswerIndex: 2),
          Question(questionText: 'Which planet is known as the Red Planet?', options: ['Earth', 'Mars', 'Jupiter', 'Venus'], correctAnswerIndex: 1),
          Question(questionText: 'H2O is the chemical formula for what?', options: ['Salt', 'Water', 'Hydrogen peroxide', 'Oxygen'], correctAnswerIndex: 1),
        ];
      case 'Cinema & TV':
        return [
          Question(questionText: 'Which director made "Inception"?', options: ['Christopher Nolan', 'Steven Spielberg', 'James Cameron', 'Quentin Tarantino'], correctAnswerIndex: 0),
          Question(questionText: 'Which series features the Stark family?', options: ['The Witcher', 'Breaking Bad', 'Game of Thrones', 'Stranger Things'], correctAnswerIndex: 2),
          Question(questionText: 'Who played Iron Man in the MCU?', options: ['Chris Hemsworth', 'Chris Evans', 'Robert Downey Jr.', 'Mark Ruffalo'], correctAnswerIndex: 2),
        ];
      case 'Sports':
        return [
          Question(questionText: 'How many players in a soccer team on the field?', options: ['9', '10', '11', '12'], correctAnswerIndex: 2),
          Question(questionText: 'Which country hosted the 2016 Summer Olympics?', options: ['China', 'Brazil', 'UK', 'Russia'], correctAnswerIndex: 1),
          Question(questionText: 'In tennis, what is a score of zero called?', options: ['Love', 'Zero', 'Nil', 'Blank'], correctAnswerIndex: 0),
        ];
      case 'Technology':
      default:
        return [
          Question(questionText: 'Which technology is primarily used for building decentralized applications?', options: ['Machine Learning', 'Blockchain', 'Virtual Reality', 'Augmented Reality'], correctAnswerIndex: 1),
          Question(questionText: 'What does "GPT" in ChatGPT stand for?', options: ['Generative Pretrained Transformer', 'Global Processing Tool', 'Graphical Processing Transformer', 'Generalized Predictive Text'], correctAnswerIndex: 0),
          Question(questionText: 'Which company created TensorFlow?', options: ['Facebook', 'Amazon', 'Google', 'Microsoft'], correctAnswerIndex: 2),
        ];
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeLeft = maxTime);
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timeLeft == 0) {
        t.cancel();
        if (!_answered) _handleAnswer(-1); // timed out
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  double _streakMultiplier() {
    if (_streak >= 7) return 2.0;
    if (_streak >= 4) return 1.5;
    if (_streak >= 2) return 1.2;
    return 1.0;
  }

  void _handleAnswer(int index) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedIndex = index;
    });

    final q = _questions[_currentIndex];
    final bool correct = index == q.correctAnswerIndex;

    const int base = 10;
    final int timeBonus = (_timeLeft * 2);
    final double mult = _streakMultiplier();
    int gained = 0;

    if (correct) {
      _streak++;
      _correctCount++;
      gained = ((base + timeBonus) * mult).round();
      _score += gained;
    } else {
      _streak = 0;
    }

    _timer?.cancel();

    Future.delayed(Duration(milliseconds: 700), () {
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _answered = false;
          _selectedIndex = null;
        });
        _startTimer();
      } else {
        Navigator.pushReplacementNamed(context, '/result', arguments: {
          'score': _score,
          'correct': _correctCount,
          'total': _questions.length,
          'name': _playerName,
          'age': _playerAge,
          'category': _category,
        });
      }
    });
  }

  void _skip() {
    if (_answered) return;
    _handleAnswer(-1);
  }

  Widget _buildOption(int i, String text) {
    final q = _questions[_currentIndex];
    Color bg = Colors.white;
    Color textColor = Colors.black87;
    if (_answered) {
      if (i == q.correctAnswerIndex) {
        bg = Colors.greenAccent.shade200;
        textColor = Colors.black;
      } else if (_selectedIndex == i && i != q.correctAnswerIndex) {
        bg = Colors.redAccent.shade100;
        textColor = Colors.black;
      }
    }
    return AnimatedContainer(
      duration: Duration(milliseconds: 360),
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: ListTile(
        title: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
        onTap: !_answered ? () => _handleAnswer(i) : null,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = theme[_category] ?? [Color(0xFF2E7DFF), Color(0xFF7C4DFF)];
    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final timerProgress = _timeLeft / maxTime;

    return Scaffold(
      // gradient header + content
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: Column(
            children: [
              // Header with category, name, score
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_category, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Player: ${_playerName.isNotEmpty ? _playerName : 'Player'}', style: TextStyle(color: Colors.white70)),
                      ]),
                    ),
                    Column(
                      children: [
                        Text('Score', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 4),
                        Text('$_score', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(width: 12),
                    // circular timer
                    Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(value: timerProgress, color: Colors.yellowAccent, backgroundColor: Colors.white30, strokeWidth: 4),
                      ),
                      Text('$_timeLeft', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ])
                  ],
                ),
              ),

              // progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: LinearProgressIndicator(value: progress, color: Colors.yellowAccent, backgroundColor: Colors.white30),
              ),

              SizedBox(height: 14),

              // question card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 14,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_playerAge.isNotEmpty)
                            Align(alignment: Alignment.topRight, child: Text('Age: $_playerAge', style: TextStyle(color: Colors.grey[700]))),
                          SizedBox(height: 6),
                          Text('Q${_currentIndex + 1}.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 8),
                          Text(q.questionText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          SizedBox(height: 12),
                          ...List.generate(q.options.length, (i) => _buildOption(i, q.options[i])),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // bottom controls: streak + skip + finish
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
                child: Row(
                  children: [
                    Chip(avatar: Icon(Icons.whatshot, color: Colors.white), label: Text('Streak: $_streak', style: TextStyle(color: Colors.white))),
                    SizedBox(width: 8),
                    Chip(avatar: Icon(Icons.star, color: Colors.white), label: Text('x${_streakMultiplier().toStringAsFixed(1)}', style: TextStyle(color: Colors.white))),
                    Spacer(),
                    TextButton(onPressed: _answered ? null : _skip, child: Text('Skip', style: TextStyle(color: Colors.white))),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.pushReplacementNamed(context, '/result', arguments: {
                          'score': _score,
                          'correct': _correctCount,
                          'total': _questions.length,
                          'name': _playerName,
                          'age': _playerAge,
                          'category': _category,
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: Text('Finish', style: TextStyle(color: colors.first)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 
}
