//
//  HomeViewController.swift
//  FirebaseTestApp
//
//  Created by AGA TOMOHIRO on 2020/06/19.
//  Copyright © 2020 AGA TOMOHIRO. All rights reserved.
//
import Foundation
import UIKit
import Firebase
import FirebaseAuth

class HomeViewController: UIViewController {

    var user:User?{
        didSet {
            print("user?.name",user?.name)
        }
    }
    
    
    @IBAction func didTapMenuButton(_ sender: UIBarButtonItem) {
        guard let menuViewController = storyboard?.instantiateViewController(identifier: "MenuTableViewController") else {return}
        present(menuViewController,animated: true)
        
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func tappedLogOutButton(_ sender: Any) {
        handleLogout()
    }
    
    
//    ログアウトをする
    private func handleLogout(){
        do{
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        }catch (let err){
            print("ログアウトに失敗しました\(err)")
        }
    }
    
//    ViewControllerから受けた値を元にして表示をする
    override func viewDidLoad() {
        super.viewDidLoad()

        logoutButton.layer.cornerRadius=10
        
        if let user = user{
        nameLabel.text = user.name + "さんようこそ"
        emailLabel.text = user.email
            
            let dateString = dataFormatterForCreateAt(date: user.createdAt.dateValue())
            dateLabel.text = "作成日：" + dateString
        // Do any additional setup after loading the view.
    
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        comfilmLoginedInUser()
    }
    
   private func comfilmLoginedInUser(){
   if Auth.auth().currentUser?.uid == nil || user == nil{
        presentToViewController()
        }
    }
    
    private func presentToViewController(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(identifier: "ViewController") as! ViewController
        let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    private func dataFormatterForCreateAt(date:Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

}
