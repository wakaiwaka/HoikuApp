//
//  AllKnowHowViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/10.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MessageUI
import SDWebImage


class AllKnowHowViewController: UIViewController,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var allPostArray:[PostData] = []
    var userArray:[Users] = []
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            if observing == false{
                let postRef = Database.database().reference().child(Const.postPath)
                postRef.observe(.childAdded) { (snapshot) in
                    if let uid = Auth.auth().currentUser?.uid{
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.allPostArray.insert(postData, at: 0)
                        self.tableView.reloadData()
                    }
                }
                postRef.observe(.childChanged ,with: { (snapshot) in
                    if let uid = Auth.auth().currentUser?.uid{
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        var index:Int = 0
                        for post in self.allPostArray{
                            if post.postId == postData.postId{
                                index = self.allPostArray.index(of: post)!
                                break
                            }
                        }
                        self.allPostArray.remove(at: index)
                        self.allPostArray.insert(postData, at: index)
                        self.tableView.reloadData()
                        
                    }
                })
                observing = true
            }
        }else{
            if observing == true{
                allPostArray = []
                userArray = []
                tableView.reloadData()
                Database.database().reference().removeAllObservers()
                observing = false
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //画面遷移した後ににcellの選択を解除する
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension AllKnowHowViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPostArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postData: self.allPostArray[indexPath.row])
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
        cell.warningButton.addTarget(self, action: #selector(appForViolationButtonTapped), for: .touchUpInside)
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //投稿詳細画面にせ遷移
        let detailKnowHowViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailKnowHow") as! DetailKnowHowViewController
        detailKnowHowViewController.postData = self.allPostArray[indexPath.row]
        self.navigationController?.pushViewController(detailKnowHowViewController, animated: true)
        
    }
    
    /// コメントボタンをタップした時の挙動
    ///
    /// - Parameters:
    ///   - sender:UIButton
    ///   - event:
    @objc func commentButtonTapped(sender:UIButton, forEvent event:UIEvent){
        let ref = Database.database().reference()
        
        let navi = self.storyboard?.instantiateViewController(withIdentifier: "MessageNavigationController") as! UINavigationController
        
        let messageViewController = navi.topViewController as! MessageViewController
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData = allPostArray[indexPath!.row]
        
        messageViewController.postData = postData
        if let user = Auth.auth().currentUser{
            let currentUserRef = ref.child(Const.users).child(user.uid)
            let ownerUserRef = ref.child(Const.users).child(postData.userId!)
            currentUserRef.observeSingleEvent(of: .value) { (snapshot) in
                let currentUser = Users(snapshot: snapshot)
                ownerUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    let ownerUser = Users(snapshot: snapshot)
                    messageViewController.ownerUser = ownerUser
                    messageViewController.currentUser = currentUser
                    self.present(navi,animated: true,completion: nil)
                })
            }
        }
    }
    
    /// いいねボタンをタップした場合の挙動
    ///
    /// - Parameters:
    ///   - sender: UIButton
    ///   - event:
    @objc func likeButtonTapped(sender:UIButton,forEvent event:UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData = allPostArray[indexPath!.row]
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
            let postRef = Database.database().reference().child(Const.postPath).child(postData.postId!)
            let likes = ["likes":postData.likes]
            postRef.updateChildValues(likes)
            let privatePostRef = Database.database().reference().child(Const.privatePostsData).child(postData.postId!)
            privatePostRef.updateChildValues(likes)
        }
    }
    
    /// 違反申請のボタンをタップした時の挙動
    ///
    /// - Parameters:
    ///   - sender:UIButton
    ///   - event:タップのevent
    @objc func appForViolationButtonTapped(sender:UIButton,forEvent event:UIEvent){
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        if let email = Auth.auth().currentUser?.email{
            let touch = event.allTouches?.first
            let point = touch!.location(in: self.tableView)
            let indexPath = tableView.indexPathForRow(at: point)
            
            let selectPostData = allPostArray[indexPath!.row]
            
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



