import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:handsprint/input/hand_points_painter.dart';
class CameraView extends StatelessWidget {
  const CameraView({
    super.key, 
    required CameraController cameraController, 
    required this.landMarks,
  }) : _cameraController = cameraController;

  final CameraController _cameraController;
  final List<Landmark> landMarks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.lightBlue, width: 2),
      ),
     
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18), 
        child: Stack(
          fit: StackFit.expand, 
          children: [
            
            CameraPreview(_cameraController),
            
           
            CustomPaint(
              painter: HandPointsPainter(landMarks),
            ),
          ],
        ),
      ),
    );
  }
}