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
import RxSwift
import RxCocoa

class NewFootPrintViewController: UIViewController, UINavigationControllerDelegate {
    
    let disposeBag = DisposeBag()
    let viewModel = NewFootPrintViewModel()
    
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
        buttonEventBind()
    }
    
    // MARK: - Private
    
    func buttonEventBind() {
        
        let imageObs = addImageButton.rx.observe(Optional<UIImage>.self, "image")
        let defaultImage = #imageLiteral(resourceName: "AddImage")
        let imageValue: Observable<UIImage> = imageObs.map{ image in
            return image! ?? defaultImage
        }
        
        imageValue
            .bind(to: viewModel.image)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap.bind{ [weak self] in
            self?.performSegue(withIdentifier: "cancel", sender: self)
            }.disposed(by: disposeBag)
        
        titleField.rx.text.orEmpty
            .bind(to: viewModel.titleConnector)
            .disposed(by: disposeBag)
        
        viewModel.titleData
            .drive(titleField.rx.text)
            .disposed(by: disposeBag)
        
        latitudeTextField.rx.text.orEmpty
            .bind(to: viewModel.latitudeValue)
            .disposed(by: disposeBag)
        
        longitudeTextField.rx.text.orEmpty
            .bind(to: viewModel.longitudeValue)
            .disposed(by: disposeBag)
        
        viewModel.registerButtonEnabled
            .drive(registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        

    }
    
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
    
    // MARK: - action
    
    @objc func cancel() {
        performSegue(withIdentifier: "cancel", sender: self)
    }
    
    @objc func registerPost() {
        SVProgressHUD.show()
        let uploadImageOb = self.fireUtil.rxUploadImage(titleField.text!, viewModel.makeUploadImage()!)
        let downLoadUrlOb = self.fireUtil.rxGetImageUrl()
        
        uploadImageOb.flatMapLatest{ b in downLoadUrlOb}
            .flatMapLatest{ url in self.fireUtil.rxUploadData(data: self.viewModel.makePostData(), url: url!) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { result in
                if result! {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "registerEnd", sender: self)
                } else {
                    SVProgressHUD.dismiss()
                    self.failRegister(message: "업로드실패")
                }
            }, onError: { err in
                SVProgressHUD.dismiss()
                self.failRegister(message: err.localizedDescription)
            })
        .disposed(by: disposeBag)
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

