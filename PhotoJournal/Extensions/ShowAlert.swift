//
//  ShowAlert.swift
//  PhotoJournal
//
//  Created by Melinda Diaz on 2/17/20.
//  Copyright © 2020 Melinda Diaz. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
   
  func showAlert(title: String, message: String, completion: ((UIAlertAction) -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        let okAction = UIAlertAction(title: "ok" , style: .default , handler: completion )
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
