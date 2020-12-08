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
                if let data = singleImage.pngData(), let tempFileURL = tempDirUrl.appendingPathComponent("dokument_\(uuid).png")
                {
                    do{
                        try data.write(to: tempFileURL)
                        imagePaths.append(tempFileURL.absoluteString)
                    } catch let error {
                        print(error.localizedDescription)
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
