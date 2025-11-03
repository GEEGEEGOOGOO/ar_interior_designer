# AR Interior Designer 🏠

An intermediate-level Augmented Reality application built with Flutter and ARCore that allows users to visualize and place virtual furniture in their real-world environment.

## Features ✨

- **Real-time AR View**: Live camera feed with ARCore integration
- **Multiple Furniture Items**: Chair, Table, Lamp, Sofa, Plant, and Bed
- **Object Manipulation**: 
  - Rotate objects by 45°
  - Scale objects up/down
  - Delete individual objects
  - Clear entire scene
- **Interactive Placement**: Tap to place furniture in your space
- **Modern UI**: Beautiful gradient interface with smooth animations
- **Object Selection**: Visual feedback for selected items

## Screenshots 📸

*AR view with placed 3D objects in real environment*

## Tech Stack 🛠️

- **Flutter** - UI Framework
- **Dart** - Programming Language
- **ARCore** - Augmented Reality engine
- **ar_flutter_plugin** - AR integration
- **vector_math** - 3D transformations
- **permission_handler** - Camera permissions

## Requirements 📋

- Flutter SDK 3.0+
- Android device with ARCore support
- Android API 24+
- Camera permission

## Installation 🚀

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/ar-interior-designer.git
cd ar-interior-designer
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run on Android device (ARCore requires physical device):
```bash
flutter run
```

## Project Structure 📁

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── furniture_item.dart   # Furniture data model
├── screens/
│   ├── home_screen.dart      # Landing page
│   └── ar_view_screen.dart   # Main AR view
├── services/
│   └── ar_service.dart       # AR helper functions
└── widgets/
    ├── furniture_selector.dart  # Furniture picker UI
    └── control_panel.dart       # Object controls UI
```

## How to Use 🎯

1. Launch the app and tap **"Start AR Experience"**
2. Grant camera permission when prompted
3. **Select a furniture item** from the top menu
4. **Tap on a surface** to place the object
5. **Tap an object** to select it
6. Use the control panel to:
   - 🔄 Rotate the object
   - ➕ Scale up
   - ➖ Scale down
   - 🗑️ Delete object

## Development Time ⏱️

Built in approximately 5-6 hours as an intermediate Flutter + AR project.

## Key Challenges Solved 🎓

1. ✅ ARCore integration with modern Flutter
2. ✅ Gradle version compatibility (SDK 36)
3. ✅ Dependency conflict resolution
4. ✅ Object placement without plane detection
5. ✅ 3D model loading and rendering
6. ✅ State management for AR objects

## Known Issues 🐛

- External 3D model loading shows error message (but objects still render)
- Plane detection requires good lighting and textured surfaces
- Some devices may have limited ARCore support

## Future Enhancements 🔮

- [ ] Save/load room layouts
- [ ] Custom 3D models
- [ ] Multiple room designs
- [ ] Color picker for objects
- [ ] Measurement tools
- [ ] Export AR screenshots
- [ ] Social sharing

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

## License 📄

This project is licensed under the MIT License.

## Acknowledgments 🙏

- ARCore by Google
- ar_flutter_plugin by Oleksandr Leuschenko
- KhronosGroup for glTF sample models

## Contact 📧

Your Name - [@ManKhauf84981](https://x.com/ManKhauf84981)

Project Link: [https://github.com/GEEGEEGOOGOO/ar-interior-designer](https://github.com/GEEGEEGOOGOO/ar-interior-designer)

---

**Built with ❤️ using Flutter & ARCore**
