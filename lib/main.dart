import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:handsprint/handsprint_game.dart';

void main()async {
   WidgetsFlutterBinding.ensureInitialized();
   await Flame.device.fullScreen();
  await Flame.device.setPortrait();
  runApp(GameWidget(game:HandsprintGame(

  ),overlayBuilderMap: {
    'GameOver': (context, HandsprintGame game) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Game Over', style: TextStyle(fontSize: 48, color: Colors.white)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('GameOver');
                game.reset(); // Reset the game state
              },
              child: Text('Restart'),
            ),
          ],
        ),
      );
    },
  },));
}

