import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'screens/greeting_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/video_screen.dart';
import 'screens/yoda_screen.dart';
import 'screens/celebrity_screen.dart';
import 'screens/final_sequence.dart';
import 'screens/message.dart';
import 'screens/end.dart';
import 'screens/challenge1.dart';
import 'screens/challenge2.dart';
import 'screens/challenge3.dart';
import 'screens/gift_1.dart';
import 'screens/gift_2.dart';
import 'screens/gift_3.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Birthday App',
      initialRoute: '/',
      routes: {
        '/': (context) => StartScreen(),
        '/greeting': (context) => GreetingScreen(),
        '/quiz': (context) => QuizScreen(),
        '/video': (context) => VideoScreen(),
        '/yoda': (context) => YodaScreen(),
        '/celebrity': (context) => CelebrityScreen(),
        '/final_sequence': (context) => FinalAnimationScreen(),
        '/heartfelt_message': (context) => HeartfeltMessageScreen(),
        '/end': (context) => EndScreen(),
        '/challenge1': (context) => Challenge1Screen(),
        '/gift_1': (context) => Gift1Screen(),
        '/challenge2': (context) => Challenge2Screen(),
        '/gift_2': (context) => Gift2Screen(),
        //'/challenge3': (context) => Challenge3Screen(),
        //'/gift_3': (context) => Gift3Screen(),
      },
    );
  }
}
