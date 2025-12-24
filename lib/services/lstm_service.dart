import 'dart:convert';
import 'package:http/http.dart' as http;

class LSTMService {
  // CHANGE THIS if needed (emulator vs real device)
  static const String _baseUrl = 'http://10.0.2.2:8000';
  // For real device on same network:
  // http://YOUR_PC_IP:8000

  bool _isLoaded = false;

  Future<void> loadModel() async {
    // No local model to load anymore
    _isLoaded = true;
  }

  Future<Map<String, dynamic>> predictStockTrend(List<double> prices) async {
    if (!_isLoaded) {
      await loadModel();
    }

    if (prices.length < 60) {
      throw 'Please provide at least 60 price values';
    }

    // Use the LAST 60 values
    final List<double> sequence = prices.sublist(prices.length - 60);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sequence': sequence}),
      );

      if (response.statusCode != 200) {
        throw 'Server error (${response.statusCode})';
      }

      final data = jsonDecode(response.body);
      final double predictedValue = data['prediction'];

      final double lastValue = prices.last;

      // Map regression output → trend
      final _TrendResult trend = _mapPrediction(predictedValue, lastValue);

      return {
        'prediction': trend.label,
        'confidence': trend.confidence,
        'allPredictions': trend.breakdown,
        'predictedValue': predictedValue,
        'lastValue': lastValue,
        'recommendations': _getRecommendation(trend.label, trend.confidence),
      };
    } catch (e) {
      throw 'Prediction failed: $e';
    }
  }

  // ---------- BUSINESS LOGIC (UI-FRIENDLY) ----------

  _TrendResult _mapPrediction(double predicted, double last) {
    final double diffPercent = ((predicted - last) / last) * 100;

    String label;
    double confidence;

    if (diffPercent > 1.0) {
      label = 'Buy';
      confidence = (diffPercent.abs() * 10).clamp(60, 95);
    } else if (diffPercent < -1.0) {
      label = 'Sell';
      confidence = (diffPercent.abs() * 10).clamp(60, 95);
    } else {
      label = 'Hold';
      confidence = 60;
    }

    return _TrendResult(
      label: label,
      confidence: confidence,
      breakdown: {
        'Buy': label == 'Buy' ? confidence : 100 - confidence,
        'Sell': label == 'Sell' ? confidence : 100 - confidence,
        'Hold': label == 'Hold' ? confidence : 100 - confidence,
      },
    );
  }

  String _getRecommendation(String prediction, double confidence) {
    if (prediction == 'Buy') {
      return confidence > 80
          ? 'Strong upward trend detected. Consider buying.'
          : 'Moderate upward trend. Monitor closely.';
    } else if (prediction == 'Sell') {
      return confidence > 80
          ? 'Strong downward trend detected. Consider selling.'
          : 'Moderate downward trend. Review your position.';
    } else {
      return 'Market appears stable. Holding is recommended.';
    }
  }

  void dispose() {
    // Nothing to dispose anymore
  }
}

// ---------- INTERNAL HELPER CLASS ----------

class _TrendResult {
  final String label;
  final double confidence;
  final Map<String, double> breakdown;

  _TrendResult({
    required this.label,
    required this.confidence,
    required this.breakdown,
  });
}
