import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum HandState { left, center, right }

class PoseDetectorService {

  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;

  PoseDetectorService({
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
  });

  bool _isCalibrated = false;


  double _calibratedOffsetX = 0.0;
  double _calibratedOffsetY = 0.0;

  final double _xThreshold = 60.0;     
  final double _jumpThreshold = 60.0; 
  final double _slideThreshold = 50.0;

  HandState _currentHandState = HandState.center;
  DateTime? _lastVerticalActionTime;
  final Duration _verticalCooldown = const Duration(milliseconds:300);


  void triggerCalibration() {
    _isCalibrated = false;
    _currentHandState = HandState.center;
    debugPrint("Calibration triggered. Standing by for next frame...");
  }

  void analyzePose(Pose pose) {
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (nose == null || (leftWrist == null && rightWrist == null)) return;

    final double leftScore = leftWrist?.likelihood ?? 0.0;
    final double rightScore = rightWrist?.likelihood ?? 0.0;
    final activeWrist = (leftScore > rightScore) ? leftWrist : rightWrist;

    if (activeWrist == null || activeWrist.likelihood < 0.5) return;

    final double handX = activeWrist.x;
    final double handY = activeWrist.y;

  
    if (!_isCalibrated) {
      _calibratedOffsetX = handX - nose.x;
      _calibratedOffsetY = handY - nose.y;
      _isCalibrated = true;
      debugPrint("Calibration successful! Offset X: $_calibratedOffsetX, Offset Y: $_calibratedOffsetY");
    }


    final double targetCenterX = nose.x + _calibratedOffsetX;
    final double targetCenterY = nose.y + _calibratedOffsetY;

    final now = DateTime.now();

    if (_currentHandState == HandState.center) {

      if (handX < targetCenterX - _xThreshold) {
        _currentHandState = HandState.right;
        onSwipeRight?.call(); 
      } 
      
      else if (handX > targetCenterX + _xThreshold) {
        _currentHandState = HandState.left;
        onSwipeLeft?.call(); 
      }
    } 

    else if (_currentHandState == HandState.right) {
      if (handX > targetCenterX - (_xThreshold * 0.4)) {
        _currentHandState = HandState.center;
        onSwipeLeft?.call(); 
      }
    } 

    else if (_currentHandState == HandState.left) {
      if (handX < targetCenterX + (_xThreshold * 0.4)) {
        _currentHandState = HandState.center;
        onSwipeRight?.call(); 
      }
    }


    if (_lastVerticalActionTime == null || 
        now.difference(_lastVerticalActionTime!) > _verticalCooldown) {

      if (handY < targetCenterY - _jumpThreshold) {
        onSwipeUp?.call();
        _lastVerticalActionTime = now;
      } 

      else if (handY > targetCenterY + _slideThreshold) {
        onSwipeDown?.call();
        _lastVerticalActionTime = now;
      }
    }
  }
}