//
//  Login.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//

import UIKit

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
        updateVisibility()
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        
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
