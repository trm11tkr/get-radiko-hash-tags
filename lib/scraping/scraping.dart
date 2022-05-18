import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_radiko_hash_tags/model/radiko_data.dart';
import 'package:get_radiko_hash_tags/scraping/scraping_detail.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class ScrapingPage extends ConsumerWidget {
  const ScrapingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radikoData = ref.watch(radikoDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(
          color: Colors.black,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(radikoData[index].localName),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScrapingDetail(
                    local: radikoData[index].localName,
                    programList: radikoData[index].programs);
              }));
            },
          );
        },
        itemCount: radikoData.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // testFunc();
          ref.watch(radikoDataProvider.notifier).scraping();
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}

Future<void> testFunc() async {
  String path =
      '#content > div.content.content__main > div > div.content__rwd.rwd.channel-detail > div > div > div.program-table__body.program-table__body--col7 > div.program-table__outer > div.program-table__items > div:nth-child(1)';
  final String url = 'https://radiko.jp/index/HBC/';
  final target = Uri.parse(url);
  final response = await http.get(target);
  final String responseBody = utf8.decode(response.bodyBytes);
  if (response.statusCode != 200) {
    Exception(response.statusCode.toString());
  }
  final document = parse(responseBody);
  final String result = document.querySelector(path)?.innerHtml ?? '情報なし';

  String titlePath = '#cboxLoadedContent > p.colorbox__title.text-left';
  final reg = RegExp(r'(?<=twitterハッシュタグは).+?(?=」)'); // 地名

  final lis = reg.allMatches(result).map((e) => e.group(0).toString()).toList();
  log(lis.toString());
}
