import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String apiKey = "AIzaSyDaXqP9_tlueUCiuVTZYKDWO25q4E3hpPE";
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey';

  static Future<String> generateContent(String text) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Our app name is AI-Enabled Restaurant Control and Optimization. Answer only questions related to restaurant food, menu, dishes, cuisine, drinks, or any other restaurant-related topics. If the question is not related to the restaurant, respond with 'Sorry, I cannot do that.\nThis question is out of policy to our app.' Question: $text"
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log("Data is---->>>> $data");

      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'] as Map<String, dynamic>?;
        if (content != null) {
          final parts = content['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null) {
              final filteredText = text.replaceAll(RegExp(r'\*\*|#'), '');
              return '$filteredText\n\nPowered by AI-Enabled Restaurant Control and Optimization';
            }
          }
        }
      }

      // Handle case where the expected structure is not found
      throw Exception('Invalid response structure');
    } else {
      throw Exception('Failed to generate content');
    }
  }
}
