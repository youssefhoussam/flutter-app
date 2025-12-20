import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile', // Fast and powerful model
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful AI assistant for Synthesia AI app. '
                  'You help users understand and work with 4 AI models: '
                  '1. ANN (Artificial Neural Network) for pattern recognition, '
                  '2. CNN (Convolutional Neural Network) for image processing, '
                  '3. Stock Prediction model for market forecasting, '
                  '4. RAG (Retrieval-Augmented Generation) for context-aware AI. '
                  'Keep responses concise, helpful, and friendly. '
                  'Maximum 3-4 sentences per response.',
            },
            {'role': 'user', 'content': message},
          ],
          'temperature': 0.7,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else if (response.statusCode == 401) {
        throw 'Invalid API key. Please check your Groq API key.';
      } else if (response.statusCode == 429) {
        throw 'Rate limit exceeded. Please try again in a moment.';
      } else {
        throw 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      if (e.toString().contains('Invalid API key')) {
        rethrow;
      } else if (e.toString().contains('Rate limit')) {
        rethrow;
      } else {
        throw 'Failed to get AI response: $e';
      }
    }
  }

  // Get a suggested response based on context
  Future<String> getQuickResponse(String quickCommand) async {
    final responses = {
      'Tell me about ANN':
          'ANN (Artificial Neural Network) is a computational model '
          'inspired by the human brain. It learns patterns from data through interconnected '
          'nodes (neurons) and is excellent for classification and regression tasks.',

      'How does CNN work?':
          'CNN (Convolutional Neural Network) is specialized for '
          'processing grid-like data, especially images. It uses convolutional layers to '
          'automatically detect features like edges, shapes, and patterns.',

      'Predict stocks':
          'Our Stock Prediction model uses historical market data, '
          'technical indicators, and machine learning algorithms to forecast price movements. '
          'It analyzes trends, volume, and patterns to make informed predictions.',

      'What is RAG?':
          'RAG (Retrieval-Augmented Generation) combines information retrieval '
          'with text generation. It searches relevant documents and uses that context to '
          'provide accurate, up-to-date responses instead of relying only on training data.',
    };

    return responses[quickCommand] ?? await sendMessage(quickCommand);
  }
}
