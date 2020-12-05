import UIKit
import VisionKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, VNDocumentCameraViewControllerDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Flutter View Controller
    let controller:FlutterViewController = window?.rootViewController as! FlutterViewController
    // Method Channel To Flutter Application with Flutter specified domain prefix `com.flutter.baristikir/baristikir`
    let channel = FlutterMethodChannel(name: "com.flutter.baristikir/baristikir", binaryMessenger: controller as! FlutterBinaryMessenger);

    // Method Call -> Opening Document Scanner View `VNDocumentCameraViewController
    channel.setMethodCallHandler {(methodCall, result) in
        if methodCall.method == "ScanDocument"
        {
            if #available(iOS 13.0, *) {
                self.window?.rootViewController = ScanViewController()
                
            } else {
                // Fallback on earlier versions
                print("Update iOS")
            }
        }
//        if methodCall.method == "PrintFromiOS"
//        {
//            if #available(iOS 13.0, *) {
//                guard VNDocumentCameraViewController.isSupported else { print("Document scanning not supported"); return }
//                var scannerViewController: VNDocumentCameraViewController?
//                scannerViewController = VNDocumentCameraViewController()
//                scannerViewController?.delegate = self
//
//                self.window.rootViewController = scannerViewController
//
//                func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
//
//                    controller.dismiss(animated: true)
//                    self.window.rootViewController = controller
//
//                    print("Finished scanning document \"\(String(describing: scan.title))\"")
//                    print("Found \(scan.pageCount)")
//
//                    let firstImage = scan.imageOfPage(at: 0)
//                }
//
//                func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
//                    // You are responsible for dismissing the controller.
//                    controller.dismiss(animated: true)
//                    self.window.rootViewController = controller
//                    result("Keine Aufnahmen")
//                }
//
//                func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
//                    // You should handle errors appropriately in your app.
//                    print(error)
//                    result(error)
//
//                    // You are responsible for dismissing the controller.
//                    controller.dismiss(animated: true)
//                }
//
//            } else {
//                // Fallback on earlier versions
//                result("mindestens iOS 13 beenötigt")
//            }
//        }
    }
    

    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
