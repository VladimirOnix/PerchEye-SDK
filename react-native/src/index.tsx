import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-perch-eye' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const PerchEye = NativeModules.PerchEyeModule
  ? NativeModules.PerchEyeModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function extractDescriptor(images: string[]): Promise<number[][]> {
  return PerchEye.extractDescriptor(images);
}

export function setGallery(gallery: { name: string; descriptor: number[] }[]) {
  PerchEye.setGallery(gallery);
}

export function recognize(
  image: string,
  onRecognition: (name: string, similarity: number) => void
) {
  PerchEye.recognize(image, onRecognition);
}
