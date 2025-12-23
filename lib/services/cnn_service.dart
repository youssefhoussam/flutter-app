import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CNNService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  // Load model and labels
  Future<void> loadModel() async {
    try {
      // Load the model
      _interpreter = await Interpreter.fromAsset(
        'assets/models/cnn_model.tflite',
      );

      // Load labels
      final labelsData = await rootBundle.loadString(
        'assets/labels/cnn_labels.txt',
      );
      _labels = labelsData
          .split('\n')
          .where((label) => label.isNotEmpty)
          .toList();

      _isLoaded = true;
      print('CNN Model loaded successfully');
    } catch (e) {
      print('Error loading CNN model: $e');
      throw 'Failed to load CNN model';
    }
  }

  // Predict from image file
  Future<Map<String, dynamic>> predictImage(File imageFile) async {
    if (!_isLoaded) {
      await loadModel();
    }

    try {
      // 1. Read and decode image
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw 'Failed to decode image';
      }

      // 2. RESIZE: Updated from 224 to 64 to match your CNN model (64x64x3 = 12,288 elements)
      final resizedImage = img.copyResize(image, width: 64, height: 64);

      // 3. Convert image to input format using 64x64
      var input = _imageToByteListFloat32(resizedImage, 64, 64);

      // 4. Prepare output buffer
      var output = List.filled(
        _labels.length,
        0.0,
      ).reshape([1, _labels.length]);

      // 5. Run inference
      _interpreter!.run(input, output);

      // 6. Get results
      final predictions = output[0] as List<double>;

      // Find top prediction
      double maxScore = predictions[0];
      int maxIndex = 0;
      for (int i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxScore) {
          maxScore = predictions[i];
          maxIndex = i;
        }
      }

      // Get all predictions sorted
      List<Map<String, dynamic>> allPredictions = [];
      for (int i = 0; i < predictions.length; i++) {
        allPredictions.add({
          'label': _labels[i],
          'confidence': predictions[i] * 100,
        });
      }
      allPredictions.sort((a, b) => b['confidence'].compareTo(a['confidence']));

      return {
        'label': _labels[maxIndex],
        'confidence': maxScore * 100,
        'allPredictions': allPredictions.take(3).toList(),
      };
    } catch (e) {
      print('Error during prediction: $e');
      throw 'Prediction failed: $e';
    }
  }

  // Convert image to Float32 List
  List<List<List<List<double>>>> _imageToByteListFloat32(
    img.Image image,
    int inputSize,
    int inputSize2,
  ) {
    var convertedBytes = List.generate(
      1,
      (index) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize2,
          (x) => List.generate(3, (c) {
            var pixel = image.getPixel(x, y);
            // Normalize pixel values to [0, 1]
            if (c == 0) return pixel.r / 255.0;
            if (c == 1) return pixel.g / 255.0;
            return pixel.b / 255.0;
          }),
        ),
      ),
    );
    return convertedBytes;
  }

  void dispose() {
    _interpreter?.close();
  }
}
