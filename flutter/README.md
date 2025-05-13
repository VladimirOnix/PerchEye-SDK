# 🧠 Perch Eye SDK Flutter Documentation

The **Perch Eye SDK** for Flutter allows you to extract unique face hashes from image sequences and verify them against new images. The SDK is built using TensorFlow and C++ and provides high performance for mobile applications, with zero dependencies.

---

## 🔧 Integration

To include the Perch Eye SDK in your Flutter project, follow these steps:

1. Add the plugin to your `pubspec.yaml`:

```yaml
dependencies:
  perch_eye:
    path: ../flutter
```

2. Run `flutter pub get` to install the package.

---

## 🔧 Initialization

To initialize the SDK, call the `init()` method:

```dart
import 'package:perch_eye/perch_eye.dart';

PerchEye.init();
```

To clean up resources when no longer needed:

```dart
PerchEye.destroy();
```

---

## 🚀 Usage

### 🔐 Enroll - Create Hash From Face Images

To create a unique hash from a sequence of face images (base64 or raw RGBA format):

```dart
PerchEye.openTransaction();
await PerchEye.addImage(base64Image1);
await PerchEye.addImage(base64Image2);
// ... more images
String hash = await PerchEye.enroll();
```

### 🧪 Verify - Compare New Face With Stored Hash

To compare a new image sequence against a previously created hash:

```dart
PerchEye.openTransaction();
await PerchEye.addImage(base64Image4);
// ... more images
double similarity = await PerchEye.verify(hash);
```

---

### ⚡ Lightweight Methods (Normalized Input)

These methods are optimized for small (160x160), preprocessed face bitmaps:

```dart
String hash = await PerchEye.evaluate(base64Images);

double similarity = await PerchEye.compareList(base64Images, hash);
```

---

## ❗ Error Codes

addImage method error codes :

```dart
enum ImageResult {
    SUCCESS,
    FACE_NOT_FOUND,
    FILE_NOT_FOUND,
    TRANSACTION_NOT_OPEN,
    SDK_NOT_INITIALIZED,
    INTERNAL_ERROR
}
```

---

## ✅ Summary
- Minimal, high-performance Flutter SDK for face hash comparison.
- Zero dependencies, designed for mobile applications.
- Works with both base64 and raw RGBA face images.
- Includes methods for enrolling, verifying, and comparing face hashes.
