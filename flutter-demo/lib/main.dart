import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:perch_eye/perch_eye.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(home: ComparePage());
}

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});
  @override
  _ComparePageState createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final ImagePicker _picker = ImagePicker();
  File? _img1, _img2;
  double? _similarity;
  bool _inProgress = false;

  Future<void> _pickImageSlot(int slot) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            title: const Text('Camera'),
            onTap: () => Navigator.pop(_, ImageSource.camera),
          ),
          ListTile(
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(_, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;

    final XFile? file = await _picker.pickImage(source: source);
    if (file == null) return;

    setState(() {
      if (slot == 1) _img1 = File(file.path);
      else _img2 = File(file.path);
      _similarity = null;
    });
  }

  Future<void> _compare() async {
    if (_img1 == null || _img2 == null) return;
    setState(() => _inProgress = true);

    try {
      final b64_1 = base64Encode(await _img1!.readAsBytes());
      final b64_2 = base64Encode(await _img2!.readAsBytes());
      final sim = await PerchEye.compareFaces(b64_1, b64_2);
      setState(() => _similarity = sim);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _inProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PerchEye Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImageSlot(1, _img1),
              _buildImageSlot(2, _img2),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            label: const Text('Compare'),
            onPressed:
            (_img1 != null && _img2 != null && !_inProgress) ? _compare : null,
          ),
          const SizedBox(height: 24),
          if (_inProgress) const CircularProgressIndicator(),
          if (_similarity != null)
            Text(
              'Similarity: ${_similarity!.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
        ]),
      ),
    );
  }

  Widget _buildImageSlot(int index, File? img) {
    return GestureDetector(
      onTap: () => _pickImageSlot(index),
      child: Container(
        width: 160,
        height: 160,
        color: Colors.grey[300],
        child: img != null
            ? Image.file(img, fit: BoxFit.cover)
            : Center(child: Text('Select #$index')),
      ),
    );
  }
}