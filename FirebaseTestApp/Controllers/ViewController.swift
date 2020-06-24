//
//  ViewController.swift
//  FirebaseTestApp
//
//  Created by AGA TOMOHIRO on 2020/06/18.
//  Copyright © 2020 AGA TOMOHIRO. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD


//登録された情報を辞書方の配列に設定をする
struct User{
    
    let name: String
    let createdAt: Timestamp
    let email: String
    
    init(dic:[String:Any]) {
        self.name = dic["name"] as! String
        self.createdAt = dic["createdAt"] as! Timestamp
        self.email = dic["email"] as! String
    }
    
}


class ViewController: UIViewController {

    @IBOutlet weak var registarButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBAction func tappedregistarButton(_ sender: Any) {
        handleAuthToFireBase()
    }
    
    @IBAction func tappedAlreadyHaveAccountButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    
//    検索をしている間の承認成功かどうかを動かすPKHUDの反応をする関数
    private func handleAuthToFireBase(){
        HUD.show(.progress, onView: view)
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password){(res, err) in
            if let err = err {
                print("認証情報の確認に失敗しました\(err)")
                HUD.hide(){(_)in
                    HUD.flash(.error,delay: 1)
                }
                return
            }
            self.addUserInfoToFirestore(email: email)
        }
    }
    
    
//    情報の書き込みから保存までを一括し行う関数
    private func addUserInfoToFirestore(email:String){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let name = self.userNameTextField.text else {return}
        
        let docData = ["email": email,"name":name,"createdAt":Timestamp()] as [String : Any]
        let userRef = Firestore.firestore().collection("users").document(uid)
        
            userRef.setData(docData){(err)in
            if let err = err{
                print("FireStoreへの確認に失敗しました\(err)")
                HUD.hide(){(_)in
                    HUD.flash(.error,delay: 1)
                }
                return
            }
            
                userRef.getDocument{(Snapshot,err)in
                    if let err = err{
                        print("ユーザー情報の取得に失敗しました\(err)")
                        HUD.hide(){(_)in
                            HUD.flash(.error,delay: 1)
                        }
                        return
                    }
                    guard let data = Snapshot?.data() else{return}
                    let user = User.init(dic: data)
                    print("ユーザー情報の取得ができました\(user.name)")
                    HUD.hide(){(_)in
                        HUD.flash(.success,delay: 1)
                        
                        self.presentToHomeViewController(user: user)
                    }
            }
        }
    }
    
    private func presentToHomeViewController(user: User){
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        
        homeViewController.user =  user
            homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    
//  delegateを設定する、キーボードが反応しているかを確認する
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registarButton.layer.cornerRadius = 10
        registarButton.isEnabled = false
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        userNameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardDidHideNotification, object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
//    キーボードが表示された際に画面と入力画面がかぶらないように設定をする
    @objc func showKeyboard(notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY  else { return }
        let registarButtonMaxY = registarButton.frame.maxY
        let distance = registarButtonMaxY - keyboardMinY + 20
        let tranceform = CGAffineTransform(translationX: 0, y: -distance)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations:{ self.view.transform = tranceform})
    }
//    キーボードを隠したしに元の位置に画面が戻るように設定をする
    @objc func hideKeyboard(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations:{ self.view.transform = .identity})
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}



//テキストフィールドが空かどうかを判定して全てが一文字でも入力された場合にのみボタンの色が変更されるように設定をする
extension ViewController:UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        let userNameIsEmpty = userNameTextField.text?.isEmpty ?? true
        
        
        if emailIsEmpty || passwordIsEmpty || userNameIsEmpty {
            registarButton.isEnabled = false
            registarButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        }else{
            registarButton.isEnabled = true
            registarButton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
        }
    }
}
