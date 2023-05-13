//
//  LoginRegisterViewController.swift
//  ChaChat
//
//  Created by daryl on 2023/5/12.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginRegisterViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var forgotbutton: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // dismiss keyboard after input
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        // how to dismiss keyboard
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentingViewController?.viewWillDisappear(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.viewWillAppear(true)
    }
    

    @IBAction func loginTapped(_ sender: UIButton) {
        if emailTextField.text?.count ?? 0 < 5 {
            emailTextField.backgroundColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 0.5)
            return
        }
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let err = error {
                Utilities().showAlert(title: "error", message: error!.localizedDescription, viewController: self)
                print(err.localizedDescription)
                return
            }
            print("DEBUG logged in !!")
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        // show confirm alert
        let alertVC = UIAlertController(title: "Register", message: "please confirm", preferredStyle: .alert)
        alertVC.addTextField { textField in
            textField.placeholder = "password"
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertVC.addAction(UIAlertAction(title: "OK", style: .default,handler: { action in
            let password = alertVC.textFields![0] as UITextField
            
            if password.text == self.passwordTextField.text {
                // register
                let email = self.emailTextField.text!
                let password = self.passwordTextField.text!
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    // check error
                    if let err = error {
                        Utilities().showAlert(title: "Error", message: err.localizedDescription, viewController: self)
                        return
                    }
                    self.dismiss(animated: true)
                }
            } else {
                Utilities().showAlert(title: "Error", message: "Passwords not the same!!", viewController: self)
            }
        }))
        self.present(alertVC, animated: true) {
            // navigate to view controller
//            let rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "rootViewController")
//            self.present(rootViewController!, animated: true, completion: nil)
            
        }
        
        
    }
    
    @IBAction func forgotTapped(_ sender: UIButton) {
        //
        if !(emailTextField.text?.isEmpty ?? true) {
            // reset password
            Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
                if let err = error {
                    Utilities().showAlert(title: "Error", message: err.localizedDescription, viewController: self)
                    return
                }
                Utilities().showAlert(title: "Success", message: "Please check your email", viewController: self)
            }
            
        }
    }
}
