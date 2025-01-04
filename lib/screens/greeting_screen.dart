import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:my_birthday_app/widgets/matrix_background.dart';
import 'package:google_fonts/google_fonts.dart';

class GreetingScreen extends StatefulWidget {
  @override
  _GreetingScreenState createState() => _GreetingScreenState();
}

class _GreetingScreenState extends State<GreetingScreen> {
  late AudioPlayer _audioPlayer;
  int _textIndex = -1;
  bool _isVideoInitialized = false;
  final List<String> _texts = [
    'Ami',
    'I hope you like the present',
    'Hope it puts a big smile on your face',
    'and make you feel special :D',
    'Umm.....',
    'A quick question before we start',
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.play(AssetSource('sounds/matrix_background.ogg'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTextSequence() async {
    for (int i = 0; i < _texts.length; i++) {
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _textIndex = i;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentText = _textIndex >= 0 ? _texts[_textIndex] : '';

    return Scaffold(
      body: Stack(
        children: [
          MatrixBackground(),
          if (!_isVideoInitialized)
            FutureBuilder<void>(
              future: _checkVideoReady(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  _isVideoInitialized = true;
                  _startTextSequence();
                  return SizedBox.shrink();
                } else {
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    ),
                  );
                }
              },
            ),
          if (_isVideoInitialized) 
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_textIndex >= 0)
                    Text(
                      currentText,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.green,
                        shadows: [
                          Shadow(offset: Offset(-2, -2), color: Colors.black),
                          Shadow(offset: Offset(2, -2), color: Colors.black),
                          Shadow(offset: Offset(-2, 2), color: Colors.black),
                          Shadow(offset: Offset(2, 2), color: Colors.black),
                        ],
                      ),
                    ),
                  SizedBox(height: 30),
                  if (_textIndex == _texts.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        _audioPlayer.stop();
                        Navigator.pushNamed(context, '/quiz');
                      },
                      child: Text(
                        'View the question',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _checkVideoReady() async {
    await Future.delayed(Duration(milliseconds: 500));
  }
}
