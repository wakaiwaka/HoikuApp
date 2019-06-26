//
//  LoginAccountViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/18.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import SVProgressHUD

class LoginAccountViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGes:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        self.view.addGestureRecognizer(tapGes)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKey(){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = Auth.auth().currentUser{
            mailAddressTextField.text = user.email
            displayNameTextField.text = user.displayName
        }
    }
    
    @IBAction func handleLoginButton(_ sender: UIButton) {
        if Auth.auth().currentUser != nil{
            SVProgressHUD.showError(withStatus: "すでにログイン済みです")
            return
        }
        
        if let address = mailAddressTextField.text,let password = passwordTextField.text{
            if address.isEmpty || password.isEmpty{
                SVProgressHUD.showError(withStatus: "必須項目を入力してください。")
                return
            }
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: address, password: password){user,error in
                if let error = error{
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    print(error.localizedDescription)
                    return
                }
                print("ログインに成功しました。")
                SVProgressHUD.dismiss()
                SVProgressHUD.showSuccess(withStatus: "ログインが完了しました")
            }
        }
    }
    @IBAction func handleCreateAccountButton(_ sender: UIButton) {
        if Auth.auth().currentUser != nil{
            SVProgressHUD.showError(withStatus: "すでにアカウント作成されています")
            return
        }
        
        if let mailAddress = mailAddressTextField.text ,let password = passwordTextField.text,let displayName = displayNameTextField.text{
            if mailAddress.isEmpty || password.isEmpty || displayName.isEmpty{
                print("何かがから文字です")
                SVProgressHUD.showError(withStatus: "必須項目を入力してください。")
                return
            }
            Auth.auth().createUser(withEmail: mailAddress, password: password){user ,error in
                if let error = error{
                    print(error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                    return
                }
                print("ユーザー作成に成功しました。")
                
                let user = Auth.auth().currentUser
                if let user = user{
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges{error in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        print("\(user.displayName!)に設定しました。")
                        SVProgressHUD.dismiss()
                        
                        
                        let userRef = Database.database().reference().child(Const.users).child(user.uid)
                        let userDic = ["userName":user.displayName,"address":user.email]
                        
                        userRef.setValue(userDic)
                        
                        SVProgressHUD.showSuccess(withStatus: "アカウント作成に成功しました")
                    }
                }
            }
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        if Auth.auth().currentUser != nil{
            try! Auth.auth().signOut()
            self.displayNameTextField.text = ""
            self.mailAddressTextField.text = ""
        }else{
            SVProgressHUD.showError(withStatus: "アカウント作成されていません")
        }
    }
    
    
}
