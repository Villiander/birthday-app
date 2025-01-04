import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HeartfeltMessageScreen extends StatefulWidget {
  @override
  _HeartfeltMessageScreenState createState() => _HeartfeltMessageScreenState();
}

class _HeartfeltMessageScreenState extends State<HeartfeltMessageScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AudioPlayer _audioPlayer;
  final FlutterTts _flutterTts = FlutterTts();

  int _currentIndex = -1;
  bool _showAllMessages = false;
  bool _isVideoReady = false;
  bool _sequenceStarted = false;

  final List<String> _messages = [
    "Remember, Ami",
    "you are very smart and talented",
    "never believe anyone who says otherwise!",
    "An angel that you are, spread your wings\nand soar through the sky",
    "reach the heights no one ever dreamt of...",
    "and outshine even the stars above\nwith your brilliance!",
    "I completely believe in you\nand will always support you :)",
    "my ride to college and home",
    "my greatest support that i can always count on",
    "the best study partner i could ever ask for",
    "my precious, lovely and adorable Pikachu ❤️",
    "a very happy birthday to the prettiest lady once again <3",
  ];

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/message_wallpaper.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() => _isVideoReady = true);
        _startSequenceIfReady();
      });

    _audioPlayer = AudioPlayer();
    _playBackgroundMusic();

    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.8); 
    _flutterTts.setVolume(0.8);
    _flutterTts.setPitch(0.2);
  }

  String _filterForTts(String original) {
    return original
        .replaceAll('\n', ' ')
        .replaceAll('❤️', '')
        .replaceAll(':)', '')
        .replaceAll('<3', '')
        .trim();
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/message_background.ogg');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.setVolume(0.4);
      await _audioPlayer.play();
      _startSequenceIfReady();
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  void _startSequenceIfReady() {
    if (_isVideoReady && !_sequenceStarted) {
      _sequenceStarted = true;
      _showTextSequence();
    }
  }

  Future<void> _showTextSequence() async {
    await Future.delayed(const Duration(seconds: 2));

    for (int i = 0; i < _messages.length; i++) {
      final textForTts = _filterForTts(_messages[i]);

      setState(() => _currentIndex = i);

      if (i < 2) {
 
        await Future.delayed(const Duration(seconds: 2));
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await _flutterTts.speak(textForTts);
      await _flutterTts.awaitSpeakCompletion(true);

      if (i < 2) {
        await Future.delayed(const Duration(seconds: 1));
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      setState(() => _currentIndex = -1);
    }

    setState(() => _showAllMessages = true);
  }

  Future<void> _stopEverythingAndNavigate() async {
    try {

      await _audioPlayer.stop();
      _controller.pause();
    
      await _flutterTts.stop();
    } catch (e) {
      print("Error stopping resources: $e");
    }

    Navigator.pushNamed(context, '/end');
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),

          Container(color: Colors.black.withOpacity(0.4)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_showAllMessages && _currentIndex != -1)
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _messages[_currentIndex],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.white,
                          height: 1.6,
                          shadows: [
                            Shadow(offset: Offset(-2, -2), color: Colors.black),
                            Shadow(offset: Offset(2, -2), color: Colors.black),
                            Shadow(offset: Offset(-2, 2), color: Colors.black),
                            Shadow(offset: Offset(2, 2), color: Colors.black),
                          ],
                        ),
                      ),
                    ),

                  if (_showAllMessages)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              ..._messages.map(
                                (msg) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    msg,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cinzelDecorative(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      color: Colors.white,
                                      height: 1.6,
                                      shadows: [
                                        Shadow(offset: Offset(-2, -2), color: Colors.black),
                                        Shadow(offset: Offset(2, -2), color: Colors.black),
                                        Shadow(offset: Offset(-2, 2), color: Colors.black),
                                        Shadow(offset: Offset(2, 2), color: Colors.black),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),

                        Align(
                          alignment: Alignment.topCenter,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _stopEverythingAndNavigate();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
