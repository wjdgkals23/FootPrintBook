//
//  NewFootPrintViewController.swift
//  FootPrintGram
//
//  Created by 정하민 on 04/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import TextFieldEffects
import SVProgressHUD

class NewFootPrintViewController: UIViewController, UINavigationControllerDelegate {
    
    var flag: Bool!
    var userInfo = UserInfo.shared
    var fireUtil = FireBaseUtil.shared
    
    var newAnnotation: FootPrintAnnotation!
    var postImage: Data!
    
    var titleField = HoshiTextField()
    var addImageButton = UIImageView()
    var latitudeTextField = HoshiTextField()
    var longitudeTextField = HoshiTextField()
    
    var cancelButton = UIButton()
    var registerButton = UIButton()
    
    var scrollView = UIScrollView()
    var contentView = UIView()
    
    var firstHeight: CGFloat!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(newAnnotation.coordinate.latitude)
        // Do any additional setup after loading the view.
        setupView()
        firstHeight = self.view.frame.height
    }
    
    // MARK: - Private
    
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
            make.left.equalTo(superView).offset(15)
            make.right.equalTo(superView).offset(-15)
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
    }
    
    func setupView() {
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.isScrollEnabled = true
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        self.scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.width.equalTo(self.scrollView)
            make.height.equalTo(self.scrollView).priority(.low)
            make.top.left.right.bottom.equalTo(self.scrollView)
        }
        self.contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(10)
            make.right.equalTo(contentView).offset(-10)
            make.width.height.equalTo(40)
        }
        cancelButton.setImage(#imageLiteral(resourceName: "CloseIcon"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        componentSetting(target: titleField, title: "Title", superView: self.contentView, topView: cancelButton)
        
        self.contentView.addSubview(addImageButton)
        addImageButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(titleField.snp.bottom).offset(40)
            make.width.height.equalTo(100)
        }
        
        addImageButton.image = #imageLiteral(resourceName: "AddImage")
        addImageButton.isUserInteractionEnabled = true
        
        let imageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePicker))
        addImageButton.addGestureRecognizer(imageViewTapGesture)
        
        registerButton.addTarget(self, action: #selector(registerPost), for: .touchUpInside)
        
        componentSetting(target: latitudeTextField, title: "latitude", superView: self.contentView, topView: addImageButton)
        componentSetting(target: longitudeTextField, title: "longitude", superView: self.contentView, topView: latitudeTextField)
        componentSetting(target: registerButton, title: "register", superView: self.contentView, topView: longitudeTextField)
        
        if newAnnotation != nil {
            latitudeTextField.text = String(newAnnotation.coordinate.latitude)
            longitudeTextField.text = String(newAnnotation.coordinate.longitude)
        }
    }
    
    func errorHandle(_ err:Error) -> Void {
        SVProgressHUD.dismiss()
        self.failRegister(message: "사진등록조회싪패" + err.localizedDescription)
    }
    
    // MARK: - action
    
    @objc func cancel() {
        performSegue(withIdentifier: "cancel", sender: self)
    }
    
    @objc func registerPost() {
        SVProgressHUD.show()
        let uploadImage = self.addImageButton.image!.jpegData(compressionQuality:0.1)
        let postData = ["name": self.titleField.text!, "latitude": self.latitudeTextField.text!, "longitude": self.longitudeTextField.text!, "created": self.newAnnotation.post.created!]
        let title = self.titleField.text!
        DispatchQueue.global().async { [unowned self] in
            self.fireUtil.totalFunc(title, uploadImage!, data2: postData).done{ result in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "registerEnd", sender: self)
                }
            }.catch{ err in self.errorHandle(err) }
        }
    }
}

// MARK: - Delegate

extension NewFootPrintViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        let ratio = image.size.height/image.size.width
        let height = (self.view.frame.width - 20)*ratio
        self.addImageButton.snp.removeConstraints()
        self.addImageButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(titleField.snp.bottom).offset(40)
            make.width.equalTo(self.view.frame.width - 20)
            make.height.equalTo(height)
        }
        
        self.addImageButton.image = image
        
        self.contentView.snp.removeConstraints()
        self.contentView.snp.makeConstraints({ (make) in
            make.width.equalTo(self.scrollView)
            make.height.equalTo(self.contentView.frame.height + height).priority(.low)
            make.top.left.right.bottom.equalTo(self.scrollView)
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePicker() {
        let imagePickerView = UIImagePickerController()
        imagePickerView.delegate = self
        imagePickerView.allowsEditing = true
        if Platform.isSimulator {
            imagePickerView.sourceType = .photoLibrary
        } else {
            imagePickerView.sourceType = .camera
        }
        self.present(imagePickerView, animated: true, completion: nil)
    }
    
}

