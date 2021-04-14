// import 'dart:developer';

// import 'package:doc_scanner/printer_service.dart';
// import 'package:flutter/services.dart';

// // Method Channel Name
// const MethodChannel _channel =
//     MethodChannel("com.flutter.baristikir/baristikir");

// class MethodChannelService {
//   MethodChannelService() : super() {
//     _channel.setMethodCallHandler(_handleMethod);
//   }

//   static final _printJobs = PrintJobs();

//   static Future<dynamic> _handleMethod(MethodCall call) async {
//     switch (call.method) {
//       case 'printCompleted':
//         final bool completed = call.arguments['completed'];
//         final String error = call.arguments['error'];
//         final job = _printJobs.getJob(call.arguments['job']);

//         if (job != null) {
//           if (completed == false && error != null) {
//             job.onCompleted.completeError(error);
//           } else {
//             job.onCompleted.complete(completed);
//           }
//         }
//         break;
//       case "faceTimeCompleted":
//         final bool completed = call.arguments["completed"];
//         final String error = call.arguments["error"];

//         if (completed && error != null) {
//           print(error);
//         }
//         break;
//       case "keychainCompleted":
//         final bool completed = call.arguments["completed"];
//         final String error = call.arguments["error"];

//         if (error != null && completed) {
//           print(error);
//         }
//         break;
//       default:
//     }
//   }
// }
