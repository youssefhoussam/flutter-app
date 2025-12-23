import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ANNService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/ann_model.tflite',
      );

      final labelsData = await rootBundle.loadString(
        'assets/labels/ann_labels.txt',
      );
      _labels = labelsData
          .split('\n')
          .where((label) => label.isNotEmpty)
          .toList();

      _isLoaded = true;
      print('ANN Model loaded successfully');
    } catch (e) {
      print('Error loading ANN model: $e');
      throw 'Failed to load ANN model';
    }
  }

  Future<Map<String, dynamic>> predictImage(File imageFile) async {
    if (!_isLoaded) {
      await loadModel();
    }

    try {
      // 1. Read image file and decode
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw 'Failed to decode image';
      }

      // 2. RESIZE: Changed from 224 to 28 to fix (150528 != 2352) error
      final resizedImage = img.copyResize(image, width: 28, height: 28);

      // 3. Convert image to the specific input format (Float32 list)
      var input = _imageToByteListFloat32(resizedImage, 28, 28);

      // 4. Prepare output buffer based on label count
      var output = List.filled(
        _labels.length,
        0.0,
      ).reshape([1, _labels.length]);

      // 5. Run the model
      _interpreter!.run(input, output);

      // 6. Process the results
      final predictions = output[0] as List<double>;

      // Find the best match
      double maxScore = predictions[0];
      int maxIndex = 0;
      for (int i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxScore) {
          maxScore = predictions[i];
          maxIndex = i;
        }
      }

      // Create a list of the top 3 predictions for the UI
      List<Map<String, dynamic>> allPredictions = [];
      for (int i = 0; i < predictions.length; i++) {
        allPredictions.add({
          'label': _labels[i],
          'confidence': predictions[i] * 100,
        });
      }

      // Sort by highest confidence
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
