import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wshop/api/feeds.dart';
import 'package:wshop/components/FeedImage.dart';
import 'package:wshop/models/auth.dart';
import 'package:wshop/models/feeds.dart';
import 'package:wshop/screens/editor.dart';

class TimelineTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TimelineTabState();
  }
}

class TimelineTabState extends State<TimelineTab> {
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
    return Container(
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
                  itemCount: _items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        height: 300,
                        child: Stack(children: [
                          Image.asset('assets/bg.png'),
                          Positioned(
                            bottom: 55,
                            right: 10,
                            child: ClipRRect(
                              child: Image.network(
                                  'https://ws2.sinaimg.cn/large/006tNc79gy1fyt6bakq3mj30rs15ojvs.jpg',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          Positioned(
                            bottom: 70,
                            right: 100,
                            child: Text(Auth().nickname,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .copyWith(color: Colors.white)),
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
          child: CupertinoNavigationBar(
              middle: Text('动态'),
              trailing: CupertinoButton(
                child: Icon(Icons.photo_camera),
                padding: EdgeInsets.only(bottom: 0),
                onPressed: () async {
                  String result = await Navigator.of(context).push(
                      CupertinoPageRoute(
                          fullscreenDialog: true,
                          title: '新建',
                          builder: (BuildContext context) => Editor()));

                  if (result == 'save') {
                    _getList();
                  }
                },
              )),
        )
      ]),
    );
  }
}
