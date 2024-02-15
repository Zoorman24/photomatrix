import 'dart:convert';
import 'dart:io';

import 'package:photomatrix/photomatrix_repository/model_list.dart';

class ApiClient {
  final HttpClient client = HttpClient();

  Future<List<Photoname>> getName() async {
    final url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbx83K7_yKg6QA_awrqYw_v8kpGtP-1y1dtwsh6B_ObXVkCT7GJt-w-GT0kyBmA__nSM/exec');
    final request = await client.getUrl(url);
    final response = await request.close();
    final jsonStrings = await response.transform(utf8.decoder).toList();
    final jsonString = jsonStrings.join();
    final json = jsonDecode(jsonString) as List<dynamic>;
    final photo =
        json.map((dynamic e) => Photoname(name: e[0] as String)).toList();

    return photo;
  }
}
