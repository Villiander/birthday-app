import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class FinalAnimationScreen extends StatefulWidget {
  @override
  _FinalAnimationScreenState createState() => _FinalAnimationScreenState();
}

class _FinalAnimationScreenState extends State<FinalAnimationScreen>
    with TickerProviderStateMixin {
  late AudioPlayer _fireworksPlayer;
  late AudioPlayer _musicPlayer;
  bool _showFireworks = false;
  bool _showTiara = false;
  bool useCrown1 = true;
  late VideoPlayerController _videoController;
  late AnimationController _heartAnimationController;

  @override
  void initState() {
    super.initState();
    _fireworksPlayer = AudioPlayer();
    _musicPlayer = AudioPlayer();
    _musicPlayer.setVolume(1.0);
    _fireworksPlayer.setVolume(0.4);
    _videoController =
        VideoPlayerController.asset('assets/videos/starry_night_background.mp4')
          ..initialize().then((_) {
            setState(() {});
            _videoController.setLooping(true);
            _videoController.play();
          }).catchError((error) {
            print("Video initialization error: $error");
          });
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _startSequence();
  }

  @override
  void dispose() {
    _fireworksPlayer.dispose();
    _musicPlayer.dispose();
    _videoController.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  Future<void> _startSequence() async {
    await Future.delayed(Duration(seconds: 1));
    _fireworksPlayer.play(AssetSource('sounds/fireworks.ogg'));
    _musicPlayer.play(AssetSource('sounds/Happy_bday_music.ogg'));
    setState(() {
      _showFireworks = true;
    });
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      _showTiara = true;
    });
    _musicPlayer.onPlayerComplete.listen((event) {
      Navigator.pushReplacementNamed(context, '/heartfelt_message');
    });
    await Future.delayed(Duration(seconds: 10));
    _playHeartAnimation();
    await Future.delayed(Duration(seconds: 10));
    _playHeartAnimation();
    await Future.delayed(Duration(seconds: 10));
    _playHeartAnimation();
  }

  void _playHeartAnimation() {
    _heartAnimationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (_videoController.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
          if (_showFireworks)
            Positioned.fill(
              child: Stack(
                children: [
                  Lottie.asset(
                    'animations/fireworks1.json',
                    fit: BoxFit.cover,
                    repeat: true,
                  ),
                  Positioned(
                    left: 100,
                    right: 100,
                    child: Lottie.asset(
                      'animations/fireworks2.json',
                      fit: BoxFit.cover,
                      repeat: true,
                    ),
                  ),
                  Positioned(
                    right: -100,
                    child: Lottie.asset(
                      'animations/fireworks3.json',
                      fit: BoxFit.cover,
                      repeat: true,
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 50,
                    child: Lottie.asset(
                      'animations/fireworks4.json',
                      fit: BoxFit.cover,
                      repeat: true,
                    ),
                  ),
                ],
              ),
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Transform.scale(
                          scale: 5.0,
                          child: Lottie.asset(
                            'animations/heart_animation.json',
                            controller: _heartAnimationController,
                            width: 300,
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Image.asset(
                      'images/her_image.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      top: -55,
                      left: 70,
                      right: 0,
                      child: _showTiara
                          ? Lottie.asset(
                              useCrown1
                                  ? 'animations/crown1.json'
                                  : 'animations/crown2.json',
                              width: 900,
                              height: 140,
                              fit: BoxFit.contain,
                            )
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "Happy 25th Birthday, Ami ❤️",
                  style: GoogleFonts.dancingScript(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
