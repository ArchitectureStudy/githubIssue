//
//  ExampleViewController.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 15..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ExampleViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    @IBOutlet var label: UILabel!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.rx.text.bind(to: label.rx.text).disposed(by: disposeBag)
        
        Observable.just(3)
        
            
    }
    
}
