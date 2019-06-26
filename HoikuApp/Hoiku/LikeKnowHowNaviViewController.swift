//
//  LikeKnowHowNaviViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/10/26.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class LikeKnowHowNaviViewController: UINavigationController,IndicatorInfoProvider  {
    
    private var itemInfo: IndicatorInfo = "人気順"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
