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
    
    func setPostData(postData:PostData){
        
        let formatter = DateFormatter()
        formatter.dateFormat =  "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text  = dateString
        
        self.titleLabel.text = postData.title
        
        //self.nameLabel.text = userData.userName
        
        Database.database().reference().child(Const.users).child(postData.userId!).observeSingleEvent(of: .value) { (snapshot) in
            let user = Users(snapshot: snapshot)
            self.nameLabel.text = user.userName
        }
        
        
        self.likeLabel.text = "\(postData.likes.count)"
        if postData.isLiked{
            let buttonImage = UIImage(named: "goodtrue")
            self.likeButton.setImage(buttonImage, for: UIControl.State.normal)
        }else{
            let buttonImage = UIImage(named: "goodfalse")
            self.likeButton.setImage(buttonImage, for: UIControl.State.normal)
        }
        
        
        Database.database().reference().child(Const.categories).child(postData.categoryId!).observe(.value) { (snapshot) in
            let category = Category(snapshot: snapshot)
            self.categoryLabel.text = category.categoryName
            self.categoryLabel.textAlignment = .center
            self.categoryLabel.textColor = UIColor.white
        }
        
        if postData.postImageArray.isEmpty == false{
            let imageUrl:String = postData.postImageArray[0]
            //画像のダウンロード
            let storage = Storage.storage()
            let httpsReference = storage.reference(forURL:imageUrl)
            postImage.sd_setImage(with: URL(string: postData.postImageArray[0]), placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: nil)
        }
        
    }
    
    func setMyPostData(myPostData:PrivatePostsData){
        
        let formatter = DateFormatter()
        formatter.dateFormat =  "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: myPostData.date!)
        self.dateLabel.text  = dateString
        
        self.titleLabel.text = myPostData.title
        
        //self.nameLabel.text = userData.userName
        
        Database.database().reference().child(Const.users).child(myPostData.userId!).observeSingleEvent(of: .value) { (snapshot) in
            let user = Users(snapshot: snapshot)
            self.nameLabel.text = user.userName
        }
        
        self.commentButton.isHidden = true
        
        Database.database().reference().child(Const.categories).child(myPostData.categoryId!).observe(.value) { (snapshot) in
            let category = Category(snapshot: snapshot)
            self.categoryLabel.text = category.categoryName
            self.categoryLabel.textAlignment = .center
            self.categoryLabel.textColor = UIColor.white
        }
        
        
        if myPostData.postImageArray.isEmpty == false{
            let imageUrl:String = myPostData.postImageArray[0]
            let storage = Storage.storage()
            let httpsReference = storage.reference(forURL:imageUrl)
            postImage.sd_setImage(with: URL(string: myPostData.postImageArray[0]), placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: nil)
        }
        
        self.likeLabel.text = "\(myPostData.likes.count)"
        if myPostData.isLiked{
            let buttonImage = UIImage(named: "goodtrue")
            self.likeButton.setImage(buttonImage, for: UIControl.State.normal)
        }else{
            let buttonImage = UIImage(named: "goodfalse")
            self.likeButton.setImage(buttonImage, for: UIControl.State.normal)
        }
    }
}
