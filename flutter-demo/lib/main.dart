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
  String? _enrollHash;
  String? _evaluateHash;
  List<String> _evaluateImages = [];
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    PerchEye.init();
  }

  @override
  void dispose() {
    PerchEye.destroy();
    super.dispose();
  }

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

  Future<void> _pickEvaluateImages() async {
    final files = await _picker.pickMultiImage();
    if (files == null || files.isEmpty) return;

    final base64List = await Future.wait(files.map((f) async {
      final bytes = await File(f.path).readAsBytes();
      return base64Encode(bytes);
    }));

    setState(() {
      _evaluateImages = base64List;
      _evaluateHash = null;
    });
  }

  Future<void> _evaluate() async {
    if (_evaluateImages.isEmpty) return _showError('Выберите изображения');
    setState(() => _inProgress = true);

    try {
      await PerchEye.openTransaction();
      final successful = await PerchEye.addImagesWithLogging(_evaluateImages);

      if (successful.isEmpty) {
        _showError('Ни одно изображение не прошло addImage');
        return;
      }

      final hash = await PerchEye.evaluate(successful);
      if (hash.isEmpty) {
        _showError('evaluate вернул пустой hash');
        return;
      }

      setState(() => _evaluateHash = hash);
    } catch (e) {
      _showError(e);
    } finally {
      setState(() => _inProgress = false);
    }
  }

  Future<void> _compareList() async {
    if (_evaluateHash == null || _evaluateImages.isEmpty) return;
    setState(() => _inProgress = true);
    try {
      await PerchEye.openTransaction();
      final sim = await PerchEye.compareList(_evaluateImages, _evaluateHash!);
      setState(() => _similarity = sim);
    } catch (e) {
      _showError(e);
    } finally {
      setState(() => _inProgress = false);
    }
  }

  Future<void> _enroll() async {
    if (_img1 == null) return;
    setState(() => _inProgress = true);
    try {
      final b64 = base64Encode(await _img1!.readAsBytes());
      await PerchEye.openTransaction();
      await PerchEye.addImage(b64);
      final hash = await PerchEye.enroll();
      setState(() => _enrollHash = hash);
    } catch (e) {
      _showError(e);
    } finally {
      setState(() => _inProgress = false);
    }
  }

  Future<void> _compareFaces() async {
    if (_img1 == null || _img2 == null) return;
    setState(() => _inProgress = true);
    try {
      final b64_1 = base64Encode(await _img1!.readAsBytes());
      final b64_2 = base64Encode(await _img2!.readAsBytes());
      final sim = await PerchEye.compareFaces(b64_1, b64_2);
      setState(() => _similarity = sim);
    } catch (e) {
      _showError(e);
    } finally {
      setState(() => _inProgress = false);
    }
  }

  void _clearAll() {
    setState(() {
      _img1 = null;
      _img2 = null;
      _similarity = null;
      _enrollHash = null;
      _evaluateHash = null;
      _evaluateImages = [];
    });
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PerchEye SDK Demo')),
      body: SingleChildScrollView(
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
          ElevatedButton(
            onPressed: (_img1 != null && !_inProgress) ? _enroll : null,
            child: const Text('Enroll Image 1'),
          ),
          ElevatedButton(
            onPressed: (_img2 != null && _img1 != null) ? _compareFaces : null,
            child: const Text('Compare Image 2 with Image 1'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _pickEvaluateImages,
            child: const Text('Pick Evaluate Images'),
          ),
          ElevatedButton(
            onPressed: (_evaluateImages.isNotEmpty && !_inProgress) ? _evaluate : null,
            child: const Text('Evaluate List'),
          ),
          ElevatedButton(
            onPressed: (_evaluateHash != null && _evaluateImages.isNotEmpty) ? _compareList : null,
            child: const Text('Compare List with Hash'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _clearAll,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
          const SizedBox(height: 24),
          if (_inProgress) const CircularProgressIndicator(),
          if (_similarity != null || _enrollHash != null || _evaluateHash != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SelectableText(
                [
                  if (_similarity != null)
                    'Similarity: ${_similarity!.toStringAsFixed(2)}',
                  if (_enrollHash != null)
                    'Enroll Hash:\n$_enrollHash',
                  if (_evaluateHash != null)
                    'Evaluate Hash:\n$_evaluateHash',
                ].join('\n\n'),
                style: const TextStyle(fontSize: 13),
              ),
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