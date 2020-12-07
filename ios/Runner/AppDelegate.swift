import UIKit
import VisionKit
import Flutter

@available(iOS 13.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
//    // Method Call -> Opening Document Scanner View `VNDocumentCameraViewController
//    channel.setMethodCallHandler {(methodCall, result) in
//        if methodCall.method == "ScanDocument"
//        {
//            #if targetEnvironment(simulator)
//                result(FlutterError(code: "not_implemented", message: "Cannot run on Simulator", details: nil))
//                return
//            #else
//
//            #endif
//        }
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
//        
    //}
    

    
    GeneratedPluginRegistrant.register(with: self)
    
    var scanViewController:ScanViewController?

    // Flutter View Controller
    guard let controller = window?.rootViewController as? FlutterViewController else {
        fatalError("Der rootViewController ist kein Typ von FlutterViewController");
    }
    
    // Method Channel To Flutter Application with Flutter specified domain prefix
    let channel = FlutterMethodChannel(name: "com.flutter.baristikir/baristikir", binaryMessenger: controller as! FlutterBinaryMessenger);
    
    
    channel.setMethodCallHandler({
       (call: FlutterMethodCall, result: @escaping FlutterResult) in
        
        guard call.method == "ScanDocument" else {
            result(FlutterMethodNotImplemented)
            return
        }
        
        // Vision Kit Document Scanner
        if #available(iOS 13.0, *) {
            scanViewController = ScanViewController()
            
            print("Inside Method channel & before Scan Document Process")
            
            scanViewController?.scanDocument{ [weak self] scanResult in
                
                guard let strongSelf = self else {return}
                
                print("before Scan Results Check")
                
                switch(scanResult){
                
                // Successfully opened VNDocumentViewController
                case .success(let scanResult):
                    
                    // Checking State of Scans - 1.Succesfully scanned and saved & 2.Cancled out of VC
                    switch scanResult {
                    
                    // Saved button pressed with scans
                    case .success(images: let images):
                        strongSelf.savedImages(images: images, result: result)
                    
                    // Cancel button pressed
                    case .canceled:
                        result(nil)
                    
                    default:
                        fatalError(FlutterMethodNotImplemented as! String)
                    }
                    
                // Error occured through opening VNDocumentViewController
                case .failure(let error):
                    result(FlutterError(code: "code", message: error.localizedDescription, details: nil))
                }
            }
        } else {
            // Fallback on earlier versions
            result(FlutterError(code: "code", message: "Scan war nicht erfolgrein", details: nil))
        }
        
        
    })
    
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func savedImages(images:[UIImage], result: @escaping FlutterResult)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let tempDirUrl = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            
            var imagePaths:[String] = []
            for singleImage in images {
                let uuid = UUID().uuidString
                if let data = singleImage.pngData(), let tempFileURL = tempDirUrl.appendingPathComponent("scaned_\(uuid).png")
                {
                    do{
                        try data.write(to: tempFileURL)
                        imagePaths.append(tempFileURL.absoluteString)
                    } catch let error {
                        result(FlutterError(code: "create_file_error", message: error.localizedDescription, details: nil))
                    }
                }
            }
            DispatchQueue.main.async {
                result(imagePaths)
            }
            result(imagePaths)
        }
    }}
