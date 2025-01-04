import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Gift2Screen extends StatefulWidget {
  const Gift2Screen({Key? key}) : super(key: key);

  @override
  State<Gift2Screen> createState() => _Gift2ScreenState();
}

class _Gift2ScreenState extends State<Gift2Screen> {
  int _currentGiftIndex = 0;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  Future<void> _playGiftAudio(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final bool reachedGift = args['reachedGift'] ?? false;
    final bool secretGift1Triggered = args['secretGift1Triggered'] ?? false;
    final bool secretGift2Triggered = args['secretGift2Triggered'] ?? false;
    final double finalScore = args['score'] ?? 0.0;

    final List<Map<String, dynamic>> gifts = [
      {
        'unlocked': reachedGift,
        'message': 'Will be revealed soon (when the time is right) 😅',
        'audio': 'assets/sounds/gift_applause.mp3',
      },
      {
        'unlocked': secretGift1Triggered,
        'message': 'You\'re rewarded with 3 No Questions Asked Favors',
        'audio': 'assets/sounds/secret_gift1.mp3',
      },
      {
        'unlocked': secretGift2Triggered,
        'message': 'You\'re rewarded with 3 Ask Me anything Questions',
        'audio': 'assets/sounds/secret_gift2.mp3',
      },
    ];

    final String additionalText = _currentGiftIndex == 1
        ? "Secret Gift 1"
        : _currentGiftIndex == 2
            ? "Secret Gift 2"
            : "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Game Over! You scored ${finalScore.round()} points.',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            if (additionalText.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                additionalText,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 40),
            Text(
              gifts[_currentGiftIndex]['unlocked']
                  ? gifts[_currentGiftIndex]['message']
                  : 'This gift is locked. Keep trying to unlock it!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: gifts[_currentGiftIndex]['unlocked']
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await _stopAudio();

                if (_currentGiftIndex < gifts.length - 1) {
                  setState(() {
                    _currentGiftIndex++;
                  });

                  if (gifts[_currentGiftIndex]['unlocked']) {
                    _playGiftAudio(gifts[_currentGiftIndex]['audio']);
                  }
                } else {
                  Navigator.pushNamed(context, '/celebrity');
                }
              },
              child: Text(
                _currentGiftIndex < gifts.length - 1
                    ? 'Next Gift'
                    : 'Next Sequence',
              ),
            ),
          ],
        ),
      ),
    );
  }
}