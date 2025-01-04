import 'package:flutter/material.dart';

class Challenge3Screen extends StatefulWidget {
  @override
  _Challenge3ScreenState createState() => _Challenge3ScreenState();
}

class _Challenge3ScreenState extends State<Challenge3Screen> {
  bool isChallengeWon = false;

  void _onWin() {
    setState(() {
      isChallengeWon = true;
    });
    Navigator.pushNamed(context, '/gift_3');  // Navigate to Gift 3 if won
  }

  void _onLose() {
    Navigator.pushNamed(context, '/final_sequence');  // Navigate to Final Animation if lost
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Challenge 3')),
      body: Center(
        child: ElevatedButton(
          onPressed: isChallengeWon ? _onWin : _onLose,
          child: Text(isChallengeWon ? 'Challenge Won!' : 'Challenge Lost!'),
        ),
      ),
    );
  }
}
