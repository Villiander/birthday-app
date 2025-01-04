import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:my_birthday_app/widgets/matrix_background.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int selectedAnswer = -1;
  String? selectedFlavor;

  late AudioPlayer _audioPlayer;

  final List<String> cakeFlavors = [
    'Chocolate',
    'Vanilla',
    'Strawberry',
    'Red Velvet',
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playMatrixAudio();
  }

  void checkAnswer(String flavor, int selectedOption) async {
    setState(() {
      selectedAnswer = selectedOption;
      selectedFlavor = flavor;
    });

    if (flavor == 'None of these') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please WhatsApp me the cake flavor you like! 🙏',
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      await Future.delayed(Duration(seconds: 3));
    }
    _audioPlayer.stop();
    Navigator.pushNamed(context, '/video');
  }

  void _playMatrixAudio() async {
    _audioPlayer = AudioPlayer();
    _audioPlayer.play(AssetSource('sounds/matrix_background.ogg'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MatrixBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'What is your favorite cake flavor? 🍰',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.6),
                        offset: Offset(3.0, 3.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'If none of these, please select "None of these" and WhatsApp me your favorite! 🙏',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 400,
                  height: 350,
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cakeFlavors.length + 1,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.0,
                    ),
                    itemBuilder: (context, index) {
                      if (index == cakeFlavors.length) {
                        return _buildOptionButton(
                          index + 1,
                          'None of these',
                          'None of these',
                        );
                      }
                      return _buildOptionButton(
                        index + 1,
                        cakeFlavors[index],
                        cakeFlavors[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int optionNumber, String text, String flavorName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedAnswer == optionNumber ? Colors.green : Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontFamily: 'Playfair Display',
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.black.withOpacity(0.6),
              offset: Offset(3.0, 3.0),
            ),
          ],
        ),
      ),
      onPressed: () => checkAnswer(flavorName, optionNumber),
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
