# 🧠 Perch Eye SDK React Native Documentation

The **Perch Eye SDK** for React Native allows you to extract unique face hashes from image sequences and verify them against new images. The SDK is built using TensorFlow and C++ and provides high performance for mobile applications, with zero dependencies.

---

## 🔧 Integration

Install the native module:

```bash
npm install react-native-perch-eye
```

---

## 🔧 Initialization

```ts
import { init, destroy } from 'react-native-perch-eye';

await init();      // Init native engine
await destroy();   // Cleanup
```

---

## 🚀 Usage

### 🔐 Enroll - Create Hash From Face Images

```ts
import { openTransaction, addImage, enroll } from 'react-native-perch-eye';

await openTransaction();
await addImage(base64Image1);
await addImage(base64Image2);
// ...
const hash = await enroll();
```

---

### 🧪 Verify - Compare New Face With Stored Hash

```ts
import { openTransaction, addImage, verify } from 'react-native-perch-eye';

await openTransaction();
await addImage(base64ImageNew);
// ...
const similarity = await verify(hash);
```

---

### ⚡ Raw Pixels Support

```ts
import { addImageRaw } from 'react-native-perch-eye';

await addImageRaw(pixels, width, height); // RGBA int array
```

---

### ⚡ Lightweight Methods (Normalized 160x160)

```ts
import { evaluate, compareList } from 'react-native-perch-eye';

const hash = await evaluate(base64Images);
const similarity = await compareList(base64Images, hash);
```

---

### ⚡ Optional: Direct Face Comparison

```ts
import { compareFaces } from 'react-native-perch-eye';

const sim = await compareFaces(img1, img2);
```

---

## ❗ Error Codes

addImage method error codes :

```ts
// Returned string:
"SUCCESS" |
"FACE_NOT_FOUND" |
"FILE_NOT_FOUND" |
"TRANSACTION_NOT_OPEN" |
"SDK_NOT_INITIALIZED" |
"INTERNAL_ERROR"
```

---

## ✅ Summary
- Minimal, high-performance Flutter SDK for face hash comparison.
- Zero dependencies, designed for mobile applications.
- Works with both base64 and raw RGBA face images.
- Includes methods for enrolling, verifying, and comparing face hashes.
