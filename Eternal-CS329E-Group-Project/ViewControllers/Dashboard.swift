//
//  Dashboard.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//
//  Edited by Ori Parks

import SwiftUI
import UIKit
import FirebaseAuth

class Dashboard: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    private let store = HabitStore.shared
    private var pendingQueue: [Habit] = []
    private var collectionView: UICollectionView!
    
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = theme.background
        ThemeManager.styleNavBar(navigationController?.navigationBar, theme: theme)
        self.title = "Home"
        
        navigationController?.navigationBar.tintColor = theme.primary
        
        let titleLabel = UILabel()
        titleLabel.text = "Home"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.textAlignment = .center
        titleLabel.textColor = theme.text
        navigationItem.titleView = titleLabel

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addHabitTapped))

        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DashboardHabitItemCell.self, forCellWithReuseIdentifier: DashboardHabitItemCell.reuseID)
        collectionView.register(DashboardHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DashboardHeaderView.reuseID)

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(habitDataLoaded), name: NSNotification.Name("HabitDataLoaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wagerWon(_:)), name: NSNotification.Name("WagerWon"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wagerLost(_:)), name: NSNotification.Name("WagerLost"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func habitDataLoaded() {
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ThemeManager.styleNavBar(navigationController?.navigationBar, theme: theme)
        
        if Auth.auth().currentUser != nil {
            store.loadFromFirebase {
                self.store.checkWagersForToday()
                self.collectionView.reloadData()
            }
        } else {
            collectionView.reloadData()
        }
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(110))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(12)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 24, trailing: 16)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout(section: section)
    }

    @objc private func addHabitTapped() {
        let vc = NewHabitViewController()
        vc.onCreate = { [weak self] name, icon in
            self?.store.addHabit(name: name, icon: icon)
            self?.collectionView.reloadData()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        store.habits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardHabitItemCell.reuseID, for: indexPath) as! DashboardHabitItemCell
        cell.configure(with: store.habits[indexPath.item])
        
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.5, delay: Double(indexPath.item) * 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            cell.alpha = 1.0
            cell.transform = .identity
        })
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let habit = store.habits[indexPath.item]
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                    cell.transform = .identity
                })
            }
        }
        
        let vc = CheckInViewController(habit: habit)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let habit = store.habits[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            let deleteAction = UIAction(
                title: "Delete Habit",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.confirmDeleteHabit(at: indexPath)
            }
            
            return UIMenu(title: habit.name, children: [deleteAction])
        }
    }
    
    private func confirmDeleteHabit(at indexPath: IndexPath) {
        let habit = store.habits[indexPath.item]
        
        let alert = UIAlertController(
            title: "Delete \(habit.name)?",
            message: "This will permanently delete this habit and all its check-in history. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteHabit(at: indexPath)
        }
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    private func deleteHabit(at indexPath: IndexPath) {
        let habit = store.habits[indexPath.item]
        
        collectionView.performBatchUpdates({
            store.deleteHabit(id: habit.id)
            collectionView.deleteItems(at: [indexPath])
        }, completion: { _ in
            self.collectionView.reloadData()
        })
        
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DashboardHeaderView.reuseID, for: indexPath) as! DashboardHeaderView
        header.configure(overallStreak: overallStreak())
        header.onCheckInTapped = { [weak self] in
            self?.startDailyCheckInLoop()
        }
        return header
    }

    private func overallStreak() -> Int {
        return store.habits.map { $0.currentStreak }.max() ?? 0
    }

    private func startDailyCheckInLoop() {
        pendingQueue = store.pendingHabitsForToday()
        guard let first = pendingQueue.first else { return }
        pushCheckIn(for: first)
    }

    private func pushCheckIn(for habit: Habit) {
        let vc = CheckInViewController(habit: habit)
        vc.onFinished = { [weak self] in
            guard let self = self else { return }
            if let idx = self.pendingQueue.firstIndex(where: { $0.id == habit.id }) {
                self.pendingQueue.remove(at: idx)
            }
            if let next = self.pendingQueue.first {
                self.pushCheckIn(for: next)
            } else {
                self.collectionView.reloadData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func wagerWon(_ notification: Notification) {
        guard let amount = notification.userInfo?["amount"] as? Int else { return }
        
        let alert = UIAlertController(
            title: "🎉 WAGER WON! 🎉",
            message: "Congratulations! You completed all your habits and won \(amount) coins!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Awesome!", style: .default) { [weak self] _ in
            self?.collectionView.reloadData()
        })
        present(alert, animated: true)
    }
    
    @objc private func wagerLost(_ notification: Notification) {
        guard let amount = notification.userInfo?["amount"] as? Int else { return }
        
        let alert = UIAlertController(
            title: "Wager Lost",
            message: "You didn't complete all habits. Better luck next time! Lost: \(amount) coins",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.collectionView.reloadData()
        })
        present(alert, animated: true)
    }
}

class DashboardCollectionView: UICollectionView {
    
    func viewDidLoad() {
        
    }
}

