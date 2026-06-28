import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:handsprint/handsprint_game.dart';

import 'package:handsprint/overlays/game_over_overlay.dart';

class GameScreen extends StatefulWidget {

  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
     late HandsprintGame game;

final ValueNotifier<List<Landmark>> landmarksNotifier = ValueNotifier<List<Landmark>>([]);

bool isReady = false;
Future<void> _initializeTracking() async {
  // Initialize hand tracking or other setup here
  setState(() {
    isReady = true;
  });
}
  @override
void initState() {
  super.initState();

  game = HandsprintGame();

  _initializeTracking();
}
@override
void dispose() {
 
  super.dispose();
}
 @override
Widget build(BuildContext context) {
  if (!isReady) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  return Scaffold(
    body: Stack(
      children: [

        GameWidget(
          game: game,
          overlayBuilderMap: {
            'GameOver':(context,HandsprintGame gameInstance)=>GameOverOverlay(gameInstance)
          },
        ),

       
      ],
    ),
  );
}
}