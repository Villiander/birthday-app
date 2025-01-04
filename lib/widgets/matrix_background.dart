import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MatrixBackground extends StatefulWidget {
  @override
  _MatrixBackgroundState createState() => _MatrixBackgroundState();
}

class _MatrixBackgroundState extends State<MatrixBackground> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/matrix_wallpaper.mp4')
      ..initialize().then((_) {
        setState(() {
          _videoController.setLooping(true);
          _videoController.play();
        });
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
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
    );
  }
}
