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
        case changePassword
        case deleteAccount
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.background
        title = "Profile"
        
        let titleLabel = UILabel()
        titleLabel.text = "Profile"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        navigationItem.titleView = titleLabel

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
            if store.settings.notificationsEnabled {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                let date = Calendar.current.date(bySettingHour: store.settings.notificationHour,
                                                  minute: store.settings.notificationMinute,
                                                  second: 0,
                                                  of: Date()) ?? Date()
                config.secondaryText = formatter.string(from: date)
            } else {
                config.secondaryText = "Off"
            }
            config.textProperties.color = theme.text
            config.secondaryTextProperties.color = theme.secondaryText
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
        case .signOut:
            config.text = "Sign Out"
            config.textProperties.color = .systemRed
            cell.accessoryView = nil
            cell.accessoryType = .none
        case .changePassword:
            config.text = "Change Password"
            config.textProperties.color = .systemRed
            cell.accessoryView = nil
            cell.accessoryType = .none
        case .deleteAccount:
            config.text = "Delete Account"
            config.textProperties.color = .systemRed
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
            let alert = UIAlertController(title: "Theme", message: "Choose a theme", preferredStyle: .actionSheet)
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
            showNotificationTimePicker()
        case .signOut:
            let alert = UIAlertController(title: "Really sign out?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            let signOutAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
                do {
                    try Auth.auth().signOut()
                    self.dismiss(animated: true)
                } catch {
                    let errorAlert = UIAlertController(title: "Sign Out Error", message: error.localizedDescription, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
            alert.addAction(signOutAction)
            present(alert, animated: true)
        case .changePassword:
            changePassword()
        case .deleteAccount:
            showDeleteAccountConfirmation()
        }
    }

    private func showNotificationTimePicker() {
        let alert = UIAlertController(title: "Daily Reminder", message: "\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        
        let initialDate = Calendar.current.date(bySettingHour: store.settings.notificationHour,
                                                  minute: store.settings.notificationMinute,
                                                  second: 0,
                                                  of: Date()) ?? Date()
        datePicker.date = initialDate
        
        alert.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 65),
            datePicker.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: -16)
        ])
        
        let enableAction = UIAlertAction(title: "Enable", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let components = Calendar.current.dateComponents([.hour, .minute], from: datePicker.date)
            let hour = components.hour ?? 20
            let minute = components.minute ?? 0
            
            NotificationManager.shared.requestAuthorization { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.store.setNotificationsEnabled(true)
                    self.store.setNotificationTime(hour: hour, minute: minute)
                    NotificationManager.shared.scheduleDailyReminder(at: hour, minute: minute)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    self.showNotificationDeniedAlert()
                }
            }
        }
        
        let disableAction = UIAlertAction(title: "Disable", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.store.setNotificationsEnabled(false)
            NotificationManager.shared.cancelAllNotifications()
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(enableAction)
        if store.settings.notificationsEnabled {
            alert.addAction(disableAction)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showNotificationDeniedAlert() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please enable notifications in Settings to receive daily reminders.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func changePassword() {
        guard let email = Auth.auth().currentUser?.email else {
            let alert = UIAlertController(
                title: "Error",
                message: "Unable to retrieve your email address.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Failed to send password reset email: \(error.localizedDescription)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(
                    title: "Success!",
                    message: "Password reset email sent to \(email)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Thanks", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    private func showDeleteAccountConfirmation() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "This will permanently delete your account and all your data. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteAccount()
        }
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        let loadingAlert = UIAlertController(title: "Deleting Account...", message: "Please wait", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        store.deleteAllUserData(uid: uid) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                user.delete { error in
                    loadingAlert.dismiss(animated: true) {
                        if let error = error {
                            let errorAlert = UIAlertController(
                                title: "Error",
                                message: "Failed to delete account: \(error.localizedDescription). You may need to sign in again to delete your account.",
                                preferredStyle: .alert
                            )
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(errorAlert, animated: true)
                        } else {
                            self.dismiss(animated: true)
                        }
                    }
                }
            } else {
                loadingAlert.dismiss(animated: true) {
                    let errorAlert = UIAlertController(
                        title: "Error",
                        message: "Failed to delete user data. Please try again.",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
        }
    }
}
