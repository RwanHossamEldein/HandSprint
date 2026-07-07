# HandSprint 🏃‍♂️🎮

**HandSprint** is an innovative, touchless 2D endless runner game built using the **Flutter** framework and **Flame Game Engine**. Controlled entirely by real-time body and hand gestures captured via the front camera, HandSprint brings a Wii/Kinect-style gaming experience directly to your mobile device using **Google ML Kit Pose Detection**.

---

##  Key Features

* **Touchless Gesture Control:** Move your hand in the air to control the character on screen.
* **Auto-Calibration System:** Automatically calibrates the dynamic offset between your hand and your nose every time you start or restart the game, adjusting to any comfortable posture.
* **Horizon-Spawn Perspective:** Obstacles spawn dynamically near the horizon (top of the screen) at a small scale and grow larger as they approach, providing a realistic 3D perspective effect.
* **Balanced Game Physics:** Specially optimized obstacle speeds, spawn distances, and collision hitboxes to accommodate natural camera processing latency.
* **Clean & Modular Architecture:** Strictly decoupled design separating the Flame Game loop, the Flutter UI, and the ML Kit Pose Detection services.

---

## 🎮 How to Play

1. **Get in Position:** Place your phone on a stable surface, stand or sit comfortably in front of the front camera, and raise your hand.
2. **Auto-Calibrate:** Start a new run or click **Restart** after a Game Over. Hold your hand still in a comfortable "resting" center position for **1 second** while the game calibrates your baseline.
3. **Control the Runner:**
   * 👈 **Move Left:** Move your hand to your left (away from center).
   * 👉 **Move Right:** Move your hand to your right (away from center).
   * 🏠 **Return to Center:** Bring your hand back to your center line (the player returns to the center lane automatically!).
   * 🔼 **Jump:** Raise your hand quickly above the center baseline to jump over low barriers.
   * 🔽 **Slide / Duck:** Lower your hand quickly below the center baseline to slide under high obstacles.

---

##  Tech Stack & Dependencies

* **Framework:** [Flutter](https://flutter.dev)
* **Game Engine:** [Flame](https://flame-engine.org) (v1.37+)
* **Machine Learning:** [Google ML Kit Pose Detection](https://developers.google.com/ml-kit/vision/pose-detection) (runs fully on-device)
* **Camera Streaming:** [Camera Package](https://pub.dev/packages/camera) (YUV420 image streaming)

---

##  Codebase Directory Structure

```text
lib/
├── const/
│   └── game_images/             # Constants for asset images and sprite sheets
├── game_componants/             # Flame Game Components
│   ├── coins.dart               # Collectible gold coins
│   ├── game_background.dart     # Scrolling parallax road background
│   ├── game_lane.dart           # Geometry coordinates for the 3 lanes
│   ├── high_obstacles.dart      # Obstacles requiring sliding to dodge
│   ├── low_obstacles.dart       # Obstacles requiring jumping to dodge
│   ├── player_component.dart    # Player animations, states, and physics
│   └── player_state.dart        # Enum for player animation states
├── overlays/
│   └── game_over_overlay.dart   # Flutter Game Over UI screen with restart button
├── services/
│   ├── image_converter.dart     # Converts camera YUV planes to ML Kit InputImage format
│   └── pose_detector_service.dart# Interprets coordinate offsets to detect gestures
├── widgets/
│   └── camera_preview_widget.dart# Stylized rounded camera preview overlay
├── game_screen.dart             # Main screen linking camera stream to the Flame widget
└── main.dart                    # App entry point and Flutter bindings
```

---

## 🔧 Installation & Setup

### Prerequisites
* Flutter SDK (3.10.0+ recommended)
* A physical Android or iOS device with a working front camera (Android Emulator / iOS Simulator do not support physical camera streams out of the box).

### Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/handsprint.git
   cd handsprint
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```


## Performance Optimization Details

To make this game run smoothly on mid-range and budget devices, we implemented several performance enhancements:
* **Frame Throttling:** Instead of processing all 30 frames per second from the camera, the app limits processing to one frame every **80ms** (approx. 12.5 FPS) when optimized. This reduces CPU load by 60% with zero impact on perceived responsiveness.
* **Physics Stability:** Clamped the movement interpolation coefficient to prevent the player character from flying off-screen or disappearing during heavy lag spikes.
* **Dynamic Horizon Scaling:** Obstacles scale up dynamically relative to their movement speed, creating a clean perspective effect while starting from a tiny Y-coordinate.

  
## Screenshots
<img width="1920" height="1080" alt="Screenshot (457)" src="https://github.com/user-attachments/assets/7246a9f8-4e2a-406a-8006-338c20437694" />
<img width="1920" height="1080" alt="Screenshot (458)" src="https://github.com/user-attachments/assets/d33dabdd-ec70-44f3-9b7d-b76fd534b67e" />
<img width="1920" height="1080" alt="Screenshot (459)" src="https://github.com/user-attachments/assets/11bf9963-b843-49c0-bff1-3793b9a49696" />
