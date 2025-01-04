import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart'; 

class CelebrityScreen extends StatefulWidget {
  @override
  _CelebrityScreenState createState() => _CelebrityScreenState();
}

class _CelebrityScreenState extends State<CelebrityScreen> {
  late VideoPlayerController _backgroundController;
  final List<String> _celebrityNames = [
    'Mr. Beast',
    'Donald Trump',
    'Elon Musk',
    'Taylor Swift',
    'Mufasa',
    'Leonardo DiCaprio'
  ];
  final List<String> _imageAssets = [
    'assets/images/mr_beast.png',
    'assets/images/Donald_Trump.png',
    'assets/images/Elon_musk.png',
    'assets/images/Taylor_Swift.png',
    'assets/images/Mufasa.png',
    'assets/images/Leonardo_Decaprio.png'
  ];
  final List<String> _voiceAssets = [
    'assets/voices/mr_beast.ogg',
    'assets/voices/Donald_Trump.ogg',
    'assets/voices/Elon_musk.ogg',
    'assets/voices/Taylor_Swift.ogg',
    'assets/voices/Mufasa.ogg',
    'assets/voices/Leonardo_Decaprio.ogg'
  ];
  final List<String> _videoAssets = [
    'assets/videos/shrek_video.mp4', 
    'assets/videos/donkey_video.mp4'  
  ];

  final AudioPlayer _audioPlayer = AudioPlayer(); 
  int _currentIndex = 0;
  bool _showIntroText = true;
  bool _isPlayingWishes = false;

  @override
  void initState() {
    super.initState();
    _backgroundController = VideoPlayerController.asset('assets/videos/celebrity_screen_background.mp4')
      ..initialize().then((_) {
        setState(() {});
        _backgroundController.setLooping(true);
        _backgroundController.play();
      });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _currentIndex++; 
        });
        _playNextCelebrity(); 
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _startCelebrityWishes() {
    if (!_isPlayingWishes) {
      setState(() {
        _showIntroText = false;
        _isPlayingWishes = true;
      });
      _playNextCelebrity();
    }
  }

  void _playNextCelebrity() async {
    if (_currentIndex < _celebrityNames.length) {
      try {
        await _audioPlayer.setAsset(_voiceAssets[_currentIndex]);
        await _audioPlayer.play();
        setState(() {});
      } catch (e) {
        print('Error playing audio for ${_celebrityNames[_currentIndex]}: $e');
        setState(() {
          _currentIndex++;
        });
        _playNextCelebrity();
      }
    } else {
      _playVideos();
    }
  }

  void _playVideos() async {
    _backgroundController.pause();

    for (int i = 0; i < _videoAssets.length; i++) {
      bool isFirstVideo = i == 0;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenVideoScreen(
            videoAsset: _videoAssets[i],
            isFirstVideo: isFirstVideo,
          ),
        ),
      );
    }

    Navigator.pushReplacementNamed(context, '/final_sequence');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_backgroundController.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _backgroundController.value.size?.width ?? 0,
                  height: _backgroundController.value.size?.height ?? 0,
                  child: VideoPlayer(_backgroundController),
                ),
              ),
            ),
          Center(
            child: _showIntroText
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'By the way, some celebs sent their birthday wishes to you!!',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _startCelebrityWishes,
                        child: Text('Start playing wishes'),
                      ),
                    ],
                  )
                : _currentIndex < _celebrityNames.length
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _imageAssets[_currentIndex],
                            height: 200,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Wishes from: ${_celebrityNames[_currentIndex]}',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      )
                    : CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

class FullScreenVideoScreen extends StatefulWidget {
  final String videoAsset;
  final bool isFirstVideo; 

  FullScreenVideoScreen({required this.videoAsset, required this.isFirstVideo});

  @override
  _FullScreenVideoScreenState createState() => _FullScreenVideoScreenState();
}

class _FullScreenVideoScreenState extends State<FullScreenVideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      }).catchError((error) {
        print("Video initialization error: $error");
        Navigator.pop(context); 
      });
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        _controller.pause();
        Navigator.pop(context); 
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, 
      child: Scaffold(
        backgroundColor: widget.isFirstVideo ? Colors.black : Colors.black, 
        body: GestureDetector(
          onTap: () {}, 
          child: Center(
            child: _controller.value.isInitialized
                ? widget.isFirstVideo
                    ? 
                    SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.fill, 
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      )
                    : 
                    Container(
                        color: Colors.black,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.none, 
                            child: SizedBox(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                        ),
                      )
                : CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
