import 'dart:convert';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Future<List<String>> getHashTags(String programUrl) async {
  final String url = 'https://radiko.jp$programUrl';
  final target = Uri.parse(url);
  final response = await http.get(target);
  final String responseBody = utf8.decode(response.bodyBytes);
  if (response.statusCode != 200) {
    Exception(response.statusCode.toString());
  }
  final document = parse(responseBody);
  final String result = document
          .querySelector(
              '#content > div.content.content__main > div > div.content__rwd.rwd.channel-detail > div > div > div.program-table__body.program-table__body--col7 > div.program-table__outer > div.program-table__items > div:nth-child(1)')
          ?.innerHtml ??
      '情報なし';

  final regHashTags1 = RegExp(r'(?<=「#).+?(?=」</a>)'); // HBC

  final List<String> hashTags1 =
      regHashTags1.allMatches(result).map((e) => e.group(0).toString()).toSet().toList();

  return hashTags1;
}
