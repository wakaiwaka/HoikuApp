//
//  DetailKnowHowViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/30.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseUI
import SDWebImage

class DetailKnowHowViewController: UIViewController {
    
    var postData:PostData!
    private var myPostData:PrivatePostsData!
    
    private var nowTagNumber:Int = 1
    
    @IBOutlet weak var postImage1: UIImageView!
    @IBOutlet weak var postImage2: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var requiredTimeLabel: UILabel!
    
    @IBOutlet weak var titleNameLabel: UILabel!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var ratingTitleLabel: UILabel!
    @IBOutlet weak var requiredTimeTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    private func setUpView(){
        //詳細画面のviewの設定
        let ref = Database.database().reference()
        
        titleLabel.layer.borderWidth = 1
        titleLabel.layer.borderColor = UIColor.lightGray.cgColor
        titleLabel.backgroundColor = UIColor.white
        titleLabel.layer.masksToBounds = true
        if let title = postData.title{
            titleLabel.text = title
        }else{
            titleLabel.text = ""
        }

         ratingLabel.layer.borderColor = UIColor.lightGray.cgColor
        ratingLabel.layer.borderWidth = 1
        ratingLabel.backgroundColor = UIColor.white
        //年齢をlabelに代入
        if postData.rateId!.isEmpty == false{
            let ratingRef = ref.child(Const.rating).child(postData.rateId!)
            ratingRef.observeSingleEvent(of: .value) { (snapshot) in
                let rating = Rating(snapshot: snapshot)
                self.ratingLabel.text = rating.rating
            }
        }else{
            self.ratingLabel.text = ""
        }
        
        
        detailLabel.layer.borderWidth = 1
        detailLabel.layer.borderColor = UIColor.lightGray.cgColor
        detailLabel.backgroundColor = UIColor.white
        if let detail = postData.detail{
            detailLabel.text = detail
        }else{
            detailLabel.text = ""
        }
        
        categoryLabel.layer.borderWidth = 1
        categoryLabel.layer.borderColor = UIColor.lightGray.cgColor
        categoryLabel.backgroundColor = UIColor.white
        //カテゴリーの名前をlabelに代入
        if postData.categoryId!.isEmpty == false{
            let categoryRef = ref.child(Const.categories).child(postData.categoryId!)
            categoryRef.observeSingleEvent(of: .value,with: { (snapshot) in
                let category = Category(snapshot: snapshot)
                self.categoryLabel.text = category.categoryName
            })
        }else{
            self.categoryLabel.text = ""
        }
        
        requiredTimeLabel.layer.borderWidth = 1
        requiredTimeLabel.layer.borderColor = UIColor.lightGray.cgColor
        requiredTimeLabel.backgroundColor = UIColor.white
        requiredTimeLabel.layer.masksToBounds = true
        //所要時間をlabelに代入
        if postData.requiredTimeId!.isEmpty == false{
            let requiredTimeRef = ref.child(Const.requiredTime).child(postData.requiredTimeId!)
            requiredTimeRef.observeSingleEvent(of: .value) { (snapshot) in
                let requiredTime = RequiredTime(snapshot: snapshot)
                self.requiredTimeLabel.text = requiredTime.reuquiredTime
            }
        }else{
            self.requiredTimeLabel.text = ""
        }
        
        titleNameLabel.layer.borderWidth = 1
        titleNameLabel.layer.borderColor = UIColor.lightGray.cgColor
        titleNameLabel.textColor = UIColor.darkGray
        titleNameLabel.layer.masksToBounds = true
        
        detailTitleLabel.layer.borderWidth = 1
        detailTitleLabel.layer.borderColor = UIColor.lightGray.cgColor
        detailTitleLabel.textColor = UIColor.darkGray
        
        categoryTitleLabel.layer.borderWidth = 1
        categoryTitleLabel.layer.borderColor = UIColor.lightGray.cgColor
        categoryTitleLabel.textColor = UIColor.darkGray
        
        ratingTitleLabel.layer.borderWidth = 1
        ratingTitleLabel.layer.borderColor = UIColor.orange.cgColor
        ratingTitleLabel.layer.borderColor = UIColor.lightGray.cgColor
        ratingTitleLabel.textColor = UIColor.darkGray
        
        requiredTimeTitleLabel.layer.borderWidth = 1
        requiredTimeTitleLabel.layer.borderColor = UIColor.orange.cgColor
        requiredTimeTitleLabel.layer.borderColor = UIColor.lightGray.cgColor
        requiredTimeTitleLabel.textColor = UIColor.darkGray
        requiredTimeTitleLabel.layer.masksToBounds = true
        
        //画像がないUIImageViewの背景の色をグレーにする
        postImage1.backgroundColor = UIColor.gray
        postImage2.backgroundColor = UIColor.gray
        //Firebaseから画像をダウンロードpostImageArrayの数で場合分け
        if postData.postImageArray.count == 1{
            downLoadImage(num: 0, postImage: postImage1)
        }else if postData.postImageArray.count == 2{
            downLoadImage(num: 0, postImage: postImage1)
            downLoadImage(num: 1, postImage: postImage2)
        }
    }
    
    //Firebaseから写真をダウンロードしてpostImageに代入する
    private func downLoadImage(num:Int,postImage:UIImageView){
        if num == 0{
            postImage.sd_setImage(with: URL(string: postData.postImageArray[0]), placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: nil)
        }else{
            postImage.sd_setImage(with: URL(string: postData.postImageArray[1]), placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: nil)
        }
    }
}
