//
//  VisionKitProvider.swift
//  Runner
//
//  Created by Baris Tikir on 07.12.20.
//

import UIKit
import Flutter

@available(iOS 13.0, *)
public class VisionKitProvider: NSObject, FlutterPlugin {

    var scanViewController:ScanViewController?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.flutter.baristikir/baristikir", binaryMessenger: registrar.messenger())
        let instance = VisionKitProvider()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

//    public static func register(with registrar: FlutterPluginRegistrar) {
//        let channel = FlutterMethodChannel(name: "com.flutter.baristikir/baristikir", binaryMessenger: registrar.messenger())
//        let instance = VisionKitProvider()
//        registrar.addMethodCallDelegate(instance, channel: channel)
//    }



//    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        #if targetEnvironment(simulator)
//        result(FlutterError(code: "not_implemented", message: "Cannot run on Simulator", details: nil))
//        return
//        #else
//
//        // Vision Kit Document Scanner
//        scanViewController=ScanViewController()
//
//        print("before scanDocument")
//
//        scanViewController?.scanDocument{ [weak self] scanResult in
//            guard let self = self else { return }
//
//            print("before scanResults Check")
//
//            switch(scanResult){
//
//            // Successfully opened VNDocumentViewController
//            case .success(let scanResult):
//
//                // Checking State of Scans - 1.Succesfully scanned and saved & 2.Cancled out of VC
//                switch scanResult {
//
//                // Saved button pressed with scans
//                case .success(images: let images):
//                    print()
//
//                // Cancel button pressed
//                case .canceled:
//                    result(nil)
//                }
//
//            // Error occured through opening VNDocumentViewController
//            case .failure(let err):
//                result(FlutterError(code: "code", message: err.localizedDescription, details: nil))
//            }
//        }
//        #endif
//    }




}
