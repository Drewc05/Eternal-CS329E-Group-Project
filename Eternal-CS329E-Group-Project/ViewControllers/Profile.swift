//
//  Profile.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//

import SwiftUI
import UIKit
import FirebaseCore
import FirebaseAuth

class Profile: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let store = HabitStore.shared
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }

    private enum Row: Int, CaseIterable {
        case theme
        case notifications
        case signOut
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.background
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = UIListContentConfiguration.valueCell()
        switch Row(rawValue: indexPath.row)! {
        case .theme:
            config.text = "Theme"
            config.secondaryText = store.settings.themeKey.capitalized
            config.textProperties.color = theme.text
            config.secondaryTextProperties.color = theme.secondaryText
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
        case .notifications:
            config.text = "Notifications"
            // Leave default text color
            let toggle = UISwitch()
            toggle.isOn = store.settings.notificationsEnabled
            toggle.addTarget(self, action: #selector(toggleNotifications(_:)), for: .valueChanged)
            toggle.onTintColor = theme.primary
            cell.accessoryView = toggle
            cell.accessoryType = .none
        case .signOut:
            config.text = "Sign Out"
            config.textProperties.color = .accent
            cell.textLabel?.textAlignment = .center
            cell.accessoryView = nil
            cell.accessoryType = .none
        }
        cell.contentConfiguration = config
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Row(rawValue: indexPath.row)! {
        case .theme:
            let alert = UIAlertController(title: "Theme", message: "Choose a theme (placeholder)", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Default", style: .default, handler: { _ in
                self.store.setThemeKey("default")
                self.view.backgroundColor = self.theme.background
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Dark", style: .default, handler: { _ in
                self.store.setThemeKey("dark")
                self.view.backgroundColor = self.theme.background
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        case .notifications:
            break
        case .signOut:
            let alert = UIAlertController(title: "Really sign out?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            let signOutAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
                do {
                    try Auth.auth().signOut()
                    self.dismiss(animated: true)
                } catch {
                    alert.message = "Sign Out Error"
                }
            }
            alert.addAction(signOutAction)
            present(alert, animated: true)
        }
    }

    @objc private func toggleNotifications(_ sender: UISwitch) {
        store.setNotificationsEnabled(sender.isOn)
    }
}

