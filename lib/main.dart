import 'dart:convert';
import 'dart:io';

import 'package:doc_scanner/keychain_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const User = {"email": "baris.tikir@surgi-data.com"};

class _MyHomePageState extends State<MyHomePage> {
  // Prefix Domain for iOS MethodChannel
  final platform = const MethodChannel("com.flutter.baristikir/baristikir");
  final _storage = SecureKeychainService();
  final String? _accountName = User["email"];

  // States & Data Outputs
  bool _scanning = false;
  String? _exception;
  List<String>? _documentPaths;

  // Method for calling Scan MethodChannel
  Future<List<String>> _scanDocument() async {
    // Storing Scanned images here
    List<dynamic> images;

    // Invoke Method Channel for Swift
    images = await platform.invokeMethod("SDScanDocument");

    return images.map((e) => e.toString()).toList();
  }

  Future<File> _downloadFile(String url, String filename) async {
    http.Client _client = new http.Client();
    var req = await _client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Prints a sample pdf printer
  void printPdfFile() async {
    var file =
        await _downloadFile("https://www.jena.de/fm/41/test.pdf", "test.pdf");

    print(file);
    print("File Path: " + file.path);
    await _printFile(file.path);
  }

  Future<void> _printFile(String filePath) async {
    if (filePath == null || filePath.isEmpty) {
      throw FormatException("filePath given is null or empty");
    }
    var file = File(filePath);
    var bytes = await file.readAsBytes();
    var b64Bytes = base64Encode(bytes);
    await _printDocument(b64Bytes, filePath);
  }

  Future<void> _printDocument(String b64Bytes, String filePath) async {
    print("Calling PrintPDF Method Channel");
    var e = await platform.invokeMethod("SDPrintPDF", {"bytes": b64Bytes});
    print(e);

    print("DONE");
  }

  void _addToKeychain(String key, String value) async {
    await _storage.write(key: key, value: value, iosOptions: _getIOSOptions());
  }
  void _readFromKeychain(String key) async {
    await _storage.read(key: key, iosOptions: _getIOSOptions());
  }
  void _removeFromKeychain(String key) async {
    await _storage.delete(key: key, iosOptions: _getIOSOptions());
  }

  IOSOptions _getIOSOptions() => IOSOptions(
        accountName: _getAccountName(),
      );
  String? _getAccountName() => _accountName!.isEmpty ? null : _accountName;

  // Future<void> _setToSecureKeychain(
  //     String action, String accountName, String key, String value) async {
  //   try {
  //     var keychainArgs = <String, dynamic>{
  //       "action": action,
  //       "key": key,
  //       "value": value,
  //       // "accountName": accountName
  //     };
  //     print("Calling SecureKeychain Method Channel");
  //     var tmp = await platform.invokeMethod("SDSecureKeychain", keychainArgs);
  //     print(tmp);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Future<void> _getFromSecureKeyChain(String action, String key) async {
  //   try {
  //     var keychainArgs = <String, dynamic>{
  //       "action": action,
  //       "key": key,
  //     };
  //     print("Calling SecureKeychain Method Channel");
  //     var tmp = await platform.invokeMethod("SDSecureKeychain", keychainArgs);
  //     print(tmp);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

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
          if (_scanning == false)
            Center(
                child: Container(
              child: Column(children: [
                MaterialButton(
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
                      });

                      print("********Flutter Documents********");
                      print(_documentPaths);
                      print("*********************************");
                    } catch (e) {
                      setState(() {
                        _exception = e.toString();
                      });
                      print(_exception);
                    }
                    setState(() {
                      _scanning = false;
                    });
                  },
                  child: Text("Scan Documents"),
                ),
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.black,
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                  onPressed: () async {
                    setState(() {
                      _scanning = true;
                    });
                    try {
                      print("Printing Documents");
                      printPdfFile();
                      print("Printing Documents Finished");
                    } catch (e) {
                      setState(() {
                        _exception = e.toString();
                      });
                      print(_exception);
                    }
                    setState(() {
                      _scanning = false;
                    });
                  },
                  child: Text("Print Document"),
                ),
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.black,
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                  onPressed: () async {
                    setState(() {
                      _scanning = true;
                    });
                    try {
                      print("Setting Value to KeyChain");
                      _addToKeychain("testKey", "testValueNew");
                      print("Keychain Channel Finished");
                    } catch (e) {
                      setState(() {
                        _exception = e.toString();
                      });
                      print(_exception);
                    }
                    setState(() {
                      _scanning = false;
                    });
                  },
                  child: Text("Set Value to keychain"),
                ),
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.black,
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                  onPressed: () async {
                    setState(() {
                      _scanning = true;
                    });
                    try {
                      print("Get Value from KeyChain");
                      _readFromKeychain("testKey");
                      print("Keychain Channel Finished");
                    } catch (e) {
                      setState(() {
                        _exception = e.toString();
                      });
                      print(_exception);
                    }
                    setState(() {
                      _scanning = false;
                    });
                  },
                  child: Text("Get Value to keychain"),
                ),
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.black,
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                  onPressed: () async {
                    setState(() {
                      _scanning = true;
                    });
                    try {
                      print("Remove Value from KeyChain");
                      _removeFromKeychain("testKey");
                      print("Keychain Channel Finished");
                    } catch (e) {
                      setState(() {
                        _exception = e.toString();
                      });
                      print(_exception);
                    }
                    setState(() {
                      _scanning = false;
                    });
                  },
                  child: Text("Remove Value from keychain"),
                ),
              ]),
            )),
          // if (_documentPaths != null)
          //   for (var i = 0; i < _documentPaths.length; i++)
          //     new Image.file(
          //         File(_documentPaths[i].replaceFirst('file://', '')))
        ],
      ),
    );
  }
}
