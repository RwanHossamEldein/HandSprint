import 'package:flutter/material.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

class HandPointsPainter extends CustomPainter {

  final List<Landmark> landmarks;

  HandPointsPainter(this.landmarks);
 
  final paintVar= Paint()
  ..color = Colors.cyanAccent 
  ..style = PaintingStyle.fill; 
  @override
  void paint(Canvas canvas, Size size) {
   for (var landmark in landmarks) {

  final x = landmark.x * size.width;
  final y = landmark.y * size.height;


  canvas.drawCircle(Offset(x, y), 4, paintVar);
}
  
  }
  
 @override
bool shouldRepaint(covariant HandPointsPainter oldDelegate) {
  return oldDelegate.landmarks != landmarks;
}
}