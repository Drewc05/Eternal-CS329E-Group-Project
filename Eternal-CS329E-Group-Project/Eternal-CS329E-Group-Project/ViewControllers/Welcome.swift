//
//  Welcome.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//

import UIKit

class Welcome: UIViewController {

    @IBOutlet weak var gradientView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.953, green: 0.918, blue: 0.859, alpha: 1)

        // Do any additional setup after loading the view.
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.BG.cgColor, UIColor.accent2.cgColor, UIColor.accent.cgColor]
        self.gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func onLogInPressed(_ sender: Any) {

    }
    
    @IBAction func onSignUpPressed(_ sender: Any) {
    }
}
