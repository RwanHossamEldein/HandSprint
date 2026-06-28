
import 'package:flutter/material.dart';
import 'package:handsprint/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();


 runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GameScreen(),
  ),
);
}