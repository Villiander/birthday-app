import 'package:flutter/material.dart';
import 'package:my_birthday_app/widgets/matrix_background.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
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
                  'Hey bday girl :)',
                  style: TextStyle(color: Colors.green, fontSize: 30),
                ),
                const SizedBox(height: 10),
                Text(
                  'Press Start to Begin',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/greeting');
                  },
                  child: Text('Start'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}