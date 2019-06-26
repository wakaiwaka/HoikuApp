//
//  PrivatePostsData.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/19.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class PrivatePostsData: NSObject {
    var postId:String?
    var title:String?
    var detail:String?
    var date:Date?
    var isLiked:Bool = false
    var likes:[String] = []
    var share:String? = "false"
    
    //写真のurl
    var postImageArray:[String] = []
    
    //対象年齢のID
    var rateId:String?
    
    //カテゴリーのID
    var categoryId:String?
    
    //所要時間のID
    var requiredTimeId:String?
    
    //必要な材料
    var requiredMaterial:String?
    
    //投稿したユーザーのID
    var userId:String?
    
    //検索用のワード
    var searchWord:String?
    
    
    init(snapshot:DataSnapshot,myId:String) {
        self.postId = snapshot.key
        let valueDictionally = snapshot.value as! [String:Any]
        
        title = valueDictionally["title"] as? String
        detail = valueDictionally["detail"] as? String
        
        let time = valueDictionally["time"] as? String
        date = Date(timeIntervalSinceReferenceDate: TimeInterval(time!)!)
        
        if let postImageArray = valueDictionally["postImageArray"] as? [String]{
            self.postImageArray = postImageArray
        }
        
        rateId = valueDictionally["rateId"] as? String
        
        categoryId = valueDictionally["categoryId"] as? String
        
        userId = valueDictionally["userId"] as? String
        
        requiredTimeId = valueDictionally["requiredTimeId"] as? String
        
        searchWord = valueDictionally["searchWord"] as? String
        
        share = valueDictionally["share"] as? String
        
        requiredMaterial = valueDictionally["requiredMaterialId"] as? String
        
        if let likes = valueDictionally["likes"] as? [String]{
            self.likes = likes
        }
        
        for likeId in likes{
            if likeId == myId{
                self.isLiked = true
                break
            }
        }
    }
}
