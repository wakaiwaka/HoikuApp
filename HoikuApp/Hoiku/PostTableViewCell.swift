//
//  PostTableViewCell.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/11/04.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import CSS3ColorsSwift

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var warningButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.text = ""
        self.titleLabel.text = ""
        self.dateLabel.text = ""
    }
    
    /// 共有の投稿格セルに投稿情報を表示する
    ///
    /// - Parameter postData: 投稿データ
    func setPostData(postData:PostData){
        
        let formatter = DateFormatter()
        formatter.dateFormat =  "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text  = dateString
        
        self.titleLabel.text = postData.title
        
        Database.database().reference().child(Const.users).child(postData.userId!).observeSingleEvent(of: .value) { (snapshot) in
            let user = Users(snapshot: snapshot)
            self.nameLabel.text = user.userName
        }
        self.nameLabel.font = UIFont.systemFont(ofSize: 20)
        
        
        //likeLabelをlikeButtonを設定する
        self.likeLabel.text = "\(postData.likes.count)"
        if postData.isLiked{
            let buttonImage = UIImage(named: "goodtrue")
            self.likeButton.setImage(buttonImage, for: UIControl.State.normal)
        }else{
            let buttonImage = UIImage(named: "goodfalse")
            self.likeButton.setImage(buttonImage, for: UIControl.State.normal)
        }
        
        
        //Firebaseよりカテゴリーを引っ張ってきてcategoryLabelに表示する
        Database.database().reference().child(Const.categories).child(postData.categoryId!).observe(.value) { (snapshot) in
            let category = Category(snapshot: snapshot)
            self.categoryLabel.text = category.categoryName
            self.categoryLabel.textAlignment = .center
            self.categoryLabel.textColor = UIColor.white
            self.categoryLabel.backgroundColor = UIColor.mediumAquamarine
            if category.categoryName?.isEmpty == true{
                self.categoryLabel.isHidden = true
            }
        }
        
        //画像をセットする
        if postData.postImageArray.isEmpty == false{
            let imageUrl:String = postData.postImageArray[0]
            //画像のダウンロード
            let storage = Storage.storage()
            let httpsReference = storage.reference(forURL:imageUrl)
            postImage.sd_setImage(with: URL(string: postData.postImageArray[0]), placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: nil)
        }
    }
    
    /// 共有しない投稿のデータを格セルに表示する
    ///
    /// - Parameter myPostData: 投稿データ
    func setMyPostData(myPostData:PrivatePostsData){
        
        let formatter = DateFormatter()
        formatter.dateFormat =  "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: myPostData.date!)
        self.dateLabel.text  = dateString
        
        self.titleLabel.text = myPostData.title

        
        //Firebaseからユーザーネームを取ってきてnameLabelに配置する「
        Database.database().reference().child(Const.users).child(myPostData.userId!).observeSingleEvent(of: .value) { (snapshot) in
            let user = Users(snapshot: snapshot)
            self.nameLabel.text = user.userName
        }
        self.nameLabel.font = UIFont.systemFont(ofSize: 20)
        
        
        self.likeLabel.text = "\(myPostData.likes.count)"
        if myPostData.isLiked{
            let buttonImage = UIImage(named: "goodtrue")
            self.likeButton.setImage(buttonImage, for: UIControl.State.normal)
        }else{
            let buttonImage = UIImage(named: "goodfalse")
            self.likeButton.setImage(buttonImage, for: UIControl.State.normal)
        }
        self.likeLabel.text = "\(myPostData.likes.count)"
        
        self.commentButton.isHidden = true
        
        //カテゴリーをデータベースから引っ張ってきてcategoryLabelに配置する、カテゴリーが設定されていない場合は表示をしない
        Database.database().reference().child(Const.categories).child(myPostData.categoryId!).observe(.value) { (snapshot) in
            let category = Category(snapshot: snapshot)
            self.categoryLabel.text = category.categoryName
            self.categoryLabel.textAlignment = .center
            self.categoryLabel.textColor = UIColor.white
            if category.categoryName?.isEmpty == true{
                self.categoryLabel.isHidden = true
            }
        }
        
        //画像をセットする
        if myPostData.postImageArray.isEmpty == false{
            let imageUrl:String = myPostData.postImageArray[0]
            let storage = Storage.storage()
            let httpsReference = storage.reference(forURL:imageUrl)
            postImage.sd_setImage(with: URL(string: myPostData.postImageArray[0]), placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: nil)
        }
    }
}
