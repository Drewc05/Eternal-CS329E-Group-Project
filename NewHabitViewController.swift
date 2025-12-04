// Eternal-CS329E-Group-Project
// Group 15
// Created / Edits done by Ori Parks (lwp369)

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class NewHabitViewController: UIViewController {

    var onCreate: ((String, String) -> Void)?

    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Habit name"
        tf.borderStyle = .roundedRect
        return tf
    }()

    private let iconField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "SF Symbol (e.g., flame.fill)"
        tf.borderStyle = .roundedRect
        return tf
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.953, green: 0.918, blue: 0.859, alpha: 1)
        title = "New Habit"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createTapped))

        let stack = UIStackView(arrangedSubviews: [nameField, iconField])
        stack.axis = .vertical
        stack.spacing = 16

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func createTapped() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let icon = iconField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalIcon = (icon?.isEmpty == false) ? icon! : "flame.fill"
        guard !name.isEmpty else { return }
        onCreate?(name, finalIcon)
        dismiss(animated: true)
    }
}
