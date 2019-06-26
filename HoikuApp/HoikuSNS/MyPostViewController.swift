//
//  MyPostViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/10/08.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MessageUI

class MyPostViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var myPostDataArray:[PrivatePostsData] = []
    private var observing:Bool = false
    
    @IBOutlet weak var naviBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviBar.title = "プライベート投稿"
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser != nil{
            if let uid = Auth.auth().currentUser?.uid{
                if observing == false{
                    let postRef = Database.database().reference().child(Const.privatePostsData).queryOrdered(byChild: "userId").queryEqual(toValue: uid)
                    
                    //要素が加わった時の処理
                    postRef.observe(.childAdded) { (snapshot) in
                        let postData = PrivatePostsData(snapshot: snapshot, myId: uid)
                        if postData.userId == Auth.auth().currentUser?.uid{
                            self.myPostDataArray.insert(postData, at: 0)
                            self.tableView.reloadData()
                        }
                    }
                    
                    //要素の中身の変更がおきた時の処理
                    postRef.observe(.childChanged ,with: { (snapshot) in
                        if let uid = Auth.auth().currentUser?.uid{
                            let postData = PrivatePostsData(snapshot: snapshot, myId: uid)
                            var index:Int = 0
                            for post in self.myPostDataArray{
                                if post.postId == postData.postId{
                                    index = self.myPostDataArray.index(of: post)!
                                    break
                                }
                            }
                            self.myPostDataArray.remove(at: index)
                            self.myPostDataArray.insert(postData, at: index)
                            self.tableView.reloadData()
                        }
                    })
                    observing = true
                }
            }
        }else{
            //ログアウトされた時の処理
            if observing == true{
                myPostDataArray = []
                tableView.reloadData()
                Database.database().reference().removeAllObservers()
                observing = false
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
}
//投稿データの配列とユーザー情報のが配列が両方0ではない時に値を与える
extension MyPostViewController:UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPostDataArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        //投稿データをセルにセットする
        cell.setMyPostData(myPostData: myPostDataArray[indexPath.row])
        //いいねボタンををした時の処理
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        //違反申請のボタンをタップした時の処理
        cell.warningButton.addTarget(self, action: #selector(appForViolationButtonTapped), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingKnowHowViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingKnowHow") as! SettingKnowHowViewController
        
        let myPostData = myPostDataArray[indexPath.row]
        
        settingKnowHowViewController.myPostData = myPostData
        
        if myPostData.share == "true"{
            settingKnowHowViewController.switchBool = true
        }else{
            settingKnowHowViewController.switchBool = false
        }
        self.navigationController?.pushViewController(settingKnowHowViewController, animated: true)
    }
    
    @objc func likeButtonTapped(sender:UIButton,forEvent event:UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData = myPostDataArray[indexPath!.row]
        if let uid = Auth.auth().currentUser?.uid{
            if postData.isLiked{
                var index = -1
                for likeId in postData.likes{
                    if likeId == uid{
                        index = postData.likes.index(of:likeId)!
                        break
                    }
                }
                postData.likes.remove(at: index)
            }else{
                postData.likes.append(uid)
            }
            let privatePostRef = Database.database().reference().child(Const.privatePostsData).child(postData.postId!)
            let likes = ["likes":postData.likes]
            privatePostRef.updateChildValues(likes)
            
            if postData.share == "true"{
                let postRef = Database.database().reference().child(Const.postPath).child(postData.postId!)
                postRef.updateChildValues(likes)
            }
        }
    }
    
    @objc func appForViolationButtonTapped(sender:UIButton,forEvent event:UIEvent){
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        if let email = Auth.auth().currentUser?.email{
            let touch = event.allTouches?.first
            let point = touch!.location(in: self.tableView)
            let indexPath = tableView.indexPathForRow(at: point)
            
            let selectPostData = myPostDataArray[indexPath!.row]
            
            let mailerController = MFMailComposeViewController()
            let toRecipients = ["wakkamassa@gmail.com"]
            let CcRecipients = [email]
            let subject = "\(selectPostData.postId!)の違反申請"
            
            mailerController.mailComposeDelegate = self
            mailerController.setSubject("件名を入力")
            mailerController.setToRecipients(toRecipients)
            mailerController.setCcRecipients(CcRecipients)
            mailerController.setSubject(subject)
            self.present(mailerController,animated: true,completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("キャンセル")
            break
        case .sent:
            print("送信")
        case .saved:
            print("保存")
        case .failed:
            print("失敗")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}


