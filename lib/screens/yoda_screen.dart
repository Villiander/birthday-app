import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class YodaScreen extends StatefulWidget {
  @override
  _YodaScreenState createState() => _YodaScreenState();
}

class _YodaScreenState extends State<YodaScreen> {
  late AudioPlayer _audioPlayer; 
  late VideoPlayerController _videoController;
  int _loopCount = 0; 
  final int _maxLoops = 3; 

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playAudioLoops(); 

    _videoController = VideoPlayerController.asset('assets/videos/yodascreen_background.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _playAudioLoops() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/yoda_audio.ogg');
      await _audioPlayer.setLoopMode(LoopMode.off);
      await _audioPlayer.setSpeed(0.6);

      
      await _audioPlayer.processingStateStream.firstWhere(
        (state) => state == ProcessingState.ready,
      );

      for (_loopCount = 0; _loopCount < _maxLoops; _loopCount++) {
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();

        
        await _audioPlayer.playerStateStream.firstWhere(
          (event) => event.processingState == ProcessingState.completed,
        );

        await _audioPlayer.stop();

        if (_loopCount < _maxLoops - 1) {
          await Future.delayed(Duration(seconds: 1)); 
        }
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/challenge1');
      }

    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: _videoController.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : Container(color: Colors.black),
          ),
          Center(
            child: Image.asset(
              'assets/images/yoda_image.png',
              width: 300,
              height: 300,
            ),
          ),
        ],
      ),
    );
  }
}
