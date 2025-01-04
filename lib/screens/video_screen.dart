import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _controller; 
  final List<String> _videoAssets = [
    'assets/videos/countdown.mp4',
    'assets/videos/star_wars_intro.mp4',
  ];
  int _currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAndPlay(_videoAssets[_currentVideoIndex]);
  }

  void _initializeAndPlay(String asset) {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();

    _controller = VideoPlayerController.asset(asset)
      ..initialize().then((_) {
        if (!mounted) return; 
        setState(() {});
        _controller?.play();
      });

    _controller?.addListener(_videoListener);
  }

  void _videoListener() {
    if (_controller == null) return;
    if (_controller!.value.position >= _controller!.value.duration) {
      _controller!.removeListener(_videoListener);
      _controller!.pause(); 
      _controller!.dispose();
      _controller = null; 

      if (!mounted) return;

      setState(() {
        _currentVideoIndex++;
      });

      if (_currentVideoIndex < _videoAssets.length) {
        _initializeAndPlay(_videoAssets[_currentVideoIndex]);
      } else {
        Navigator.pushReplacementNamed(context, '/yoda');
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller != null && _controller!.value.isInitialized
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
