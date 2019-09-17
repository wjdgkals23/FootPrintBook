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

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    var googleSignButton = GIDSignInButton()
    var userInfo = UserInfo.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(googleSignButton)
        googleSignButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).offset(-30)
        }
//        googleSignButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { [weak that = self] (user, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                that?.userInfo.o_uid = user?.user.uid
                that?.userInfo.o_email = user?.user.email
                that!.performSegue(withIdentifier: "SignIn", sender: that)
            }
        }
    }

}
