import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:my_birthday_app/widgets/matrix_background.dart'; // Import the matrix effect widget

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();

    // Initialize the audio player and load the sound
    _audioPlayer = AudioPlayer();
    _audioPlayer.play(AssetSource('sounds/matrix_background.ogg')); // Play the sound
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the sound indefinitely

  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _login() {
    String username = usernameController.text;
    String password = passwordController.text;

    if ((username == 'Ami Chopra' || username == 'ami' || username == 'Ami' || username == 'ami chopra') && password == 'pagereplacement') {
      _audioPlayer.stop();
      Navigator.pushNamed(context, '/greeting');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aahh, only Ami can see this, no one else can!!!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Matrix background animation widget
          MatrixBackground(),

          // Centered login content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
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
