# App Icon Setup Guide

## Overview

Your app currently uses the default Flutter icon. Here's how to change it to a custom icon for the clothes remote control app.

## Quick Setup (Using flutter_launcher_icons)

### Step 1: Add Dependency

Edit `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### Step 2: Create Icon Configuration

Create `flutter_launcher_icons.yaml` in project root:
```yaml
flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icon/app_icon.png"
  
  # Android specific
  android_adaptive_round_icon: "assets/icon/app_icon_round.png"
  
  # iOS specific
  ios_settings:
    - size: 1024
```

### Step 3: Prepare Icon Files

Create `assets/icon/` directory and add:
- `app_icon.png` (1024x1024 pixels)
- `app_icon_round.png` (1024x1024 pixels, for adaptive icons)

### Step 4: Generate Icons

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required sizes for Android and iOS!

---

## Manual Setup (Without flutter_launcher_icons)

### For Android

#### 1. Create Icon File
- Size: 192x192 pixels (for mdpi)
- Format: PNG with transparency
- Name: `ic_launcher.png`

#### 2. Place in Directories

Copy your icon to all these directories with appropriate sizes:

```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png (48x48)
├── mipmap-hdpi/ic_launcher.png (72x72)
├── mipmap-xhdpi/ic_launcher.png (96x96)
├── mipmap-xxhdpi/ic_launcher.png (144x144)
└── mipmap-xxxhdpi/ic_launcher.png (192x192)
```

#### 3. Icon Sizes Reference
- mdpi: 48x48
- hdpi: 72x72
- xhdpi: 96x96
- xxhdpi: 144x144
- xxxhdpi: 192x192

#### 4. Rebuild App
```bash
flutter clean
flutter run
```

### For iOS

#### 1. Open Xcode
```bash
open ios/Runner.xcworkspace
```

#### 2. Add Icon
1. Select Runner project
2. Go to Assets.xcassets
3. Right-click → New App Icon Set
4. Name it "AppIcon"
5. Drag your icon files to each size slot

#### 2. Icon Sizes for iOS
- 20x20 (iPhone Notification)
- 29x29 (iPhone Settings)
- 40x40 (iPhone Spotlight)
- 60x60 (iPhone App)
- 76x76 (iPad App)
- 83.5x83.5 (iPad Pro)
- 1024x1024 (App Store)

---

## Recommended Icon Design

For a clothes remote control app, consider:

### Design Elements
- 👕 Clothes hanger or shirt icon
- 🏠 Mini house icon
- ☀️ Sun/rain elements
- 🤖 Automation elements

### Color Scheme
- Primary: Indigo (#4F46E5)
- Secondary: Purple (#9333EA)
- Accent: Orange (#EA580C)
- Background: White or transparent

### Style
- Modern and clean
- Easily recognizable at small sizes
- Works in both light and dark themes
- Professional appearance

---

## Example Icon Design (ASCII Art)

```
    ┌─────────────┐
    │   ☀️ 🏠 ☀️  │
    │   👕 👕 👕  │
    │   ═══════   │
    │   🤖 ⚙️ 🔄  │
    └─────────────┘
```

---

## Online Icon Generators

If you don't have design software, use these free tools:

1. **Figma** (figma.com)
   - Free design tool
   - Create custom icons
   - Export in all sizes

2. **Canva** (canva.com)
   - Pre-made templates
   - Easy to customize
   - Export as PNG

3. **Adobe Express** (express.adobe.com)
   - Free design tool
   - Professional templates
   - Quick export

4. **App Icon Generator** (appicon.co)
   - Upload image
   - Auto-generates all sizes
   - Download for Android/iOS

---

## Step-by-Step with flutter_launcher_icons (Recommended)

### 1. Install Package
```bash
flutter pub add --dev flutter_launcher_icons
```

### 2. Create Icon
- Create a 1024x1024 PNG image
- Save as `assets/icon/app_icon.png`

### 3. Create Configuration
Create `flutter_launcher_icons.yaml`:
```yaml
flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/icon/app_icon.png"
    background_color: "#ffffff"
```

### 4. Generate Icons
```bash
flutter pub run flutter_launcher_icons
```

### 5. Verify
```bash
flutter clean
flutter run
```

---

## Troubleshooting

### Icons not updating
```bash
flutter clean
flutter pub get
flutter run
```

### Android icon not showing
1. Check icon is in correct mipmap folder
2. Verify AndroidManifest.xml has correct reference
3. Rebuild app

### iOS icon not showing
1. Check Assets.xcassets has AppIcon set
2. Verify all sizes are filled
3. Clean Xcode build folder
4. Rebuild app

### Icon looks blurry
1. Ensure source image is 1024x1024 or larger
2. Use PNG format with transparency
3. Avoid scaling up small images

---

## File Structure

```
project/
├── assets/
│   └── icon/
│       ├── app_icon.png (1024x1024)
│       └── app_icon_round.png (1024x1024)
├── android/
│   └── app/src/main/res/
│       ├── mipmap-mdpi/ic_launcher.png
│       ├── mipmap-hdpi/ic_launcher.png
│       ├── mipmap-xhdpi/ic_launcher.png
│       ├── mipmap-xxhdpi/ic_launcher.png
│       └── mipmap-xxxhdpi/ic_launcher.png
├── ios/
│   └── Runner/
│       └── Assets.xcassets/
│           └── AppIcon.appiconset/
├── flutter_launcher_icons.yaml
└── pubspec.yaml
```

---

## Current App Icon

Your app currently uses the default Flutter icon. To change it:

1. **Quick Method**: Use flutter_launcher_icons (recommended)
2. **Manual Method**: Replace PNG files in mipmap folders

---

## Next Steps

1. ✅ Design your icon (1024x1024 PNG)
2. ✅ Add flutter_launcher_icons to pubspec.yaml
3. ✅ Create flutter_launcher_icons.yaml
4. ✅ Run `flutter pub run flutter_launcher_icons`
5. ✅ Test on device

---

## Resources

- [Flutter Launcher Icons](https://pub.dev/packages/flutter_launcher_icons)
- [Android Icon Guidelines](https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher)
- [iOS App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Figma](https://figma.com)
- [Canva](https://canva.com)

---

## Summary

Your app icon can be easily customized using:
- **Recommended**: flutter_launcher_icons package (auto-generates all sizes)
- **Manual**: Replace PNG files in mipmap folders

Just create a 1024x1024 PNG image and let flutter_launcher_icons handle the rest! 🎨
