//
//  Login.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class Login: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    
    @IBOutlet weak var visibilityButton: UIButton!
    
    let smallEyeImage = UIImage(systemName: "eye", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
    let smallEyeSlashImage = UIImage(systemName: "eye.slash", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener() { ( auth, user ) in
            if user != nil {
                self.performSegue(withIdentifier: "Login2Nav", sender: nil)
                self.emailField.text = nil
                self.pwField.text = nil
            }
            
        }
        updateVisibility()
    }
    @IBAction func onLogIn(_ sender: Any) {
        if emailField.state.isEmpty || pwField.state.isEmpty {
            DisplayInsufficentDetailsAlert()
            return
        }
        
        Auth.auth().signIn(withEmail: emailField.text!, password: pwField.text!) {
            ( result, error ) in
            if let error = error as NSError? {
                self.DisplayLoginErrorAlert(errorMessage: error.localizedDescription)
            } else {
            
            }
        }
        
    }
    
    @IBAction func onForgotPW(_ sender: Any) {
        forgotPassword()
    }
    
    func DisplayInsufficentDetailsAlert(){
        let alertController = UIAlertController(title: "Insufficent Details",
                                                    message: "We cannot log you in at this time. One or more log in fields are empty",
                                                    preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default) { _ in
            }
        
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func DisplayLoginErrorAlert(errorMessage: String){
        let alertController = UIAlertController(title: "Login Error",
                                                    message: errorMessage,
                                                    preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default) { _ in
            }
        
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func forgotPassword(){
        let alertController = UIAlertController(title: "Function Unavailable",
                                                    message: "Forgot Password is unavailable at this time. Tough luck buddy.",
                                                    preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Alright...", style: .default) { _ in
            }
        
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onVisibility(_ sender: Any) {
        toggleVisibility()
    }
    
    func toggleVisibility(){
        pwField.isSecureTextEntry = !pwField.isSecureTextEntry
        updateVisibility()
    }
    
    func updateVisibility(){
        if pwField.isSecureTextEntry {
            visibilityButton.setImage(smallEyeImage, for: UIControl.State.normal)
        } else {
            visibilityButton.setImage(smallEyeSlashImage, for: UIControl.State.normal)
        }
    }
}
