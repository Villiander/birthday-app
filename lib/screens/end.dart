import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:gif/gif.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';

class EndScreen extends StatefulWidget {
  @override
  _EndScreenState createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late GifController _gifController;
  late AudioPlayer _audioPlayer;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/end_screen.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {
          _isVideoReady = true;
        });
      });

    _gifController = GifController(vsync: this)
      ..addListener(() {
        if (_gifController.isCompleted) {
          _gifController.reset();
          _gifController.forward();
        }
      });
    _audioPlayer = AudioPlayer();
    _playBackgroundAudio();
  }

  Future<void> _playBackgroundAudio() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/end.mp3');
      _audioPlayer.setVolume(0.7);
      //_audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _gifController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _exitApp() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isVideoReady)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "That's all bro",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(offset: Offset(2, 2), color: Colors.black),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Eagerly waiting for your feedback :)",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      shadows: [
                        Shadow(offset: Offset(2, 2), color: Colors.black),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Gif(
                    image: AssetImage('assets/gifs/cat.gif'),
                    controller: _gifController,
                    height: 200,
                    width: 200,
                    placeholder: (context) => Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white),
                    ),
                    onFetchCompleted: () {
                      _gifController.reset();
                      _gifController.forward();
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _exitApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text(
                      'Exit App',
                      style: TextStyle(color: Colors.black),
                    ),
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