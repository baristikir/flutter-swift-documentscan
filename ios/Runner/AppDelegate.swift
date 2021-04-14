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
        
        guard call.method == MethodChannelOptions.SDScanDocument.rawValue || call.method == MethodChannelOptions.SDPrintPDF.rawValue || call.method == MethodChannelOptions.SDSecureKeychain.rawValue else {
            result(FlutterMethodNotImplemented)
            return
        }
        
        print("Swift Native Code reached")
//        public var jobs = [Int32: PdfPrintController()]
        
        if call.method == MethodChannelOptions.SDScanDocument.rawValue {
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
        } else if call.method == MethodChannelOptions.SDPrintPDF.rawValue {
            print("Printing PDF")
            
            let args = call.arguments! as! [String: Any]
            
            let b64Bytes = args["bytes"] as? String ?? ""
            print("Base 64 Bytes from Args:", b64Bytes)
            let pdfFile = Data(base64Encoded: b64Bytes, options: .ignoreUnknownCharacters)
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.jobName = "Print Form"
            printInfo.outputType = .photo
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            printController.showsNumberOfCopies = true
            printController.printingItem = pdfFile
            // UIPrintInteractionController presents a user interfacee and manages the printing
            printController.present(animated: true, completionHandler: nil)
            
//            let args = call.arguments! as! [String: Any]
//
//            let name = args["name"] as! String
//            let printer = args["printer"] as! String
//            let width = CGFloat((args["width"] as! NSNumber).floatValue)
//            let height = CGFloat((args["height"] as! NSNumber).floatValue)
//            let printJob = PdfPrintController(index: args["job"] as! Int)
//
//            jobs[args["job"] as! UInt32] = printJob

            
        } else if call.method == MethodChannelOptions.SDSecureKeychain.rawValue {
            print("Custom Keychain")
            
            // Initializing Custom Secure Keychain Wrapper Instance
            
            // Extracting Flutter Arguments
            let args = call.arguments! as! [String: Any]
            // Destructing Arguments
            let key = args["key"] as? String ?? ""
            let value = args["value"] as? String ?? ""
            let action = args["action"] as? String ?? ""
            let options = args["options"] as? NSDictionary ?? nil
            
            
            if action.isEmpty {
                result(FlutterError(code: "actionFatal", message: "No Action was declared!", details: nil))
                return
            } else {
                let secureStore = SecureStore()
                
                switch action {
                    case SecureStoreActions.getFromSecureKeychain.rawValue:
                        //var groupId: String = options?["groupId"] as! String

                        let keychainValue = try! secureStore.entry(forKey: key)
                        print("Keychain value", keychainValue!)
                    case SecureStoreActions.setToSecureKeychain.rawValue:
                        //var groupId: String = options?["groupId"] as! String
                        //var accessibility: String = options?["accessibility"] as! String

                        try! secureStore.set(entry: value, forKey: key)
                        let testValue = try! secureStore.entry(forKey: key)
                        print("Previously set Test Value: ", testValue!)
                    case SecureStoreActions.removeFromSecureKeychain.rawValue:
                        try! secureStore.removeEntry(forkey: key)
                        do {
                            _ = try secureStore.entry(forKey: key)
                        } catch {
                            print("Removed Succesfully!")
                        }
                    default:
                        result(FlutterError(code: "actionNotFound", message: "No Action in scope was found", details: "Request through get, set or remove. Nothing else!"))
                }
                
//                if action == "set" {
//                    // Storing KeyPairValue to Keychain
//                    let status: () = try! secureStore.set(entry: value, forKey: key)
//                    // Testing new Stored Value
//                    let testValue = try! secureStore.entry(forKey: key)
//                    print("Previously set Test Value: ", testValue!)
//
////                    if status !== errSecSuccess {
////                        return true
////                    } else if status == errSecSuccess {
////                        return false
////                    }
//                } else if action == "get" {
//                    let keychainValue = try! secureStore.entry(forKey: key)
//                    print("Keychain value", keychainValue!)
////                    return keychainValue
//                }
                print("Keychain Stuff DONE!")
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
