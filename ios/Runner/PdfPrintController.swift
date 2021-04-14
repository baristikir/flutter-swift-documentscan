//
//  PdfPrintController.swift
//  Runner
//
//  Created by Baris Tikir on 18.03.21.
//

import UIKit

public class PdfPrintController: UIPrintPageRenderer, UIPrintInteractionControllerDelegate {
    
    let printController = UIPrintInteractionController()
    private var pdfDocument: CGPDFDocument?
    private var jobName: String?
    private var orientation: UIPrintInfo.Orientation?
    private let semaphore = DispatchSemaphore(value: 0)
    private var dynamic = false
        
    public init(index: Int) {
        super.init()
        pdfDocument = nil
        printController.delegate = self
    }
    
//    override public func drawPage(at pageIndex: Int, in printableRect: CGRect) {
//        print("Draw Page Method Called")
//        let context = UIGraphicsGetCurrentContext()
//        let page = pdfDocument?.page(at: pageIndex + 1)
//        context?.scaleBy(x: 1.0, y: -1.0)
//        context?.translateBy(x: 0.0, y: -paperRect.size.height)
//        if page != nil {
//            print("Received PDF Page, trying to print")
//            context?.drawPDFPage(page!)
//        }
//    }
    
    func printPDF(pdf: Any, printInfo: UIPrintInfo) {
//        let printing = UIPrintInteractionController.isPrintingAvailable
//        if !printing {
//            self.printing.onCompleted(printJob: self, completed: false, error: "Printing not available")
//            return
//        }
    }
    
    func cancelJob(_ error: String?) {
        pdfDocument = nil
        if dynamic {
            semaphore.signal()
        } else {
            
        }
    }
    
    func completionHandler(printerVC _: UIPrintInteractionController, completed: Bool, error: Error?) {
        if !completed, error != nil {
            print("Unable to print: \(error?.localizedDescription ?? "unkown error")")
        }
    }
}
