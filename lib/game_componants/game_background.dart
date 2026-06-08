import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:handsprint/const/game_images/game_images.dart';

// ignore: deprecated_member_use
class GameBackground extends ParallaxComponent with HasGameRef {
  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    parallax = await Parallax.load(
      [
        ParallaxImageData(GameImages.road),
      ],
      baseVelocity: Vector2(0, -250.0),   
      size: gameRef.size,
      repeat: ImageRepeat.repeat,
      fill: LayerFill.width,
      alignment: Alignment.center,
    );
    await super.onLoad();
  }
  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    size = newSize;
  }
}