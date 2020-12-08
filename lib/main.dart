import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;

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
      title: 'Flutter - VisionKit Document Scanner',
      theme: ThemeData(
        primaryColor: Colors.black,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter - VisionKit Document Scanner'),
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
  final platform = const MethodChannel("com.flutter.baristikir/baristikir");

  // States & Data Outputs
  bool _scanning = false;
  bool _documentsScanned = false;
  String _exception;
  List<String> _documentPaths;

  // Method for calling Scan MethodChannel
  Future<List<String>> _scanDocument() async {
    // Storing Scanned images here
    List<dynamic> images;

    // Invoke Method Channel for Swift
    print("Before Swift Method Channel");

    dev.log('message',
        name: '_document', error: {"data": "Error document data"});

    images = await platform.invokeMethod("ScanDocument");

    dev.log('message', name: 'images', error: {"data": "Image Exception"});

    print(images.length);
    print(images);

    return images.map((e) => e.toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        textDirection: TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_scanning == false && _documentsScanned == false)
            Center(
                child: Container(
              child: MaterialButton(
                textColor: Colors.white,
                color: Colors.black,
                padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                onPressed: () async {
                  setState(() {
                    _scanning = true;
                  });
                  try {
                    final documents = await _scanDocument();
                    print("*******Swift Documents*******");
                    print(documents);
                    print("*****************************");
                    setState(() {
                      _documentPaths = documents;
                      _documentsScanned = true;
                    });
                    print("********Flutter Documents********");
                    print(_documentPaths);
                    print("*********************************");
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
            )),
          if (_documentPaths != null)
            for (var i = 0; i < _documentPaths.length; i++)
              new Image.file(
                  File(_documentPaths[i].replaceFirst('file://', '')))
        ],
      ),
    );
  }
}
