//
//  NewFootPrintViewController.swift
//  FootPrintGram
//
//  Created by 정하민 on 04/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import UIKit
import SnapKit
import TextFieldEffects

class NewFootPrintViewController: UIViewController {
    
    var newAnnotation: FootPrintAnnotation!
    var postImage: Data!

    var titleField = HoshiTextField()
    var addImageButton = UIImageView()
    var latitudeTextField = HoshiTextField()
    var longitudeTextField = HoshiTextField()
    
    var cancelButton = UIButton()
    var registerButton = UIButton()
    
    func componentSetting(target: UIView, title: String, superView: UIView, topView: UIView) {
        if let textTarget = target as? HoshiTextField {
            textTarget.placeholder = title
            textTarget.placeholderFontScale = 1
            textTarget.placeholderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            textTarget.borderActiveColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            textTarget.borderInactiveColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            textTarget.contentVerticalAlignment = .top
        }
        
        if let buttonTarget = target as? UIButton {
            buttonTarget.setTitle(title, for: .normal)
            buttonTarget.backgroundColor = #colorLiteral(red: 1, green: 0.3891042471, blue: 0.3763918281, alpha: 1)
        }
        
        superView.addSubview(target)
        
        target.snp.makeConstraints { (make) in
            make.left.equalTo(superView.safeAreaLayoutGuide).offset(15)
            make.right.equalTo(superView.safeAreaLayoutGuide).offset(-15)
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
    }
    
    func setupView() {
        self.view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            make.width.height.equalTo(40)
        }
        cancelButton.setImage(#imageLiteral(resourceName: "CloseIcon"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        componentSetting(target: titleField, title: "Title", superView: self.view, topView: cancelButton)
        
        self.view.addSubview(addImageButton)
        addImageButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(titleField.snp.bottom).offset(40)
            make.width.height.equalTo(100)
        }
        addImageButton.image = #imageLiteral(resourceName: "AddImage")
        
        componentSetting(target: latitudeTextField, title: "latitude", superView: self.view, topView: addImageButton)
        componentSetting(target: longitudeTextField, title: "longitude", superView: self.view, topView: latitudeTextField)
        componentSetting(target: registerButton, title: "register", superView: self.view, topView: longitudeTextField)
        
        if newAnnotation != nil {
            latitudeTextField.text = String(newAnnotation.coordinate.latitude)
            longitudeTextField.text = String(newAnnotation.coordinate.longitude)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(newAnnotation.coordinate.latitude)
        // Do any additional setup after loading the view.
        setupView()
    }
    
    @objc func cancel(){
        performSegue(withIdentifier: "cancel", sender: self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
