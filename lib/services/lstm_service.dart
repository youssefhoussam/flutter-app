import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class LSTMService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/lstm_model.tflite',
      );

      final labelsData = await rootBundle.loadString(
        'assets/labels/lstm_labels.txt',
      );
      _labels = labelsData
          .split('\n')
          .where((label) => label.isNotEmpty)
          .toList();

      _isLoaded = true;
      print('LSTM Model loaded successfully');
    } catch (e) {
      print('Error loading LSTM model: $e');
      throw 'Failed to load LSTM model';
    }
  }

  // Predict stock trend from historical data
  // Input: List of stock prices (e.g., last 30 days)
  Future<Map<String, dynamic>> predictStockTrend(
    List<double> stockPrices,
  ) async {
    if (!_isLoaded) {
      await loadModel();
    }

    try {
      // Normalize stock prices (you may need to adjust this based on your model)
      List<double> normalizedPrices = _normalizeData(stockPrices);

      // Prepare input based on your LSTM model's expected shape
      // Common shape: [1, sequence_length, 1] or [1, sequence_length, features]
      var input = [
        normalizedPrices.map((price) => [price]).toList(),
      ];

      // Prepare output buffer
      var output = List.filled(
        _labels.length,
        0.0,
      ).reshape([1, _labels.length]);

      // Run inference
      _interpreter!.run(input, output);

      final predictions = output[0] as List<double>;

      // Find the highest probability
      double maxScore = predictions[0];
      int maxIndex = 0;
      for (int i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxScore) {
          maxScore = predictions[i];
          maxIndex = i;
        }
      }

      // Create prediction result
      Map<String, double> allPredictions = {};
      for (int i = 0; i < predictions.length; i++) {
        allPredictions[_labels[i]] = predictions[i] * 100;
      }

      return {
        'prediction': _labels[maxIndex],
        'confidence': maxScore * 100,
        'allPredictions': allPredictions,
        'recommendations': _getRecommendation(
          _labels[maxIndex],
          maxScore * 100,
        ),
      };
    } catch (e) {
      print('Error during prediction: $e');
      throw 'Prediction failed: $e';
    }
  }

  // Normalize data to range [0, 1]
  List<double> _normalizeData(List<double> data) {
    if (data.isEmpty) return [];

    double min = data.reduce((a, b) => a < b ? a : b);
    double max = data.reduce((a, b) => a > b ? a : b);

    if (max == min) return List.filled(data.length, 0.5);

    return data.map((value) => (value - min) / (max - min)).toList();
  }

  String _getRecommendation(String prediction, double confidence) {
    if (prediction == 'Buy') {
      if (confidence > 80) {
        return 'Strong buy signal. Market shows positive momentum.';
      } else if (confidence > 60) {
        return 'Moderate buy signal. Consider entering position.';
      } else {
        return 'Weak buy signal. Monitor closely before acting.';
      }
    } else if (prediction == 'Sell') {
      if (confidence > 80) {
        return 'Strong sell signal. Consider taking profits.';
      } else if (confidence > 60) {
        return 'Moderate sell signal. Review your position.';
      } else {
        return 'Weak sell signal. Keep monitoring.';
      }
    } else {
      // Hold
      return 'Market is stable. Maintain current position and monitor trends.';
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
