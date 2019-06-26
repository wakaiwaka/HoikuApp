//
//  EurekaSearchViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/12/08.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import Eureka

class EurekaSearchViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            +++ Section("検索ワード")
            <<< TextRow{row in
                row.placeholder = "検索ワードを入力してください"
                row.tag = "searchWard"
                row.value = ""
            }
            +++ Section("カテゴリ")
            <<< SegmentedRow<String>(){row in
                row.tag = "category"
                row.options = ["なし","絵本","歌","遊び","製作"]
                row.value = "設定"
            }
            
            +++ Section("対象年齢")
            <<< SegmentedRow<String>(){row in
                row.tag = "rating"
                row.options = ["なし","0~3歳","4歳","5歳","6歳"]
                row.value = "設定"
            }
            
            +++ Section("所要時間")
            <<< SegmentedRow<String>(){row in
                row.tag = "requiredTime"
                row.options = ["なし","15分","30分","60分","1時間~"]
                row.value = "設定"
        }
    }
    
    
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        //サーチワードをキーを決定して画面遷移の際に渡す
        var searchKey:String = ""
        var searchWard:String = ""
        
        //検索ワードを決定する
        searchWard = conductSearchWard(pickerWard: form.rowBy(tag: "category") as! SegmentedRow<String>, searchWard: searchWard)
        searchWard = conductSearchWard(pickerWard: form.rowBy(tag: "rating") as! SegmentedRow<String>, searchWard: searchWard)
        searchWard = conductSearchWard(pickerWard: form.rowBy(tag: "requiredTime") as! SegmentedRow<String>, searchWard: searchWard)
        
        //検索キーを決定する
        searchKey = conductSearchKey(searchKey: searchKey, pickerWard: form.rowBy(tag: "category") as! SegmentedRow<String>, element: "category")
        searchKey = conductSearchKey(searchKey: searchKey, pickerWard: form.rowBy(tag: "rating") as! SegmentedRow<String>, element: "rating")
        searchKey = conductSearchKey(searchKey: searchKey, pickerWard: form.rowBy(tag: "requiredTime") as! SegmentedRow<String>, element: "requiredTime")
        
        let searchAllKnowHowViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchAllKnowHow") as! SearchAllKnowHowViewController
        searchAllKnowHowViewController.searchKey = searchKey
        searchAllKnowHowViewController.searchWard = searchWard
        if let text = (form.rowBy(tag: "searchWard") as! TextRow).value{
            searchAllKnowHowViewController.searchText = text
        }
    self.navigationController?.pushViewController(searchAllKnowHowViewController, animated: true)
        
    }
    
    //保存する検索ワードを決定する
    private func conductSearchWard(pickerWard:SegmentedRow<String>,searchWard:String) -> String{
        var ward = searchWard
        guard pickerWard.value == "なし" else{
            if searchWard.isEmpty == false{
                ward += "_"
            }
            ward += pickerWard.value!
            return ward
        }
        return ward
    }
    
    //保存する検索キーを決定する
    private func conductSearchKey(searchKey:String,pickerWard:SegmentedRow<String>,element:String) -> String{
        var key = searchKey
        guard pickerWard.value == "なし" else{
            if searchKey.isEmpty == false{
                key += "_"
            }
            key += element
            return key
        }
        return key
    }
    
    
}
