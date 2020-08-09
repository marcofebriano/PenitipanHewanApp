//
//  ViewController.swift
//  PenitipanHewanApp
//
//  Created by Ari Gonta on 28/07/20.
//  Copyright © 2020 JOJA. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var window: UIWindow?
    var userDefault = UserDefaults.standard
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        window = appDelegate.window
        
        //MARK: For Checking User
        //        loginModel.forEach { (i) in
        //            print("username: ", i.username ?? "")
        //            print("pass: ", i.password ?? "")
        //            print("role: ", i.role ?? "")
        //        }
        
        // MARK: Configure
        usernameTextField.placeholder = "Username"
        passwordTextField.placeholder = "Password"
        
        // MARK: Style
        loginButton.setButtonMainStyle()
        signUpButton.setButtonMainStyle()
        usernameTextField.setMainUnderLine()
        passwordTextField.setMainUnderLine()
        titleLabel.textColor = ColorHelper.instance.mainGreen
    }
    
    //    func fetchCoreData() {
    //        let context = appDelegate.persistentContainer.viewContext
    //        let fetchLoginModel = NSFetchRequest<NSFetchRequestResult>(entityName: "Login")
    //        do {
    //            let results = try context.fetch(fetchLoginModel) as! [NSManagedObject]
    //            results.forEach { (i) in
    //                loginModel.append(LoginModel(
    //                    username: i.value(forKey: "username") as? String,
    //                    password: i.value(forKey: "password") as? String,
    //                    role: i.value(forKey: "role") as? String)
    //                )
    //            }
    //        } catch {
    //            print("failed")
    //        }
    //    }
    
    func sendLoginRequest(username: String, password: String, completion: ((LoginModel?, Error?) -> Void)? = nil) {
        let loginRequest = LoginService(endpoint: CommonHelper.shared.LOGIN_PATH, username: username, password: password)
        loginRequest.sendRequest(completion: { result in
            switch result {
            case .failure(let err):
                completion?(nil, err)
                break
            case .success(let value):
                completion?(value.data, nil)
            }
        })
    }
    
    @IBAction func loginButton(_ sender: Any) {
        //MARK: For Temporary Checking User
        //        loginModel.forEach { (i) in
        //            if usernameTextField.text == i.username && passwordTextField.text == i.password {
        //                userDefault.set(isLoggedIn, forKey: CommonHelper.shared.isLogin)
        //                userDefault.set(i.role, forKey: CommonHelper.shared.lastRole)
        //                if i.role?.contains("Petshop") ?? false {
        //                    dismissView(weakVar: self) {
        //                        $0.goToPetshopTabbar(window: window)
        //                    }
        //                } else {
        //                    dismissView(weakVar: self) {
        //                        $0.goToUserTabbar(window: window)
        //                    }
        //                }
        //            }
        //        }
        
        guard let window = window else { return }
        if usernameTextField.text != "" && passwordTextField.text != "" {
            
            usernameTextField.setMainUnderLine()
            passwordTextField.setMainUnderLine()
            
            sendLoginRequest(username: usernameTextField.text!, password: passwordTextField.text!) {
                data, err in
                if let error = err {
                    self.openAlert(title: "Warning",
                                   message: "Incorrect Username & Password!",
                                   alertStyle: .alert,
                                   actionTitles: ["Ok"],
                                   actionStyles: [.default],
                                   actions: [
                                    {_ in
                                        print("Ok click")
                                    }
                    ])
                    print(error)
                } else {
                    self.userDefault.set(true, forKey: CommonHelper.shared.isLogin)
                    self.userDefault.set(data?.role, forKey: CommonHelper.shared.lastRole)
                    
                    if data?.role?.contains("Petshop") ?? false {
                        self.dismissView(weakVar: self) {
                            $0.goToPetshopTabbar(window: window)
                        }
                    } else {
                        self.dismissView(weakVar: self) {
                            $0.goToUserTabbar(window: window)
                        }
                    }
                }
            }
        } else {
            usernameTextField.setRedUnderLine()
            passwordTextField.setRedUnderLine()
        }
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "SignUp", bundle: nil)
        if let detailMovieVC = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            self.navigationController?.pushViewController(detailMovieVC, animated: true)
        }
    }
    
    @IBAction func usernameTextField(_ sender: Any) {
        
    }
    
    @IBAction func passwordTextField(_ sender: Any) {
        
    }
}
