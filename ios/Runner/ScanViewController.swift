//
//  ScanViewController.swift
//  Runner
//
//  Created by Baris Tikir on 02.12.20.
//

import UIKit
import VisionKit

typealias VisionHandler = (Result<VisionResult,Error>) -> Void

@available(iOS 13.0, *)
class ScanViewController: NSObject, VNDocumentCameraViewControllerDelegate {
    
    let documentVC = VNDocumentCameraViewController()
    var completionHandler: VisionHandler?
    
    override init() {
        super.init()
        documentVC.delegate = self
        documentVC.modalPresentationStyle = UIModalPresentationStyle.currentContext
    }

    func scanDocument(completionHandler: @escaping VisionHandler)
    {
        let window: UIWindow? = UIApplication.shared.keyWindow
        self.completionHandler = completionHandler
        window?.rootViewController?.present(self.documentVC, animated: true)
    }
    
    private func showDocumentScanner(window:UIWindow?) -> UIViewController?
    {
        let usingWindow = window
        var controller = usingWindow?.rootViewController
        while controller?.presentedViewController != nil{
            controller = controller?.presentingViewController
        }
        return controller
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan)
    {
        var images:[UIImage] = []
        
        // Process the scanned pages
        for i in 0..<scan.pageCount {
            _ = scan.imageOfPage(at: i)
            images.append(scan.imageOfPage(at: i))
        }
        
        print("user did press save with scanned docs numbers \(scan.pageCount) ")
        
        // Responsible for dismissing the `VNDocumentScanViewController` controller.
        documentVC.dismiss(animated: true, completion: nil)
        self.completionHandler?(.success(VisionResult.success(images: images)))
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        // Responsible for dismissing the `VNDocumentScanViewController` controller.
        print("Did press cancel")

        documentVC.dismiss(animated: true)
        self.completionHandler?(.success(.canceled))
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        // Handle errors appropriately in your app.
        print(error)
        

        // Responsible for dismissing the `VNDocumentScanViewController` controller.
        documentVC.dismiss(animated: true)
        self.completionHandler?(.failure(error))
    }
    
    
    // Converting UIImage to base64encoded -> String
    class func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
}
