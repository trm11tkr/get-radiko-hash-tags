import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

final radikoDataProvider =
    StateNotifierProvider<RadikoData, List<LocalStation>>((ref) {
  return RadikoData();
});

class LocalStation {
  const LocalStation({required this.localName, required this.programs});

  final String localName;
  final List<Program> programs;
}

class Program {
  Program(
      {required this.programName, required this.url, required this.hashTags});

  final String programName;
  final String url;
  late List<String> hashTags;
}

class RadikoData extends StateNotifier<List<LocalStation>> {
  RadikoData() : super([]);

  Future<void> scraping() async {
    const String url = 'https://radiko.jp/index/';
    final target = Uri.parse(url);
    final response = await http.get(target);
    final String responseBody = utf8.decode(response.bodyBytes);
    if (response.statusCode != 200) {
      Exception(response.statusCode.toString());
    }
    final document = parse(responseBody);
    List<LocalStation> radikoData = await extraction(document);
    state = radikoData;
  }

  Future<List<LocalStation>> extraction(document) async {
    List<LocalStation> localStations = [];
    for (int i = 1; i <= 15; i += 2) {
      final String result = document
              .querySelector(
                  '#content > div.content.content__main > div > div > div:nth-child($i)')
              ?.innerHtml ??
          '情報なし';
      final regLocal = RegExp(r'(?<=>).+?(?=<)'); // 地名
      final regURL = RegExp(r'(?<=href=").+?(?=">)'); // URL
      final regProgram = RegExp(r'(?<=">).+?(?=</a)'); // 番組名

      final String localTitle =
          (regLocal.firstMatch(result)?.group(0)).toString();

      final List<String> url =
          regURL.allMatches(result).map((e) => e.group(0).toString()).toList();

      final List<String> programTitle = regProgram
          .allMatches(result)
          .map((e) => e.group(0).toString())
          .toList();

      LocalStation localStation =
          LocalStation(localName: localTitle, programs: []);
      for (int j = 0; j < url.length; j++) {
        List<String> hashTag = await getHashTags(url[j]);
        localStation.programs.add(Program(
            programName: programTitle[j], url: url[j], hashTags: hashTag));
      }
      localStations.add(localStation);
      log('$localTitle done');
    }
    return localStations;
  }

  Future<List<String>> getHashTags(String programUrl) async {
    final String url = 'https://radiko.jp$programUrl';
    final target = Uri.parse(url);
    final response = await http.get(target);
    final String responseBody = utf8.decode(response.bodyBytes);
    if (response.statusCode != 200) {
      Exception(response.statusCode.toString());
    }
    final document = parse(responseBody);
    String result = document
            .querySelector(
                '#content > div.content.content__main > div > div.content__rwd.rwd.channel-detail > div > div > div.program-table__body.program-table__body--col7 > div.program-table__outer > div.program-table__items > div:nth-child(1)')
            ?.text ??
        "情報なし";

    final regHashTags = RegExp(r'(?<=「#).+?(?=」)'); // HBC

    final List<String> hashTags = regHashTags
        .allMatches(result)
        .map((e) => e.group(0).toString())
        .toSet()
        .toList();

    return hashTags;
  }
}
