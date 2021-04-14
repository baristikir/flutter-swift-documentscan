// import 'dart:async';
// import 'package:flutter/foundation.dart';

// import 'package:flutter/services.dart';

// /// Represetns a print job to communicate with the platform implementation
// class PrintJob {
//   /// Print Job Number
//   final int index;

//   /// Future  triggered when the job is done
//   final Completer<bool> onCompleted;

//   const PrintJob._({
//     this.index,
//     this.onCompleted,
//   });
// }

// /// Represents a list of print jobs
// class PrintJobs {
//   /// List of print jobs
//   PrintJobs();

//   static var _currentIndex = 0;

//   final _printJobs = <int, PrintJob>{};

//   /// Add print job to the list
//   PrintJob add({
//     Completer<bool> onCompleted,
//   }) {
//     final job = PrintJob._(index: _currentIndex++, onCompleted: onCompleted);
//     _printJobs[job.index] = job;
//     return job;
//   }

//   /// retrieve an existing job
//   PrintJob getJob(int index) {
//     if (_printJobs[index] != null) {
//     return _printJobs[index];
//     }
//     throw new ErrorDescription(
//         "Custom Error: Such a print job is not registered!");
//   }

//   /// remove a print job from the list
//   void remove(int index) {
//     _printJobs.remove(index);
//   }
// }

// const MethodChannel _channel =
//     MethodChannel("com.flutter.baristikir/baristikir");

// class PrinterChannel {
//   PrinterChannel() : super() {
//     _channel.setMethodCallHandler(_handleMethod);
//   }

//   static final _printJobs = PrintJobs();

//   static Future<dynamic> _handleMethod(MethodCall call) async {
//     switch (call.method) {
//       case 'onCompleted':
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
//       default:
//     }
//   }

//   // @override
//   // Future<bool> layoutPdf(String name, Printer printer, LayoutCallback onLayout,
//   //     PdfFormatPage format) async {
//   //   final job = _printJobs.add(
//   //     onCompleted: Completer<bool>(),
//   //     onLayout: onLayout,
//   //   );

//   //   final params = <String, dynamic>{
//   //     if (printer != null) 'printer': printer.url,
//   //     'name': name,
//   //     'job': job.index,
//   //     'width': format.width,
//   //     'height': format.height,
//   //     // 'dynamic': dynamicLayout,
//   //   };

//   //   await _channel.invokeMethod("PrintPDF", params);
//   //   try {
//   //     return await job.onCompleted.future;
//   //   } finally {
//   //     _printJobs.remove(job.index);
//   //   }
//   // }
// }
