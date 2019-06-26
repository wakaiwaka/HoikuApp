//
//  Rating.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/12.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Rating: NSObject {
    //対象年齢のデータ
    var rating:String?

    init(snapshot:DataSnapshot) {
        let valueDictionally = snapshot.value as! [String:Any]
        
        rating = valueDictionally["title"] as? String
    }
}
