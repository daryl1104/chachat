//
//  Utilities.swift
//  ChaChat
//
//  Created by daryl on 2023/5/12.
//

import Foundation
import UIKit

class Utilities {

    func showAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true)
        
    }
    
}
