//
//  UIViewControllerExtension.swift
//  FootPrintGram
//
//  Created by 정하민 on 27/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func failRegister(message: String) {
        let alert = UIAlertController(title: message, message: "재시도 해주세요", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            self.dismiss(animated: false, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
