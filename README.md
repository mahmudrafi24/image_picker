## 📱 Overview

A Flutter project demonstrating a **fully custom image picker** and **path provider** built from scratch using platform channels. This implementation supports picking images from the device's gallery or camera, displaying them in a simple UI, and saving them to the app's persistent documents directory—all without using third-party packages like `image_picker` or `path_provider`.

**Why Custom Implementation?**
- 🎯 Better control over functionality
- 📦 Lighter app size (no external dependencies)
- 🔧 Direct handling of platform-specific features
- 📚 Educational resource for understanding platform channels

## ✨ Features

### Custom Image Picker
- 📁 **Gallery Selection**: Access device photo library
- 📷 **Camera Capture**: Take new photos directly
- 🔄 Returns `dart:io.File` object with image path (JPEG format)
- ❌ Graceful handling of user cancellation
- ⚠️ Built-in error handling for unavailable features

### Custom Path Provider
- 🗂️ **Temporary Directory**: For short-lived files
- 💾 **Application Documents Directory**: For persistent storage
- 🔐 Platform-specific secure paths (iOS sandbox, Android private directories)

### User Interface
- 🎨 Clean, minimal design
- 👁️ Real-time image preview
- 📍 Display save path information
- 🔄 Auto-save on image selection
- 📱 Responsive layout

### Platform Support
- ✅ Android (API 21+) with runtime permissions
- ✅ iOS (12+) with automatic permission prompts
- 🧪 Tested on physical devices


## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.24.0 or later ([Install Guide](https://flutter.dev/docs/get-started/install))
- **Android Development**:
  - Android Studio with SDK 34+
  - Physical Android device (API 21+) recommended
- **iOS Development** (macOS only):
  - Xcode 16+
  - Physical iOS device (iOS 12+) recommended
- Run `flutter doctor` to verify setup

### Installation

1. **Clone or create the project**
   ```bash
   flutter create custom_image_picker_app
   cd custom_image_picker_app
   ```

2. **Configure Android Permissions**
   
   Add to `android/app/src/main/AndroidManifest.xml` (before `<application>`):
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
   ```

   Add FileProvider inside `<application>`:
   ```xml
   <provider
       android:name="androidx.core.content.FileProvider"
       android:authorities="${applicationId}.fileprovider"
       android:exported="false"
       android:grantUriPermissions="true">
       <meta-data
           android:name="android.support.FILE_PROVIDER_PATHS"
           android:resource="@xml/file_paths" />
   </provider>
   ```

   Create `android/app/src/main/res/xml/file_paths.xml`:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <paths xmlns:android="http://schemas.android.com/apk/res/android">
       <external-files-path name="my_images" path="Pictures" />
   </paths>
   ```

3. **Configure iOS Permissions**
   
   Add to `ios/Runner/Info.plist` inside `<dict>`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>This app needs camera access to take photos.</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>This app needs photo library access to select images.</string>
   ```

4. **Add the source files**
   - `lib/custom_image_picker.dart`: Image picker interface
   - `lib/custom_path_provider.dart`: Path provider interface
   - `lib/main.dart`: App entry point and UI
   - Update `MainActivity.kt` (Android) and `AppDelegate.swift` (iOS) with platform channel handlers

5. **Run the app**
   ```bash
   flutter pub get
   flutter run
   ```

## 📖 Usage

1. Launch the app to see Gallery and Camera buttons
2. **Tap Gallery** → Select an image → View preview and save confirmation
3. **Tap Camera** → Capture a photo → View preview and save confirmation
4. Images are automatically saved to the app's documents directory
5. Check console logs for detailed save paths

### Code Example

```dart
// Pick from gallery
final File? image = await CustomImagePicker.pickImage(
  source: ImageSource.gallery,
);

// Get documents directory
final Directory? appDir = await CustomPathProvider.getApplicationDocumentsDirectory();

// Save image
if (image != null && appDir != null) {
  final String newPath = '${appDir.path}/picked_image.jpg';
  await image.copy(newPath);
  print('Image saved to: $newPath');
}
```

## 📁 Project Structure

```
custom_image_picker_app/
├── lib/
│   ├── main.dart                    # App entry + UI
│   ├── custom_image_picker.dart     # Image picker channel
│   └── custom_path_provider.dart    # Path provider channel
├── android/
│   ├── app/src/main/
│   │   ├── kotlin/.../MainActivity.kt    # Android channel handlers
│   │   ├── AndroidManifest.xml           # Permissions config
│   │   └── res/xml/file_paths.xml        # FileProvider paths
│   └── build.gradle
├── ios/
│   ├── Runner/
│   │   ├── AppDelegate.swift        # iOS channel handlers
│   │   └── Info.plist               # iOS permissions
│   └── Runner.xcworkspace
├── pubspec.yaml                     # No external dependencies!
└── README.md
```

## 🔧 Building for Release

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
# Then use Xcode: Product → Archive → Distribute App
```

For production builds, consider adding obfuscation:
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| **Permission Denied** | Reinstall app or add runtime permission checks |
| **Channel Not Found** | Verify channel names match exactly: `custom_picker_channel`, `custom_path_channel` |
| **Camera Not Working on Emulator** | Use a physical device for camera functionality |
| **iOS Build Errors** | Run `cd ios && pod install` |
| **Path Returns Null** | Check native platform logs (Logcat/Xcode console) |

View logs:
```bash
flutter logs
# Android: adb logcat
# iOS: Xcode console
```

## 💡 Enhancement Ideas

- [ ] Multi-image selection support
- [ ] Image compression and resizing
- [ ] Thumbnail grid view
- [ ] Web and desktop platform support
- [ ] Custom image cropping
- [ ] Video capture support
- [ ] Error handling UI improvements

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by Flutter's [Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels) documentation
- Thanks to the Flutter community for excellent tooling and resources

## 📞 Support

If you have questions or run into issues:
- Open an issue on GitHub
- Check Flutter forums and Stack Overflow
- Review Flutter's official documentation

---

