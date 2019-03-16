import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wshop/api/feeds.dart';
import 'package:wshop/components/FeedImage.dart';
import 'package:wshop/models/auth.dart';
import 'package:wshop/models/feeds.dart';

class UserScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserScreenState();
  }
}

class UserScreenState extends State<UserScreen> {
  static const channel = const MethodChannel('com.meizizi.doraemon/door');
  List<Feed> _items = [];
  Feeds feeds;

  Future<void> _share(List<String> pics) async {
    try {
      final int result = await channel.invokeMethod('weixin', pics);
      debugPrint(result.toString());
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    _getList();
  }

  Future<void> _getList() async {
    if (feeds != null && !feeds.hasNext) {
      return;
    }

    int cursor = feeds != null ? feeds.nextCursor : 0;

    feeds = await getTimeline(context, cursor);

    setState(() {
      _items.addAll(feeds.list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Stack(children: [
        RefreshIndicator(
            displacement: 80,
            onRefresh: () {
              setState(() {
                _items.clear();
              });
              return _getList();
            },
            child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    _getList();
                  }
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: _items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        height: 300,
                        child: Stack(children: [
                          Image.asset(
                            'assets/bg.png',
                            height: 211,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            left: 20,
                            top: 80,
                            child: ClipRRect(
                              child: Image.network(Auth().avatar,
                                  width: 64, height: 64, fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          Positioned(
                            left: 100,
                            top: 90,
                            child: Text(Auth().nickname,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .copyWith(color: Colors.white)),
                          ),
                          Positioned(
                            left: 100,
                            top: 120,
                            child: Text(Auth().nickname,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .copyWith(
                                        color: Colors.white, fontSize: 12)),
                          ),
                          Positioned(
                            left: 100,
                            top: 150,
                            child: Text('上新 20                总数 100',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .copyWith(
                                        color: Colors.white, fontSize: 12)),
                          )
                        ]),
                      );
                    }
                    index = index - 1;
                    return Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Color.fromRGBO(236, 236, 236, 1),
                                    width: 1.0))),
                        padding: EdgeInsets.only(bottom: 10, right: 20),
                        margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                        child: Stack(children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: ClipRRect(
                                    child: Image.network(
                                        _items[index].author.avatar,
                                        width: 42,
                                        height: 42,
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                Expanded(
                                    child: Column(
                                  children: <Widget>[
                                    Text(_items[index].author.nickname,
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                                fontWeight: FontWeight.w600)),
                                    Text(_items[index].content,
                                        style:
                                            Theme.of(context).textTheme.body1),
                                    FeedImage(
                                      imageList: _items[index].pics,
                                    ),
                                    Text('9分钟前',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle
                                            .copyWith(fontSize: 12)),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                )),
                              ]),
                          Positioned(
                              bottom: -17,
                              right: 70,
                              child: Row(children: [
                                CupertinoButton(
                                    child: Image.asset('assets/star.png',
                                        width: 22, height: 22),
                                    onPressed: () {
                                      _share(_items[index].pics);
                                    }),
                                Text(
                                  _items[index].star.toString(),
                                  style: Theme.of(context).textTheme.subtitle,
                                )
                              ])),
                          Positioned(
                              bottom: -17,
                              right: 0,
                              child: CupertinoButton(
                                  child: Image.asset('assets/share.png',
                                      width: 22, height: 22),
                                  onPressed: () {
                                    _share(_items[index].pics);
                                  })),
                        ]));
                  },
                ))),
        Positioned(
            left: 10,
            top: 20,
            child: Container(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Row(children: [
                Column(children: <Widget>[
                  Icon(
                    Icons.navigate_before,
                    color: Colors.white,
                    size: 40,
                  )
                ])
              ]),
            ))
      ]),
    ));
  }
}
