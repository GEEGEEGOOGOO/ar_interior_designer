// AR Service is simplified with ar_flutter_plugin
// The plugin handles most node management internally
// This file is kept for potential future extensions

class ARService {
  // Helper methods can be added here if needed for complex operations
  
  static double clampScale(double scale, double factor) {
    return (scale * factor).clamp(0.1, 2.0);
  }
  
  static double degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }
}