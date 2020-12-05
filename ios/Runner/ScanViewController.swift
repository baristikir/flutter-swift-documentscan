//
//  ScanViewController.swift
//  Runner
//
//  Created by Baris Tikir on 02.12.20.
//

import UIKit
import VisionKit

@available(iOS 13.0, *)
class ScanViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showDocumentScanner()
    }

    private func showDocumentScanner()
    {
        let documentVC = VNDocumentCameraViewController()
        documentVC.delegate = self
        present(documentVC, animated: true, completion: nil)
    }
    
}

@available(iOS 13.0, *)
extension ScanViewController:VNDocumentCameraViewControllerDelegate{
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        
        // Process the scanned pages
        for pageNumber in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)
            print(ScanViewController.convertImageToBase64(image: image))
        }

        // You are responsible for dismissing the controller.
        controller.dismiss(animated: true)
        return
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        // You are responsible for dismissing the controller.
        controller.dismiss(animated: true)
        //present(, animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        // You should handle errors appropriately in your app.
        print(error)

        // You are responsible for dismissing the controller.
        controller.dismiss(animated: true)
        return
    }
    
    
    class func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
}
