//
//  EurekaLoinAccountViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/12/08.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import Firebase
import Eureka
import FirebaseAuth
import FirebaseDatabase

class EurekaLoinAccountViewController: FormViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            
            +++ Section("")
            <<< TextRow{row in
                row.title = "メールアドレス"
                row.tag = "mailAddress"
            }
            
            <<< TextRow{row in
                row.title = "パスワード"
                row.placeholder = "6文字以上で入力してください"
                row.tag = "passward"
        }
        
        <<< TextRow{row in
            row.title = "名前"
            row.tag = "name"
            
        }
        
        
        
        
    }
    
}
