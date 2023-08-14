// lib/services/chatgpt_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGPTService {
  static const endpoint =
      'https://api.openai.com/v1/engines/davinci/completions';
  final String apiKey;

  ChatGPTService(this.apiKey);

  Future<String> getAdvice(String text) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'prompt': 'カウンセラー風にアドバイス: $text',
        'max_tokens': 50,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['choices'][0]['text'].trim();
    } else {
      throw Exception('Failed to get advice from ChatGPT');
    }
  }
}
