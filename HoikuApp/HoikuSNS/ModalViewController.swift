//
//  ModalViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/10/26.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var modalView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = "アカウントの作成・ログインすると記事の投稿、他のユーザーの投稿を見ることができるようになります！マイページからアカウント作成・ログインしよう！"
        textLabel.backgroundColor = UIColor.orange
        textLabel.textColor = UIColor.white
        modalView.backgroundColor = UIColor.orange
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
