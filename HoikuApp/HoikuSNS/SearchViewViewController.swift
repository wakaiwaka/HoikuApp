//
//  SearchViewViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/27.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit

class SearchViewViewController: UIViewController {
    
    
    @IBOutlet weak var searchWardTextLabel: UITextField!
    @IBOutlet weak var categorySegmented: UISegmentedControl!
    @IBOutlet weak var ratingSegmented: UISegmentedControl!
    @IBOutlet weak var requiredSegmented: UISegmentedControl!
    
    
    let categoryArray:[String] = ["","絵本","歌","遊び","製作"]
    let ratingArray:[String] = ["","0~3歳","4歳","5歳","6歳"]
    let requiredTimeArray:[String] = ["","15分","30分","60分","1時間以上"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchWardTextLabel.textAlignment = .center
        searchWardTextLabel.placeholder = "検索ワードを入力してください"
        
        categorySegmented.removeAllSegments()
        categorySegmented.insertSegment(withTitle: "設定なし", at: 0, animated: true)
        categorySegmented.insertSegment(withTitle: "絵本", at: 1, animated: true)
        categorySegmented.insertSegment(withTitle: "歌", at: 2, animated: true)
        categorySegmented.insertSegment(withTitle: "遊び", at: 3, animated: true)
        categorySegmented.insertSegment(withTitle: "製作", at: 4, animated: true)
        categorySegmented.selectedSegmentIndex = 0
        categorySegmented.tintColor = UIColor.orange
        
        ratingSegmented.removeAllSegments()
        ratingSegmented.insertSegment(withTitle: "設定なし", at: 0, animated: true)
        ratingSegmented.insertSegment(withTitle: "0~3歳", at: 1, animated: true)
        ratingSegmented.insertSegment(withTitle: "4歳", at: 2, animated: true)
        ratingSegmented.insertSegment(withTitle: "5歳", at: 3, animated: true)
        ratingSegmented.insertSegment(withTitle: "6歳", at: 4, animated: true)
        ratingSegmented.selectedSegmentIndex = 0
        ratingSegmented.tintColor = UIColor.orange
        
        requiredSegmented.removeAllSegments()
        requiredSegmented.insertSegment(withTitle: "設定なし", at: 0, animated: true)
        requiredSegmented.insertSegment(withTitle: "15分", at: 1, animated: true)
        requiredSegmented.insertSegment(withTitle: "30分", at: 2, animated: true)
        requiredSegmented.insertSegment(withTitle: "60分", at: 3, animated: true)
        requiredSegmented.insertSegment(withTitle: "1時間以上", at: 4, animated: true)
        requiredSegmented.selectedSegmentIndex = 0
        requiredSegmented.tintColor = UIColor.orange
        
        
        let tapGes:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        self.view.addGestureRecognizer(tapGes)
    }
    //キーボードを閉じるメソッド
    @objc func dismissKey(){
        self.view.endEditing(true)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        //サーチワードをキーを決定して画面遷移の際に渡す
        var searchKey:String = ""
        var searchWard:String = ""
        searchWard = conductSearchWard(pickerWard: categoryArray[categorySegmented.selectedSegmentIndex], searchWard: searchWard)
        searchWard = conductSearchWard(pickerWard: ratingArray[ratingSegmented.selectedSegmentIndex], searchWard: searchWard)
        searchWard = conductSearchWard(pickerWard: requiredTimeArray[requiredSegmented.selectedSegmentIndex], searchWard: searchWard)
        
        searchKey = conductSearchKey(searchKey: searchKey, pickerWard: categoryArray[categorySegmented.selectedSegmentIndex], element: "category")
        searchKey = conductSearchKey(searchKey: searchKey, pickerWard: ratingArray[ratingSegmented.selectedSegmentIndex], element: "rating")
        searchKey = conductSearchKey(searchKey: searchKey, pickerWard: requiredTimeArray[requiredSegmented.selectedSegmentIndex], element: "requiredTime")
        
        let searchAllKnowHowViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchAllKnowHow") as! SearchAllKnowHowViewController
        searchAllKnowHowViewController.searchKey = searchKey
        searchAllKnowHowViewController.searchWard = searchWard
        searchAllKnowHowViewController.searchText = searchWardTextLabel.text!
        
        self.navigationController?.pushViewController(searchAllKnowHowViewController, animated: true)
        
    }
    
    private func conductSearchWard(pickerWard:String,searchWard:String) -> String{
        var ward = searchWard
        guard pickerWard.isEmpty else{
            if searchWard.isEmpty == false{
                ward += "_"
            }
            ward += pickerWard
            return ward
        }
        return ward
    }
    
    private func conductSearchKey(searchKey:String,pickerWard:String,element:String) -> String{
        var key = searchKey
        guard pickerWard.isEmpty else{
            if searchKey.isEmpty == false{
                key += "_"
            }
            key += element
            return key
        }
        return key
    }
}

