import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RagService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<void> ingestFile(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/ingest'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to ingest file: ${response.statusCode}');
    }
  }

  Future<String> ask(String question, {int topK = 5}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': question,
        'top_k': topK,
        }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to ask question: ${response.statusCode}');
    }

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    return jsonResponse['answer'] as String;
  }
}

