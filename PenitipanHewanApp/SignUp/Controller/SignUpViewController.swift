//
//  SignUpViewController.swift
//  PenitipanHewanApp
//
//  Created by Ari Gonta on 31/07/20.
//  Copyright © 2020 JOJA. All rights reserved.
//

import UIKit
import CoreData

protocol SignUpViewProtocol: class {
    func errorResponse(error: Error?)
    func showLoading()
    func removeLoading()
}

class SignUpViewController: UIViewController  {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var window: UIWindow?
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var fullnameTft: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var phoneTft: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var selectRole: UITextField!
    @IBOutlet weak var containerButton: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addressTft: UITextField!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var addressStackView: UIStackView!
    
    var loginModel: LoginModel?
    
    var presenter: SignUpPresenterProtocol?
    var activeComponent: UIView?
    var spinner: UIView?
    
    var selectedCountry: String?
    var role = ["customer", "petshop"]
    
    // MARK: - helper
    var pickerHelper: PickerHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        window = appDelegate.window
        presenter = SignUpPresenter(self, window)
        initializeHidKeyboard()
        
        self.navigationController?.navigationBar.topItem?.title = " "
        
        selectRole.delegate = self
        username.delegate = self
        
        // MARK: Configure
        email.placeholder = "Email"
        fullnameTft.placeholder = "Nama Lengkap"
        username.placeholder = "Username"
        phoneTft.placeholder = "No. Handphone"
        password.placeholder = "Password"
        confirmPassword.placeholder = "Confirm Password"
        selectRole.placeholder = "Select Role"
        addressTft.placeholder = "Alamat Petshop"
        self.title = "Sign Up"
        
        // MARK: Style
        buttonSignUp.setButtonMainStyle()
        
        textFields.forEach { (textField) in
            textField.setMainUnderLine()
            textField.delegate = self
        }
        
        containerButton.addDropShadow(to: .top)
        
        createPickerView()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications(scrollView: scrollView, activeComponent: activeComponent)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
//    func saveToCoreData(_ login: LoginModel? = nil) {
//        let context = appDelegate.persistentContainer.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: "Login", in: context)
//        let newUser = NSManagedObject(entity: entity!, insertInto: context)
//
//        newUser.setValue(login?.username, forKey: "username")
//        newUser.setValue(login?.password, forKey: "password")
//        newUser.setValue(login?.role, forKey: "role")
//
//        do {
//            try context.save()
//        } catch {
//            print("Failed saving")
//        }
//    }
    
    @IBAction func buttonSignUp(_ sender: Any) {
        presenter?.validateForm(screen: self)
    }
    
}

// MARK: - textfield delegate
extension SignUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == selectRole {
            return false
        } else if textField == username {
            let text = (textField.text ?? "") as NSString
            let usernameTxt = text.replacingCharacters(in: range, with: string)
            username.text = usernameTxt.trimmingCharacters(in: .whitespacesAndNewlines)
            return false
        } else if textField == password {
            let text = (textField.text ?? "") as NSString
            let passwordTxt = text.replacingCharacters(in: range, with: string)
            password.text = passwordTxt.trimmingCharacters(in: .whitespacesAndNewlines)
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - picker

extension SignUpViewController {
    func createPickerView() {
        pickerHelper = PickerHelper(self, self)
        pickerHelper?.setPicker(textField: selectRole, data: role)
    }
}

extension SignUpViewController: PickerHelperDelegate {
    
    func pickerResult(textField: UITextField, value: String) {
        if textField == selectRole {
            textField.text = value
        }
    }
}

extension SignUpViewController: SignUpViewProtocol {
    func errorResponse(error: Error?) {
        if let newError = error as? ErrorResponse {
            self.showToast(message: newError.messages)
        }
    }
    
    /// Show loading
    func showLoading() {
        self.showSpinner { [weak self] (spinner) in
            guard let self = self else { return }
            self.spinner = spinner
        }
    }
    
    /// remove loading
    func removeLoading() {
        guard let spinner = self.spinner else { return }
        self.removeSpinner(spinner)
    }
}
