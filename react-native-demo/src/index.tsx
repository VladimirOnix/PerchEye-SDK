import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'reactnativedemo' doesn't seem to be linked. Make sure: \n\n` +
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

export function compareImages(img1: string, img2: string): Promise<number> {
  return new Promise((resolve, reject) => {
    PerchEye.compare(img1, img2)
      .then((similarity) => {
        resolve(similarity);
      })
      .catch((error) => {
        console.error('Error comparing images:', error);
        reject(0);
      });
  });
}
