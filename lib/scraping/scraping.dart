import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_radiko_hash_tags/model/radiko_data.dart';
import 'package:get_radiko_hash_tags/scraping/scraping_detail.dart';

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
          ref.watch(radikoDataProvider.notifier).scraping();
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}