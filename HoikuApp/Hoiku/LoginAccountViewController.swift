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
    
    @IBOutlet weak var termsOfService: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGes:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        self.view.addGestureRecognizer(tapGes)
        
        loginButton.backgroundColor = UIColor.orange
        loginButton.tintColor = UIColor.white
        loginButton.layer.cornerRadius = 10
        
        createAccountButton.backgroundColor = UIColor.orange
        createAccountButton.tintColor = UIColor.white
        createAccountButton.layer.cornerRadius = 10
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc private func dismissKey(){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // viewが表示された時にパスワードとアカウント名を表示する
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
                //メールアドレスとパスワードが入力されていない場合にはなにも起こさない
                SVProgressHUD.showError(withStatus: "必須項目を入力してください。")
                return
            }
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: address, password: password){user,error in
                if let error = error{
                    //エラーが起きた場合にはエラーを表示する
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    print(error.localizedDescription)
                    return
                }
                //アカウント作成に成功したことを表示する
                print("ログインに成功しました。")
                SVProgressHUD.dismiss()
                SVProgressHUD.showSuccess(withStatus: "ログインが完了しました")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func handleCreateAccountButton(_ sender: UIButton) {
        //ログインされている場合にはエラーを表示する
        if Auth.auth().currentUser != nil{
            SVProgressHUD.showError(withStatus: "すでにアカウント作成されています")
            return
        }
        
        if let mailAddress = mailAddressTextField.text ,let password = passwordTextField.text,let displayName = displayNameTextField.text{
            if mailAddress.isEmpty || password.isEmpty || displayName.isEmpty{
                //入力された内容で空文字がある場合には空文字であることを表示する
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
                
                let semaphore = DispatchSemaphore(value: 0)
                
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
                        
                        semaphore.signal()
                        
                        semaphore.wait()
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }
    
    @IBAction func termsOfServiceButtonTapped(_ sender: UIButton) {
        let termsOfServiceNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfServiceNavi") as! UINavigationController
        
        let termsOfServiceViewController = termsOfServiceNavigationController.topViewController as! TermsOfServiceViewController
        
        self.present(termsOfServiceNavigationController,animated: true,completion: nil)
    }
    
}
