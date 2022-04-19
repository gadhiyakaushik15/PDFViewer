//
//  Helper.swift
//  PDFViewer
//
//  Created by Macbook Pro on 04/05/18.
//  Copyright © 2018 Kaushik Gadhiya. All rights reserved.
//

import UIKit

class Helper: NSObject
{
    
    static var sharedInstance = Helper()

    //MARK: - Alerts
    
    func showAlert(delegate : UIViewController, alertContentText : String){
        
        let myAlertController = UIAlertController(title: "Message", message: alertContentText, preferredStyle: UIAlertController.Style.alert)
        
        myAlertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        delegate.present(myAlertController, animated: true, completion: nil)
        
    }
}
