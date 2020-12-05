import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Prefix Domain for iOS MethodChannel
  static const platform =
      const MethodChannel("com.flutter.baristikir/baristikir");

  // States & Data Outputs
  bool _scanning = false;
  String _exception;
  List<dynamic> _documents;

  // Method for calling Scan MethodChannel
  Future<List<String>> _scanDocument() async {
    // Storing Scanned images here
    List<dynamic> images;

    try {
      // Invoke Method Channel for Swift
      images = await platform.invokeMethod("ScanDocument");
    } catch (e) {
      print(e);
      return e;
    }

    return images.map((e) => e.toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        textDirection: TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_scanning == false)
            FlatButton(
              onPressed: () async {
                setState(() {
                  _scanning = true;
                });
                try {
                  final documents = await _scanDocument();
                  setState(() async {
                    _documents = documents;
                  });
                } catch (e) {
                  setState(() {
                    _exception = e;
                  });
                  print(_exception);
                }
                setState(() {
                  _scanning = false;
                });
              },
              child: Text("Scan Documents"),
            ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     if (_scanning == false) {
      //       setState(() {
      //         _scanning = true;
      //       });
      //       _scanDocument();
      //     }
      //   },
      //   tooltip: 'Scan',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
