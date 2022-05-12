import 'package:flutter/material.dart';

class ScrapingDetail extends StatelessWidget {
  const ScrapingDetail(
      {Key? key, required this.local, required this.programList})
      : super(key: key);

  final String local;
  final List<List<String>> programList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(local),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(programList[index].toString()),
          );
        },
        itemCount: programList.length,
      ),
    );
  }
}
