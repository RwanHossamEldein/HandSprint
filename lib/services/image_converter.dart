import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ImageConverter {
  // Converts a CameraImage to an InputImage compatible with ML Kit
  static InputImage? cameraImageToInputImage({
    required CameraImage image,
    required CameraController controller,
  }) {
    try {
   
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();


      final sensorOrientation = controller.description.sensorOrientation;
      final imageRotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      if (imageRotation == null) return null;


      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);
      if (inputImageFormat == null) return null;

  
      final inputImageData = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );
    } catch (e) {
      debugPrint("Error converting CameraImage to InputImage: $e");
      return null;
    }
  }
}
