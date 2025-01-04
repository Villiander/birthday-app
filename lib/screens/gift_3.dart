import 'package:flutter/material.dart';

class Gift3Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gift 3')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You received Gift 3! 🎁'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/final_sequence');  // Navigate to Final Animation after receiving Gift 3
              },
              child: Text('Proceed to Final Animation'),
            ),
          ],
        ),
      ),
    );
  }
}
