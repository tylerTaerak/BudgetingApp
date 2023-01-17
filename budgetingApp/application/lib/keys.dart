import 'package:http/http.dart' as http;
import 'dart:convert';

/// class to contain link tokens
class LinkKey {
  final String linkToken;

  const LinkKey({
    required this.linkToken
  });

  factory LinkKey.fromJson(Map<String, dynamic> json) {
    return LinkKey(
      linkToken: json['link_token']
    );
  }
}

/// retrieve link key to activate Link
Future<LinkKey> fetchLinkKey() async {
  final response = await http.get(
    Uri.parse('http://localhost:9090/budget/link')
  );

  if (response.statusCode == 200) {
    return LinkKey.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to retrieve link token');
  }
}

/// exchange public token (from Link) for an access key
Future<void> exchangePubKey(String public) async {
  final response = await http.post(
    Uri.parse('http://localhost:9090/budget/exchange_tokens'),
    headers: <String, String> {
        'Content-Type': 'application/json; charset=UTF-8'
    },
    body: jsonEncode(<String, String>{
        'public_token': public
    })
  );

  if (response.statusCode == 200) {
    // do nothing
  } else {
    throw Exception('Failed to properly exchange link token');
  }
}
