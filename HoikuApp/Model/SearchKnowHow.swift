//
//  SearchKnowHow.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/10/11.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import Foundation
import RealmSwift

class SearchKnowHow:Object {
    @objc dynamic var postId:String = ""
    @objc dynamic var title:String = ""
    
    override static func primaryKey()-> String?{
        return "postId"
    }
}


