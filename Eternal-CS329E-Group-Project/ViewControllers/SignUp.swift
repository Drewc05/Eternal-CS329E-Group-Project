//
//  Login.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class SignUp: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var confirmPWField: UITextField!
    @IBOutlet weak var visibilityButton: UIButton!
    @IBOutlet weak var visibilityButton2: UIButton!
    
    let smallEyeImage = UIImage(systemName: "eye", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
    let smallEyeSlashImage = UIImage(systemName: "eye.slash", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener() { ( auth, user ) in
            if user != nil {
                self.performSegue(withIdentifier: "Signup2Nav", sender: nil)
                self.emailField.text = nil
                self.pwField.text = nil
            }
        }
        updateVisibility()
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        if !emailField.hasText || !pwField.hasText || !confirmPWField.hasText {
            let alertController = UIAlertController(title: "Couldn't Sign Up",
                                                        message: "One or more fields are empty",
                                                        preferredStyle: .alert)
            let action1 = UIAlertAction(title: "OK", style: .default) { _ in
                }
            
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if pwField.text!.count < 6 {
            let alertController = UIAlertController(title: "Couldn't Sign Up",
                                                        message: "Password must be 6 or more characters",
                                                        preferredStyle: .alert)
            let action1 = UIAlertAction(title: "OK", style: .default) { _ in
                }
            
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if pwField.text! != confirmPWField.text! {
            let alertController = UIAlertController(title: "Couldn't Sign Up",
                                                        message: "Passwords don't match",
                                                        preferredStyle: .alert)
            let action1 = UIAlertAction(title: "OK", style: .default) { _ in
                }
            
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        Auth.auth().createUser(withEmail: emailField.text!, password: pwField.text!) { (result, error) in
            if let error = error as NSError? {
                let alertController = UIAlertController(title: "Couldn't Sign Up",
                                                        message: error.localizedDescription,
                                                        preferredStyle: .alert)
                let action1 = UIAlertAction(title: "OK", style: .default) { _ in
                }
                alertController.addAction(action1)
            } else {
                
            }
        }
    }
    
    
    @IBAction func onVisibility(_ sender: Any) {
        toggleVisibility()
    }
    
    @IBAction func onVisibility2(_ sender: Any) {
        toggleVisibility()
    }
    
    func toggleVisibility(){
        pwField.isSecureTextEntry = !pwField.isSecureTextEntry
        confirmPWField.isSecureTextEntry = pwField.isSecureTextEntry
        updateVisibility()
    }
    
    func updateVisibility(){
        if pwField.isSecureTextEntry {
            visibilityButton.setImage(smallEyeImage, for: UIControl.State.normal)
            visibilityButton2.setImage(smallEyeImage, for: UIControl.State.normal)
        } else {
            visibilityButton.setImage(smallEyeSlashImage, for: UIControl.State.normal)
            visibilityButton2.setImage(smallEyeSlashImage, for: UIControl.State.normal)
        }
    }
}
