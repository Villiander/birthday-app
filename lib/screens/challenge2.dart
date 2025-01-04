import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:my_birthday_app/screens/doodle_jump_game.dart';
import 'package:just_audio/just_audio.dart';

class Challenge2Screen extends StatefulWidget {
  const Challenge2Screen({Key? key}) : super(key: key);

  @override
  State<Challenge2Screen> createState() => _Challenge2ScreenState();
}

class _Challenge2ScreenState extends State<Challenge2Screen> {
  late DoodleJumpGame _game;
  late AudioPlayer _backgroundPlayer;
  late AudioPlayer _effectPlayer;
  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayers();
    _game = DoodleJumpGame(onGameOver: _handleGameOver);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  Future<void> _initializeAudioPlayers() async {
    _backgroundPlayer = AudioPlayer();
    _effectPlayer = AudioPlayer();

    await _backgroundPlayer.setAsset('assets/sounds/challenge2_background.mp3');
    await _effectPlayer.setAsset('assets/sounds/death.mp3');

    await _backgroundPlayer.setVolume(0.5);
    await _effectPlayer.setVolume(0.5);
    await _backgroundPlayer.setLoopMode(LoopMode.one);
    _backgroundPlayer.play();
  }

  @override
  void dispose() {
    _backgroundPlayer.dispose();
    _effectPlayer.dispose();
    super.dispose();
  }

  void _showWelcomeDialog() {
    if (_isDialogShown) return;
    _isDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Welcome to Challenge 2"),
        content: const Text(
          "This challenge has 1 gift and 2 secret gifts that you can unlock\nUse left and right arrow keys for movement\nAll the best!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    _game.startGame();
  }

  void _handleGameOver() {
    _playDeathSound();

    int gifts = _game.giftTriggered ? 1 : 0;
    int secrets = 0;
    if (_game.secretGift1Triggered) secrets += 1;
    if (_game.secretGift2Triggered) secrets += 1;
    int totalSecrets = 2;
    bool allGiftsUnlocked = (gifts == 1 && secrets == totalSecrets);
    String message;
    List<Widget> actions = [];

    if (allGiftsUnlocked) {
      message = "Game Over\nWow Ami!, you rock!";
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _navigateToGift2();
          },
          child: const Text("Proceed"),
        ),
      );
    } else if (gifts > 0 || secrets > 0) {
      int remainingGifts = 1 - gifts;
      int remainingSecrets = totalSecrets - secrets;
      message =
          "You've won $gifts gift(s) and $secrets secret gift(s).\nThere are $remainingGifts more gift(s) and $remainingSecrets more secret gift(s) in this level!";
      actions.addAll([
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _restartGame();
          },
          child: const Text("Try Again"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _navigateToGift2();
          },
          child: const Text("Give Up"),
        ),
      ]);
    } else {
      message =
          "Game Over\nDon't worry, try again and unlock 1 gift and 2 secret gifts.";
      actions.addAll([
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _restartGame();
          },
          child: const Text("Try Again"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _navigateToGift2();
          },
          child: const Text("Proceed"),
        ),
      ]);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: Text(message),
        actions: actions,
      ),
    );
  }

  Future<void> _restartGame() async {
    await _game.reset();
    _startGame();
  }

  Future<void> _playDeathSound() async {
    try {
      await _backgroundPlayer.setVolume(0.1);
      _effectPlayer.stop();
      await _effectPlayer.seek(Duration.zero);
      await _effectPlayer.play();
      _effectPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _backgroundPlayer.setVolume(0.2);
        }
      });
    } catch (e) {
      print("Error playing death sound: $e");
    }
  }

  void _navigateToGift2() {
    Navigator.pushReplacementNamed(
      context,
      '/gift_2',
      arguments: {
        'reachedGift': _game.giftTriggered,
        'secretGift1Triggered': _game.secretGift1Triggered,
        'secretGift2Triggered': _game.secretGift2Triggered,
        'score': _game.score,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: _game),
    );
  }
}