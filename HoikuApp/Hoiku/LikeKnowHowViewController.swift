//
//  LikeKnowHowViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/11.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MessageUI

class LikeKnowHowViewController: UIViewController,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    private let semaphore = DispatchSemaphore(value: 0)
    private let queue = DispatchQueue.global(qos: .userInitiated)
    private let mainqueue = DispatchQueue.main
    
    private var likePostArray:[PostData] = []
    private var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likePostArray.reverse()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 120
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ログインされている場合の処理
        if Auth.auth().currentUser != nil{
            if self.observing == false{
                let postRef = Database.database().reference().child(Const.postPath).queryOrdered(byChild: "likes")
                //要素が追加された時の処理
                postRef.observe(.childAdded) { (snapshot) in
                    if let uid = Auth.auth().currentUser?.uid{
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        var addIndex:Int = 0
                        for addPost in self.likePostArray{
                            if addPost.likes.count <= postData.likes.count{
                                addIndex = self.likePostArray.index(of: addPost)!
                                break
                            }
                        }
                        self.likePostArray.insert(postData, at: addIndex)
                        self.tableView.reloadData()
                    }
                }
                //投稿データが変更になった場合の処理
                postRef.observe(.childChanged ,with: { (snapshot) in
                    if let uid = Auth.auth().currentUser?.uid{
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        var removeIndex:Int = 0
                        var addIndex:Int = 0
                        
                        //変更する投稿のポストidを一度取り出す
                        for removePost in self.likePostArray{
                            if removePost.postId == postData.postId{
                                removeIndex = self.likePostArray.index(of: removePost)!
                            }
                        }
                        
                        //取り出した投稿のidを
                        self.likePostArray.remove(at: removeIndex)
                        
                        for addPost in self.likePostArray{
                            
                            //全投稿の中で変更されるデータのいいね数より少ない、一番若い順番のデータを取りだす
                            if addPost.likes.count <= postData.likes.count{
                                addIndex = self.likePostArray.index(of: addPost)!
                                self.likePostArray.insert(postData, at: addIndex)
                                self.tableView.reloadData()
                                break
                            }else if postData.likes.count == 0{
                                //変更されるえデータのいいね数が0の場合一番下に設定する。
                                self.likePostArray.append(postData)
                                self.tableView.reloadData()
                                break
                            }
                        }
                    }
                })
                let userRef = Database.database().reference().child(Const.users)
                
                userRef.observe(.childChanged) { (snapshot) in
                    self.tableView.reloadData()
                }
                
                self.observing = true
            }
        }else{
            //オブサーブがtrueの場合投稿データを空にする。
            if observing == true{
                likePostArray = []
                tableView.reloadData()
                Database.database().reference().removeAllObservers()
                observing = false
            }
        }
    }
    
    //画面が消えた時にtableviewの選択をなくす。
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension LikeKnowHowViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.likePostArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        
        //投稿データといいねのボタン、コメントボタン、警告ボタンの設置
        cell.setPostData(postData: self.likePostArray[indexPath.row])
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped(sender:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(commentButtonTapped(sender:forEvent:)), for: .touchUpInside)
        cell.warningButton.addTarget(self, action: #selector(appForViolationButtonTapped(sender:forEvent:)), for: .touchUpInside)
        return cell
    }
    
    //セルをタップした時に詳細画面を表示
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailKnowHowViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailKnowHow") as! DetailKnowHowViewController
        
        detailKnowHowViewController.postData = self.likePostArray[indexPath.row]
        
        self.navigationController?.pushViewController(detailKnowHowViewController, animated: true)
        
    }
    
    //コメントボタンをタップした時の処理
    @objc private func commentButtonTapped(sender:UIButton, forEvent event:UIEvent){
        let ref = Database.database().reference()
        
        let navi = self.storyboard?.instantiateViewController(withIdentifier: "MessageNavigationController") as! UINavigationController
        
        let messageViewController = navi.topViewController as! MessageViewController
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData = likePostArray[indexPath!.row]
        
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
    //いいね!ボタンをタップした時の処理
    @objc private func likeButtonTapped(sender:UIButton,forEvent event:UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData = likePostArray[indexPath!.row]
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
    //違反申請のボタンをタップした時の処理
    @objc private func appForViolationButtonTapped(sender:UIButton, forEvent event:UIEvent){
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        if let email = Auth.auth().currentUser?.email{
            let touch = event.allTouches?.first
            let point = touch!.location(in: self.tableView)
            let indexPath = tableView.indexPathForRow(at: point)
            
            let selectPostData = likePostArray[indexPath!.row]
            
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
    private func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
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
