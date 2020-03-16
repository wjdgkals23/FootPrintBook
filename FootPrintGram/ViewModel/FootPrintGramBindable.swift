//
//  FootPrintGramBindable.swift
//  FootPrintGram
//
//  Created by 정하민 on 2020/03/16.
//  Copyright © 2020 JHM. All rights reserved.
//

import UIKit

protocol FootPrintGramBindable {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get }
    
    func setUpView()
    func setUpRx()
}

extension FootPrintGramBindable where Self: UIViewController {
    mutating func bind(viewModel: Self.ViewModelType) {
        loadViewIfNeeded()
        setUpView()
        setUpRx()
    }
}
