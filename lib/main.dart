import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FluttApp Dictionary",
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String url = "https://owlbot.info/api/v4/dictionary/";
  String token = "b87cd647d24e598f99ae7b8da96024939f51cc64";

  TextEditingController textEditingController = TextEditingController();

  StreamController streamController;
  Stream stream;

  Timer _timer;

  searchText() async {
    if (textEditingController.text == null ||
        textEditingController.text.length == 0) {
      streamController.add(null);
      return;
    }
    streamController.add("waiting");
    http.Response response = await http.get(
        url + textEditingController.text.trim(),
        headers: {"Authorization": "Token " + token});
    print(response.body);
    streamController.add(jsonDecode(response.body));
  }

  @override
  void initState() {
    super.initState();
    streamController = StreamController();
    stream = streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FluttApp Dictionary",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextFormField(
                    controller: textEditingController,
                    onChanged: (text) {
                      if (_timer?.isActive ?? false) _timer.cancel();
                      _timer = Timer(Duration(milliseconds: 1000), () {
                        searchText();
                      });
                    },
                    decoration: InputDecoration(
                        hintText: "search for a word",
                        contentPadding: EdgeInsets.only(left: 24),
                        border: InputBorder.none),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  searchText();
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: StreamBuilder(
          builder: (_, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text("Enter a search word"),
              );
            }
            if (snapshot.data == "waiting") {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (_, index) {
                return ListBody(
                  children: [
                    Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        leading: snapshot.data['definitions'][index]
                                    ['image_url'] ==
                                null
                            ? null
                            : CircleAvatar(
                                backgroundImage: NetworkImage(snapshot
                                    .data['definitions'][index]['image_url']),
                              ),
                        title: Text(textEditingController.text.trim() +
                            "(${snapshot.data['definitions'][index]['type']})"),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          snapshot.data['definitions'][index]['definition']),
                    ),
                  ],
                );
              },
            );
          },
          stream: stream,
        ),
      ),
    );
  }
}
