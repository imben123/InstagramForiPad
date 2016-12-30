//
//  LoginViewController.swift
//  Instagram
//
//  Created by Ben Davis on 29/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import UIKit
import InstagramData
import SwiftToolbox

class LoginViewController: UIViewController {
    
    let usernameField: UITextField = LoginViewController.createEmailField()
    let passwordField: UITextField = LoginViewController.createPasswordField()
    let loginButton: UIButton = LoginViewController.createLoginButton()
    
    let kTopMargin: CGFloat = 60
    let kVerticalSpacing: CGFloat = 20
    let kFieldWidth: CGFloat = 260
    let kFieldHeight: CGFloat = 44
    static let kFieldInnerPadding: CGFloat = 8
    
    static let kButtonColor: UIColor = .blue
    static let kSelectedButtonColor: UIColor = UIColor.blue.withAlphaComponent(0.6)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.loginButton.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func createEmailField() -> UITextField {
        let result = createTextField()
        result.keyboardType = .emailAddress
        result.placeholder = "email"
        return result
    }
    
    class func createPasswordField() -> UITextField {
        let result = createTextField()
        result.isSecureTextEntry = true
        result.keyboardType = .default
        result.placeholder = "password"
        return result
    }
    
    class func createTextField() -> UITextField {
        let result = UITextField()
        result.layer.borderColor = UIColor.black.cgColor
        result.layer.borderWidth = 1.0
        result.leftView = UIView(frame: CGRect(x: 0, y: 0, width: kFieldInnerPadding, height: 0))
        result.leftViewMode = .always
        result.rightView = UIView(frame: CGRect(x: 0, y: 0, width: kFieldInnerPadding, height: 0))
        result.rightViewMode = .always
        return result
    }
    
    class func createLoginButton() -> UIButton {
        let result = UIButton()
        result.setTitle("Log in", for: .normal)
        result.setTitle("Logging in...", for: .selected)
        result.setTitleColor(kButtonColor, for: .normal)
        result.setTitleColor(kSelectedButtonColor, for: .selected)
        result.layer.borderColor = kButtonColor.cgColor
        result.layer.borderWidth = 1.0
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(usernameField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        usernameField.frame = CGRect(x: view.width*0.5 - kFieldWidth*0.5,
                                     y: kTopMargin + topLayoutGuide.length,
                                     width: kFieldWidth,
                                     height: kFieldHeight)
        
        passwordField.frame = CGRect(x: usernameField.originX,
                                     y: usernameField.bottomY + kVerticalSpacing,
                                     width: usernameField.width,
                                     height: usernameField.height)
        
        loginButton.frame = usernameField.frame
        loginButton.originY = passwordField.bottomY + kVerticalSpacing
    }
    
    @objc func loginPressed() {
        self.setInteractionEnabled(false)
        
        InstagramData.shared.authManager.login(
            username: self.usernameField.text!,
            password: self.passwordField.text!,
            completion: { [weak self] in
                self?.setInteractionEnabled(true)
                self?.navigationController?.pushViewController(ViewController(), animated: true)
            }, failure:  { [weak self] in
                self?.setInteractionEnabled(true)
                self?.showAlert(withTitle: "Login Failed", message: "Please try again")
            }
        )
    }
    
    private func setInteractionEnabled(_ interactionEnabled: Bool) {
        usernameField.isUserInteractionEnabled = interactionEnabled
        passwordField.isUserInteractionEnabled = interactionEnabled
        loginButton.isUserInteractionEnabled = interactionEnabled
        loginButton.isSelected = !interactionEnabled
        if interactionEnabled {
            loginButton.layer.borderColor = LoginViewController.kButtonColor.cgColor
        } else {
            loginButton.layer.borderColor = LoginViewController.kSelectedButtonColor.cgColor
        }
    }
    
}
