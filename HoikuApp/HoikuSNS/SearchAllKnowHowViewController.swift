//
//  SearchAllKnowHowViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/28.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import RealmSwift
import MessageUI

class SearchAllKnowHowViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate {
    
    
    var allPostArray:[PostData] = []
    private let realm = try! Realm()
    var searchPostArray:[PostData] = []
    
    var observing = false
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchKey:String = ""
    var searchWard:String = ""
    var searchText:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 120
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchPostArray.count
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser != nil{
            if observing == false{
                //searchTextの中身がもsearchWardの中身もない場合の処理
                if self.searchText.isEmpty{
                    if searchWard.isEmpty{
                        return
                    }
                    //searchTextがなくてsearchWardの中身がある場合の処理
                    let postRef = Database.database().reference().child(Const.postPath).queryOrdered(byChild: "searchWord/" + self.searchKey).queryEqual(toValue:self.searchWard)
                    postRef.observe(.childAdded) { (snapshot) in
                        if let uid = Auth.auth().currentUser?.uid{
                            let postData = PostData(snapshot: snapshot, myId: uid)
                            self.searchPostArray.insert(postData, at: 0)
                            self.tableView.reloadData()
                        }
                    }
                    //要素の変更があった場合の処理
                    postRef.observe(.childChanged ,with: { (snapshot) in
                        if let uid = Auth.auth().currentUser?.uid{
                            let postData = PostData(snapshot: snapshot, myId: uid)
                            var index:Int = 0
                            for post in self.searchPostArray{
                                if post.postId == postData.postId{
                                    index = self.searchPostArray.index(of: post)!
                                    break
                                }
                            }
                            self.searchPostArray.remove(at: index)
                            self.searchPostArray.insert(postData, at: index)
                            self.tableView.reloadData()
                        }
                    })
                }else{
                    //searchTextに値がありsearchWardにも値がある場合
                    if searchWard.isEmpty == false{
                        let postRef = Database.database().reference().child(Const.postPath).queryOrdered(byChild: "searchWord/" + self.searchKey).queryEqual(toValue:self.searchWard)
                        postRef.observe(.childAdded) { (snapshot) in
                            if let uid = Auth.auth().currentUser?.uid{
                                let postData = PostData(snapshot: snapshot, myId: uid)
                                
                                self.allPostArray.insert(postData, at: 0)
                                try! self.realm.write {
                                    let searchKnowHow = SearchKnowHow()
                                    if let postId = postData.postId{
                                        searchKnowHow.postId = postId
                                    }
                                    if let title = postData.title{
                                        searchKnowHow.title = title
                                    }
                                    self.realm.add(searchKnowHow, update: true)
                                }
                                //Firebaseで絞った条件をさらにRealmで絞る
                                let predicate = NSPredicate(format:"title CONTAINS %@",self.searchText)
                                let searchKnowHowArray = try! Realm().objects(SearchKnowHow.self).filter(predicate).sorted(byKeyPath: "postId", ascending: false)
                                for knowHow in searchKnowHowArray{
                                    for post in self.allPostArray{
                                        if let postId = post.postId{
                                            if knowHow.postId == postId{
                                                self.searchPostArray.insert(post, at: 0)
                                                self.tableView.reloadData()
                                            }}}}}}
                        //要素の変更があった場合の処理
                        postRef.observe(.childChanged ,with: { (snapshot) in
                            if let uid = Auth.auth().currentUser?.uid{
                                let postData = PostData(snapshot: snapshot, myId: uid)
                                var index:Int = 0
                                for post in self.searchPostArray{
                                    if post.postId == postData.postId{
                                        index = self.searchPostArray.index(of: post)!
                                        break
                                    }}
                                self.searchPostArray.remove(at: index)
                                self.searchPostArray.insert(postData, at: index)
                                self.tableView.reloadData()
                            }
                        }
                        )
                        
                    }else{
                        //searchTextに値がありsearchWardに値がない場合
                        let postRef = Database.database().reference().child(Const.postPath)
                        postRef.observe(.childAdded) { (snapshot) in
                            if let uid = Auth.auth().currentUser?.uid{
                                let postData = PostData(snapshot: snapshot, myId: uid)
                                
                                self.allPostArray.insert(postData, at: 0)
                                try! self.realm.write {
                                    let searchKnowHow = SearchKnowHow()
                                    if let postId = postData.postId{
                                        searchKnowHow.postId = postId
                                    }
                                    if let title = postData.title{
                                        searchKnowHow.title = title
                                    }
                                    self.realm.add(searchKnowHow, update: true)
                                }
                                //Firebaseで絞った条件をさらにRealmで絞る
                                let predicate = NSPredicate(format:"title CONTAINS %@",self.searchText)
                                let searchKnowHowArray = try! Realm().objects(SearchKnowHow.self).filter(predicate).sorted(byKeyPath: "postId", ascending: false)
                                for knowHow in searchKnowHowArray{
                                    for post in self.allPostArray{
                                        if let postId = post.postId{
                                            if knowHow.postId == postId{
                                                self.searchPostArray.insert(post, at: 0)
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        //要素の変更があった場合の処理
                        postRef.observe(.childChanged ,with: { (snapshot) in
                            if let uid = Auth.auth().currentUser?.uid{
                                let postData = PostData(snapshot: snapshot, myId: uid)
                                var index:Int = 0
                                for post in self.searchPostArray{
                                    if post.postId == postData.postId{
                                        index = self.searchPostArray.index(of: post)!
                                        break
                                    }
                                }
                                self.searchPostArray.remove(at: index)
                                self.searchPostArray.insert(postData, at: index)
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
                observing = true
            }
        }else{
            if observing == true{
                searchPostArray = []
                tableView.reloadData()
                Database.database().reference().removeAllObservers()
                observing = false
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postData: searchPostArray[indexPath.row])
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped(sender:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(commentButtonTapped(sender:forEvent:)), for: .touchUpInside)
        cell.warningButton.addTarget(self, action: #selector(appForViolationButtonTapped(sender:forEvent:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailKnowHowViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailKnowHow") as! DetailKnowHowViewController
        
        detailKnowHowViewController.postData = self.searchPostArray[indexPath.row]
        
        self.navigationController?.pushViewController(detailKnowHowViewController, animated: true)
        
    }
    
    /// コメントボタンをタップした時のこ挙動
    ///
    /// - Parameters:
    ///   - sender:
    ///   - event:
    @objc func commentButtonTapped(sender:UIButton,forEvent event:UIEvent){
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
    
    //いいね!ボタンが押された際の処理
    @objc func likeButtonTapped(sender:UIButton,forEvent event:UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData = searchPostArray[indexPath!.row]
        
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
    
    
    /// 
    ///
    /// - Parameters:
    ///   - sender:
    ///   - event:
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
