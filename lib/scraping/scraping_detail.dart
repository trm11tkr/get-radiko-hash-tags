import 'package:flutter/material.dart';

import '../model/radiko_data.dart';

class ScrapingDetail extends StatelessWidget {
  const ScrapingDetail(
      {Key? key, required this.local, required this.programList})
      : super(key: key);

  final String local;
  final List<Program> programList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(local),
      ),
      body: ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(
          color: Colors.black,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(programList[index].programName.toString()),
            subtitle: Text('ハッシュタグ：${programList[index].hashTags.toString()}'),
          );
        },
        itemCount: programList.length,
      ),
    );
  }
}
