//
//  ChangeAccountViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/11/20.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class ChangeAccountViewController: UIViewController {
    
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userName = Auth.auth().currentUser?.displayName{
            self.displayName.text = userName
        }
        createAccountButton.backgroundColor = UIColor.orange
        createAccountButton.tintColor = UIColor.white
        createAccountButton.layer.cornerRadius = 10
        logoutButton.backgroundColor = UIColor.orange
        logoutButton.tintColor = UIColor.white
        logoutButton.layer.cornerRadius = 10
    }
    
    //表示名変更ボタンをタップした時の処理
    @IBAction func changeAccountName(_ sender: UIButton) {
        if displayName.text?.isEmpty == true{
            SVProgressHUD.showError(withStatus: "表示名を入力してください")
            return
        }
        if let user = Auth.auth().currentUser{
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = self.displayName.text
            
            //FirebaseAuthのユーザー情報を変更
            changeRequest.commitChanges { error in
                if let error = error {
                    // プロフィールの更新でエラーが発生
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                }
                print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                
                //FirebaseRealtimeDatabase上に保存されているユーザー情報の変更
                let ref = Database.database().reference().child(Const.users).child(user.uid)
                ref.observeSingleEvent(of: .value) { (snapshot) in
                    let oneUser = Users(snapshot: snapshot)
                    oneUser.userName = user.displayName
                    ref.updateChildValues(["userName":oneUser.userName])
                    SVProgressHUD.showSuccess(withStatus: "ユーザー名を" + oneUser.userName! + "に変更しました")
                }
            }
            
        }
    }
    
    //ログアウトボタンを押した場合の処理
    @IBAction func logoutAccount(_ sender: UIButton) {
        //アカウントがログインされている場合にログアウトの処理を反映させる
        if Auth.auth().currentUser != nil{
            try! Auth.auth().signOut()
            self.displayName.text = ""
            
            //ログイン画面に遷移させる
            let loginAccountNavi = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountNavi") as! UINavigationController
            let loginAccountViewController = loginAccountNavi.topViewController as! LoginAccountViewController
            self.present(loginAccountNavi,animated: true,completion: nil)
        }else{
            //ログインされていない場合は画面にログインされていないことを表示する
            SVProgressHUD.showError(withStatus: "ログインされていません")
        }
    }
}
