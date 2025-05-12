import React, { useState } from 'react';
import { View, Text, Button, Image, ScrollView, StyleSheet, Alert, ActivityIndicator } from 'react-native';
import { compareFaces, testString } from 'react-native-perch-eye'; // ✅ Правильный импорт
import * as ImagePicker from 'react-native-image-picker';

const includeExtra = true;

const FaceCompareScreen = () => {
  const [img1, setImg1] = useState<any>(null);
  const [img2, setImg2] = useState<any>(null);
  const [base64_1, setBase64_1] = useState<string | null>(null);
  const [base64_2, setBase64_2] = useState<string | null>(null);
  const [similarity, setSimilarity] = useState<number | null>(null);
  const [loading, setLoading] = useState(false);

  const cameraOptions = {
    saveToPhotos: false,
    mediaType: 'photo',
    includeBase64: true,
    includeExtra
  };

  const handleTakePhoto1 = () => {
    ImagePicker.launchCamera(cameraOptions, (res) => {
      if (res.didCancel || res.errorCode) return;
      if (res.assets?.length) {
        setImg1(res.assets[0]);
        setBase64_1(res.assets[0].base64 || null);
        setSimilarity(null);
      }
    });
  };

  const handleTakePhoto2 = () => {
    ImagePicker.launchCamera(cameraOptions, (res) => {
      if (res.didCancel || res.errorCode) return;
      if (res.assets?.length) {
        setImg2(res.assets[0]);
        setBase64_2(res.assets[0].base64 || null);
        setSimilarity(null);
      }
    });
  };

  const handlePickFromGallery = () => {
    ImagePicker.launchImageLibrary(
      {
        selectionLimit: 2,
        mediaType: 'photo',
        includeBase64: true,
        includeExtra,
      },
      (res) => {
        if (res.didCancel || res.errorCode) return;
        const assets = res.assets || [];
        if (assets.length >= 2) {
          setImg1(assets[0]);
          setImg2(assets[1]);
          setBase64_1(assets[0].base64 || null);
          setBase64_2(assets[1].base64 || null);
          setSimilarity(null);
        }
      }
    );
  };

  const handleCompare = async () => {
    if (base64_1 && base64_2) {
      setLoading(true);
      try {
        const sim = await compareFaces(base64_1, base64_2);
        setSimilarity(sim);
      } catch (error) {
        console.error(error);
        Alert.alert('Error', 'Failed to compare faces.');
      } finally {
        setLoading(false);
      }
    } else {
      Alert.alert('Error', 'Please select two images first.');
    }
  };

  const handleReset = () => {
    setImg1(null);
    setImg2(null);
    setBase64_1(null);
    setBase64_2(null);
    setSimilarity(null);
  };


const checkTestString = async () => {
  const result = await testString();
  alert(result);
};

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.header}>👁️ Face Similarity Check</Text>
      <Text style={{ marginBottom: 20 }}>
        Please upload or take two face photos to compare.
      </Text>

      <View style={styles.buttonRow}>
        <Button title="📸 First Photo" onPress={handleTakePhoto1} />
        <Button title="📸 Second Photo" onPress={handleTakePhoto2} />
      </View>

      <Button title="🖼️ Pick 2 Photos from Gallery" onPress={handlePickFromGallery} />

<Button title="Test" onPress={async () => {
  const text = await testString();
  alert(text);
}} />




      <View style={styles.imageRow}>
        {img1 && (
          <Image
            source={{ uri: img1.uri }}
            style={styles.image}
            accessibilityLabel="First image"
          />
        )}
        {img2 && (
          <Image
            source={{ uri: img2.uri }}
            style={styles.image}
            accessibilityLabel="Second image"
          />
        )}
      </View>

      {img1 && img2 && (
        <View style={{ gap: 20 }}>
          <Button title="🔍 Compare Faces" onPress={handleCompare} disabled={loading || similarity !== null} />
          <Button title="🔄 Start Over" onPress={handleReset} />
        </View>
      )}

      {loading && <ActivityIndicator size="large" color="#0000ff" />}

      {similarity !== null && (
        <Text style={styles.similarityText}>
          Similarity: {(similarity * 100).toFixed(2)}%
        </Text>
      )}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    justifyContent: 'flex-start',
    alignItems: 'center',
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '100%',
    marginBottom: 16,
  },
  imageRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '100%',
    marginBottom: 16,
    marginTop: 16,
  },
  image: {
    width: 120,
    height: 120,
    borderRadius: 8,
    marginHorizontal: 8,
  },
  similarityText: {
    fontSize: 16,
    fontWeight: '500',
    marginTop: 16,
  },
});

export default FaceCompareScreen;