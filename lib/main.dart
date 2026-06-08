import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:handsprint/handsprint_game.dart';

void main()async {
   WidgetsFlutterBinding.ensureInitialized();
   await Flame.device.fullScreen();
  await Flame.device.setPortrait();
  runApp(GameWidget(game:HandsprintGame())); 
}

