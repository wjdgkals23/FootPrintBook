//
//  MakeAlert.swift
//  FootPrintGram
//
//  Created by 정하민 on 03/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation
import UIKit

class MakeAlert {
    
    static let shared = MakeAlert()
    
    func makeOneActionAlert(target: UIViewController!, title: String!, message: String!, dismiss: Bool) {
        let alertVC = UIAlertController(title: title,
                          message: message,
                          preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .destructive) { alert in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(alertAction)
        target.present(alertVC, animated: false, completion: nil)
    }
}
