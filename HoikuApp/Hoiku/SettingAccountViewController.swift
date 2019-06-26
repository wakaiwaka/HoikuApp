//
//  SettingAccountViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/10/03.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import MessageUI
import Firebase
import FirebaseAuth
import CSS3ColorsSwift

class SettingAccountViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate{
    
    var myPagesArray:[String] = ["プライベート投稿","いいね一覧"]
    var settingArray:[String] = ["アカウント名変更・ログアウト"]
    var sectionArray:[String] = ["マイページ","設定"]
    
    @IBOutlet weak var naviBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        naviBar.title = "マイページ"
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //画面遷移した後にcellの選択を解除する
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArray[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.groupTableViewBackground
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //セクションの配列の1つ目の場合にはマイページのセクションを設置する
        if section == 0{
            return myPagesArray.count
        }else if section == 1{
            //セクションの配列の2つ目の場合には設定のセクションを設置する
            return settingArray.count
        }else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.section == 0{
            cell.textLabel?.text = myPagesArray[indexPath.row]
            cell.textLabel?.textColor = UIColor.black
        }else if indexPath.section == 1{
            cell.textLabel?.text = settingArray[indexPath.row]
            cell.textLabel?.textColor = UIColor.black
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if myPagesArray[indexPath.row] == "プライベート投稿"{
                let myPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyPost") as! MyPostViewController
                self.navigationController?.pushViewController(myPostViewController, animated: true)
            }else if myPagesArray[indexPath.row] == "いいね一覧"{
                let myLikeViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyLike") as! MyLikeViewController
                self.navigationController?.pushViewController(myLikeViewController, animated: true)
            }
        }else{
            let changeAccountViewController = self.storyboard?.instantiateViewController(withIdentifier: "Change") as! ChangeAccountViewController
            self.navigationController?.pushViewController(changeAccountViewController, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("キャンセル")
            break
        case .sent:
            print("送信")
        case .saved:
            print("保存")
        case .failed:
            print("失敗")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
