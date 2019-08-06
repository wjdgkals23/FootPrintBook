//
//  LoginViewController.swift
//  FootPrintGram
//
//  Created by 정하민 on 06/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    var googleSignButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(googleSignButton)
        googleSignButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).offset(-30)
        }
//        googleSignButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        GIDSignIn.sharedInstance().uiDelegate = self
        // Do any additional setup after loading the view.
    }
    
//
    
   
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
