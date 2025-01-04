import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:gif/gif.dart';

class Gift1Screen extends StatefulWidget {
  @override
  _Gift1ScreenState createState() => _Gift1ScreenState();
}

class _Gift1ScreenState extends State<Gift1Screen> with TickerProviderStateMixin {
  int step = 0;
  bool unlockSecretGift = false;
  late GifController _gifController;
  final List<String> equations = [
    r"H(x) = \left\{ x < 0 : 0, x \geq 0 : 1 \right\}",
    r"y = H(x - 1/3) - H(x - 5/3)",
    r"x = 5.5 \left\{ 0 \leq y \leq 3 \right\}",
    r"y = ( - \left| 3x - 3 \right| + 3 ) * H(x) - ( - \left| 3x - 3 \right| + 3 ) * H(x - 2) + ( - \left| 5x - 14 \right| + 3 ) * H(x - 2.2) - ( - \left| 5x - 14 \right| + 3 ) * H(x - 3.4) + ( - \left| 5x - 20 \right| + 3 ) * H(x - 3.4) - ( - \left| 5x - 20 \right| + 3 ) * H(x - 4.6)",
    r"1.7\left(\ \left(\sin\left(t\right)\right)^{3}+4.5,\ 1+\frac{1}{16}\left(13\cos\left(t\right)-5\cos\left(2t\right)-2\cos\left(3t\right)-\cos\left(4t\right)\right)\right)"
  ];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this)
      ..addListener(() {
        if (_gifController.isCompleted) {
          _gifController.reset();
          _gifController.forward();
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      setState(() {
        unlockSecretGift = arguments?['unlockSecretGift'] ?? false;
      });
      _playSound('assets/sounds/gift_applause.mp3');
    });
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  @override
  void dispose() {
    _gifController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (step == 0) ...[
                Text(
                  "You won a pizza treat from me :)",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Gif(
                  image: AssetImage('assets/gifs/pizza.gif'),
                  controller: _gifController,
                  placeholder: (context) => const Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white),
                  ),
                  onFetchCompleted: () {
                    _gifController.reset();
                    _gifController.forward();
                  },
                  height: 200,
                  width: 200,
                ),
                SizedBox(height: 20),
                if (unlockSecretGift)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        step = 1;
                        _playSound('assets/sounds/secret_gift_applause.mp3');
                      });
                    },
                    child: Text('Next to Secret Gift'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/challenge2');
                    },
                    child: Text('Next Challenge'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
              ] else if (step == 1 && unlockSecretGift) ...[
                Text(
                  "You've unlocked the secret gift! 🎁✨",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  "Copy and paste the following equations one by one into the Desmos graphing calculator to see the plot\n"
                  "Disable the plot of the 1st equation (click the red symbol beside the eqn)\n"
                  "For the last equation, set the range of `t` as [0, 2pi]",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ...equations.map((eq) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: EquationCard(equation: eq),
                    )),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/challenge2');
                  },
                  child: Text('Next Challenge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EquationCard extends StatelessWidget {
  final String equation;

  EquationCard({required this.equation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              equation,
              style: TextStyle(
                fontSize: 16,
                color: Colors.greenAccent,
                fontFamily: 'RobotoMono',
              ),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.copy, color: Colors.blueAccent),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: equation)).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Equation copied: $equation'),
                    duration: Duration(seconds: 2),
                  ),
                );
              });
            },
            tooltip: 'Copy Equation',
          ),
        ],
      ),
    );
  }
}