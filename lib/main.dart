import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:handsprint/handsprint_game.dart';
import 'package:handsprint/overlays/game_over_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final game = HandsprintGame();

  runApp(
    GameWidget(
      game: game,
      overlayBuilderMap: {
        'GameOver': (context, game) {
          return GameOverOverlay(
            game as HandsprintGame,
          );
        },
      },
    ),
  );
}