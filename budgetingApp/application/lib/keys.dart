import 'package:http/http.dart' as http;
import 'dart:convert';

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

class PubKey {
  final String publicToken;

  const PubKey({
    required this.publicToken
  });

  factory PubKey.fromJson(Map<String, dynamic> json) {
    return PubKey(
      publicToken: json['public_token']
    );
  }
}

Future<LinkKey> fetchLinkKey() async {
  final response = await http.post(
    Uri.parse('http://localhost:9090/budget/link')
  );

  if (response.statusCode == 200) {
    return LinkKey.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to retrieve link token');
  }
}

Future<PubKey> fetchPubKey() async {
  final response = await http.post(
    Uri.parse('http://localhost:9090/budget/link')
  );

  if (response.statusCode == 200) {
    return PubKey.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to retrieve link token');
  }
}
