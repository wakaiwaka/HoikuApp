//
//  MainViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/10/26.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import XLPagerTabStrip

class MainViewController: ButtonBarPagerTabStripViewController {
    
    override func viewDidLoad() {
        //XLPagerTabStripの部品の設定
        
        settings.style.buttonBarBackgroundColor = UIColor.white
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = UIColor.white
        //セルの文字色
        settings.style.buttonBarItemTitleColor = UIColor.orange
        //セレクトバーの色
        settings.style.selectedBarBackgroundColor = UIColor.orange
        
        if Auth.auth().currentUser == nil{
            let loginAccountNavi = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountNavi") as! UINavigationController
            let loginAccountViewController = loginAccountNavi.topViewController as! LoginAccountViewController
            self.present(loginAccountNavi,animated: true,completion: nil)
        }
        
        super.viewDidLoad()
    }
    
    //みんなの投稿を構成する画面をXLPagerTabStripを利用してまとめる
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let allKnowHowNavi = self.storyboard?.instantiateViewController(withIdentifier: "AllKnowHowNavi") as! UINavigationController
        
        let allKnowHowViewController = allKnowHowNavi.topViewController as! AllKnowHowViewController
        
        let searchKnowHowNavi = self.storyboard?.instantiateViewController(withIdentifier: "searchKnowHowNavi") as! UINavigationController
        
        let searchViewController = searchKnowHowNavi.topViewController as! EurekaSearchViewController
        
        let likeKnowHowNavi = self.storyboard?.instantiateViewController(withIdentifier: "likeKnowHow") as! UINavigationController
        
        let likeKnowHowViewqController = likeKnowHowNavi.topViewController as! LikeKnowHowViewController
        
        let createKnowHowNavi = self.storyboard?.instantiateViewController(withIdentifier: "CreatePostNavigationController") as! UINavigationController
        
        let createKnowHowViewController = createKnowHowNavi.topViewController as! CreateKnowHowViewController
        
        let childViewControllers = [allKnowHowNavi,likeKnowHowNavi,createKnowHowNavi,searchKnowHowNavi]
        return childViewControllers
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil{
            let loginAccountNavi = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountNavi") as! UINavigationController
            let loginAccountViewController = loginAccountNavi.topViewController as! LoginAccountViewController
            self.present(loginAccountNavi,animated: true,completion: nil)
        }
    }
    
}
