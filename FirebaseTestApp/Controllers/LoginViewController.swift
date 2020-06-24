//
//  LoginViewController.swift
//  FirebaseTestApp
//
//  Created by AGA TOMOHIRO on 2020/06/19.
//  Copyright © 2020 AGA TOMOHIRO. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBotton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    @IBAction func tappedDontHaveAccountButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedLoginButton(_ sender: Any) {
        handleAuthToFireBase()
    }
    
    private func handleAuthToFireBase(){
        HUD.show(.progress,onView: view)
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password){(res,err) in
            if let err = err{
                print("ログイン情報の取得に失敗しました\(err)")
                HUD.hide(){(_)in
                HUD.flash(.error,delay: 1)
                }
                return
            }
                print("ログインに成功しました")
            
             guard let uid = Auth.auth().currentUser?.uid else {return}
            let userRef = Firestore.firestore().collection("users").document(uid)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self

        loginBotton.layer.cornerRadius = 10
        loginBotton.isEnabled = false
        loginBotton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        // Do any additional setup after loading the view.
    }
    
}
    extension LoginViewController:UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        
        
        if emailIsEmpty || passwordIsEmpty {
            loginBotton.isEnabled = false
            loginBotton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        }else{
            loginBotton.isEnabled = true
            loginBotton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
            }
        }
    }
