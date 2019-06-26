//
//  AllTaskViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/04.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import CSS3ColorsSwift


class AllTaskViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createTaskButton: UIBarButtonItem!
    @IBOutlet weak var naviBar: UINavigationItem!
    
    let realm = try! Realm()
    var allTaskArray = try! Realm().objects(Task.self).sorted(byKeyPath:"date",ascending:false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.naviBar.title = "メモ"
    }
    
    //タスク作成ボタンを押した時の挙動
    @IBAction func createTaskButtonTapped(_ sender: UIBarButtonItem) {
        //新しいメモのインスタンスを生成する
        let task = Task()
        
        //２回目以降の場合idに１を加える
        if allTaskArray.count != 0{
            task.id = allTaskArray.max(ofProperty: "id")! + 1
        }
        
        let nc = self.storyboard?.instantiateViewController(withIdentifier: "EurekaCreateTaskNavi") as! UINavigationController
        let createTaskViewController = nc.topViewController as! EurekaCreateTaskViewController
        createTaskViewController.task = task
        self.present(nc,animated: true,completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

extension AllTaskViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = allTaskArray[indexPath.row].name
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.string(from: allTaskArray[indexPath.row].date)
        cell.detailTextLabel?.text = dateString
        
        //ふせんの色を決定する
        if allTaskArray[indexPath.row].color == "白"{
            cell.backgroundColor = UIColor.white
        }else if allTaskArray[indexPath.row].color == "赤"{
            cell.backgroundColor = UIColor.tomato
        }else if allTaskArray[indexPath.row].color == "カーキ"{
            cell.backgroundColor = UIColor.khaki
        }else if allTaskArray[indexPath.row].color == "緑"{
            cell.backgroundColor = UIColor.mediumAquamarine
        }else if allTaskArray[indexPath.row].color == "水色"{
            cell.backgroundColor = UIColor.lightBlue
        }
        
        if allTaskArray[indexPath.row].color == "白"{
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        }else{
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
        }
        
        let calendar = Calendar.current
        
        let day = Date()
        
        //期限が過ぎている場合には文字を警告の赤色にする
        let today = calendar.startOfDay(for: day)
        if allTaskArray[indexPath.row].date < today{
            cell.detailTextLabel?.textColor = UIColor.red
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTaskArray.count
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let center = UNUserNotificationCenter.current()
            let task = self.allTaskArray[indexPath.row]
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            try! realm.write {
                realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルが選択された場合詳細画面に画面遷移する
        let editTaskViewController = self.storyboard?.instantiateViewController(withIdentifier: "EurekaEditTask") as! EurekaEditTaskViewController
        editTaskViewController.task = allTaskArray[indexPath.row]
        self.navigationController?.pushViewController(editTaskViewController, animated: true)
    }
}

