import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_radiko_hash_tags/scraping/scraping_detail.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import 'get_hash_tags.dart';

typedef HashTags = Map<String, List<List<String>>>;

class ScrapingPage extends StatefulWidget {
  ScrapingPage({Key? key}) : super(key: key);

  bool isLoading = false;

  @override
  State<ScrapingPage> createState() => _ScrapingPageState();
}

class _ScrapingPageState extends State<ScrapingPage> {
  HashTags programList = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('radiko page'),
      ),
      body: widget.isLoading
        ? const Center(child: CircularProgressIndicator())


      : ListView.builder(
        itemBuilder: (context, index) {
          String key = programList.keys.elementAt(index);
          return ListTile(
            title: Text(key),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScrapingDetail(local: key, programList: programList[key]!);
              }));
            }
          );
        },
        itemCount: programList.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            widget.isLoading = !widget.isLoading;
          });
          final newpProgramList = await scraping();
          setState(() {
            widget.isLoading = !widget.isLoading;
            programList = newpProgramList;
          });
          print('finish');
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}

Future<HashTags> scraping() async {
  print('scraping start');
  const String url = 'https://radiko.jp/index/';
  final target = Uri.parse(url);
  final response = await http.get(target);
  final String responseBody = utf8.decode(response.bodyBytes);
  if (response.statusCode != 200) {
    Exception(response.statusCode.toString());
  }
  final document = parse(responseBody);
  HashTags hashTagsList =  await normalization(document);
  return hashTagsList;
}

Future<HashTags> normalization(document) async {
  print('normalization start');
  final HashTags hashTags = {};
  for (int i = 1; i < 3; i += 2) {
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

    hashTags[localTitle] = [];
    for (int j = 0; j < url.length; j++) {
      final List<String> hashTagsList = await getHashTags(url[j]);
      hashTags[localTitle]?.addAll([
        [programTitle[j]] + hashTagsList
      ]);
    }
  }
  return hashTags;
}
