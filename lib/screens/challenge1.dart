import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

class Challenge1Screen extends StatefulWidget {
  @override
  _Challenge1ScreenState createState() => _Challenge1ScreenState();
}

class _Challenge1ScreenState extends State<Challenge1Screen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _backgroundController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPaused = false; 

  final List<List<int>> puzzle = [
    [5, 0, 9, 0, 2, 8, 6, 0, 3],
    [0, 3, 0, 9, 4, 0, 0, 5, 7],
    [0, 7, 2, 0, 3, 5, 9, 0, 0],
    [1, 5, 0, 6, 9, 0, 0, 3, 2],
    [3, 0, 6, 8, 0, 2, 7, 4, 0],
    [0, 8, 0, 3, 0, 7, 0, 9, 6],
    [4, 0, 5, 0, 6, 9, 0, 0, 8],
    [0, 6, 0, 5, 0, 1, 4, 0, 9],
    [9, 0, 8, 0, 7, 0, 5, 0, 1],
  ];

  final List<List<int>> solution = [
    [5, 4, 9, 7, 2, 8, 6, 1, 3],
    [8, 3, 1, 9, 4, 6, 2, 5, 7],
    [6, 7, 2, 1, 3, 5, 9, 8, 4],
    [1, 5, 7, 6, 9, 4, 8, 3, 2],
    [3, 9, 6, 8, 1, 2, 7, 4, 5],
    [2, 8, 4, 3, 5, 7, 1, 9, 6],
    [4, 1, 5, 2, 6, 9, 3, 7, 8],
    [7, 6, 3, 5, 8, 1, 4, 2, 9],
    [9, 2, 8, 4, 7, 3, 5, 6, 1],
  ];

  late List<List<int>> userGrid;
  Set<String> wrongCells = Set();
  late AnimationController _timerController;
  bool giveUpPressed = false;
  late List<List<TextEditingController>> controllers;

  Future<void> _playSoundtrack() async {
  try {
    await _audioPlayer.setAsset('assets/sounds/challenge1_soundtrack.mp3'); 
    await _audioPlayer.setVolume(0.6); 
    await _audioPlayer.play();
  } catch (e) {
    print("Error playing soundtrack: $e");
  }
}

  Future<void> _pauseSoundtrack() async {
    await _audioPlayer.pause();
  }

  Future<void> _resumeSoundtrack() async {
    await _audioPlayer.play();
  }

  Future<void> _restartSoundtrack() async {
    await _audioPlayer.stop();
    await _playSoundtrack();
  }

  @override
  void initState() {
    super.initState();
    userGrid = List.generate(9, (i) => List<int>.from(puzzle[i]));
    controllers = List.generate(
      9,
      (row) => List.generate(
        9,
        (col) => TextEditingController(
          text: userGrid[row][col] == 0 ? '' : userGrid[row][col].toString(),
        ),
      ),
    );
    _initializeBackgroundVideo();
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(minutes: 9),
    )
      ..addListener(() {
        setState(() {});
      })
      ..forward();
      _playSoundtrack();
  }

  void _initializeBackgroundVideo() {
    _backgroundController = VideoPlayerController.asset(
      'assets/videos/challenge1_background.mp4',
    )
      ..initialize().then((_) {
        setState(() {
          _backgroundController.setLooping(true);
          _backgroundController.play();
        });
      });
  }

  void _checkSolution() {
    Set<String> errors = {};
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (userGrid[i][j] != solution[i][j]) {
          errors.add('$i-$j');
        }
      }
    }

    setState(() {
      wrongCells = errors;
    });

    if (errors.isEmpty) {
      _onWin();
    }
  }
    void _pauseGame() {
    setState(() {
      _timerController.stop(); 
      _pauseSoundtrack(); 
      isPaused = true;
    });
  }

  void _resumeGame() {
    setState(() {
      _timerController.forward(); 
      _resumeSoundtrack();
      isPaused = false;
    });
  }

  void _onWin() {
    bool solvedUnderTime = _timerController.value < 1.0;
    _audioPlayer.stop();
    _showResultPopup(
      solvedUnderTime
          ? "You are a rockstar Ami! 🔥"
          : "Well Done Ami!\nYou have won 1 gift, but there is 1 secret gift that you can unlock.",
      solvedUnderTime,
    );
  }

  void _showResultPopup(String message, bool unlockSecretGift) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(unlockSecretGift ? "Congratulations!" : "Good Try!"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/gift_1',
                arguments: {'unlockSecretGift': unlockSecretGift},
              );
            },
            child: Text("Claim Reward"),
          ),
          if (!unlockSecretGift)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: Text("Try Again"),
            ),
        ],
      ),
    );
  }

  void _showGiveUpPopup() {
    _pauseGame();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text(
            "There is still 1 gift and 1 secret gift that you can unlock in this level!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/gift_1',
                arguments: {'unlockSecretGift': false},
              );
            },
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeGame();
            },
            child: Text("No"),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      userGrid = List.generate(9, (i) => List<int>.from(puzzle[i]));
      wrongCells.clear();
      for (int row = 0; row < 9; row++) {
        for (int col = 0; col < 9; col++) {
          controllers[row][col].text =
              userGrid[row][col] == 0 ? '' : userGrid[row][col].toString();
        }
      }
    });
    _timerController.reset();
    _timerController.forward();
    _restartSoundtrack();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _timerController.dispose();
    _audioPlayer.dispose();
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Widget _buildSudokuCell(int row, int col) {
    bool isEditable = puzzle[row][col] == 0;
    String cellKey = '$row-$col';
    bool isWrong = wrongCells.contains(cellKey);

    bool isTopBorder = row % 3 == 0;
    bool isLeftBorder = col % 3 == 0;
    bool isBottomBorder = row == 8;
    bool isRightBorder = col == 8;

    double topWidth = isTopBorder ? 2 : 1;
    double bottomWidth = isBottomBorder ? 2 : 1;
    double leftWidth = isLeftBorder ? 2 : 1;
    double rightWidth = isRightBorder ? 2 : 1;

    Color borderColorTop = isTopBorder ? Colors.red : Colors.white;
    Color borderColorBottom = isBottomBorder ? Colors.red : Colors.white;
    Color borderColorLeft = isLeftBorder ? Colors.red : Colors.white;
    Color borderColorRight = isRightBorder ? Colors.red : Colors.white;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColorTop, width: topWidth),
          bottom: BorderSide(color: borderColorBottom, width: bottomWidth),
          left: BorderSide(color: borderColorLeft, width: leftWidth),
          right: BorderSide(color: borderColorRight, width: rightWidth),
        ),
        color: isWrong
            ? Colors.red.withOpacity(0.6)
            : (isEditable ? Colors.black : Colors.grey[800]),
      ),
      child: TextField(
        enabled: isEditable,
        keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ]
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            if (value.isNotEmpty && int.tryParse(value) == null) return;
            wrongCells.remove(cellKey);
            userGrid[row][col] = int.tryParse(value) ?? 0;
          });
        },
        controller: controllers[row][col],
      ),
    );
  }

  Widget _buildTimer() {
    final double remainingTime = 1.0 - _timerController.value;
    Color timerColor;
    if (remainingTime > 0.5) {
      timerColor = Colors.green;
    } else if (remainingTime > 0.2) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.red;
    }
    return Positioned(
      top: 20,
      right: 20,
      child: CircularProgressIndicator(
        value: remainingTime,
        strokeWidth: 8.0,
        backgroundColor: Colors.white,
        valueColor: AlwaysStoppedAnimation<Color>(timerColor),
      ),
    );
  }

  Widget _buildMessage() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Column(
        children: [
          Text(
            "Solve this Sudoku Puzzle for your gift, solve it before the songs end for a secret gift Ami!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSudokuGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(9, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(9, (col) {
            return SizedBox(
              width: 40,
              height: 40,
              child: _buildSudokuCell(row, col),
            );
          }),
        );
      }),
    );
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
                  width: _backgroundController.value.size.width,
                  height: _backgroundController.value.size.height,
                  child: VideoPlayer(_backgroundController),
                ),
              ),
            ),
          Container(color: Colors.black.withOpacity(0.5)),
          _buildTimer(),
          _buildMessage(),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSudokuGrid(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _checkSolution,
                    child: Text('Submit Solution'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _showGiveUpPopup,
                    child: Text('Give Up!'),
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
