//
//  Dashboard.swift
//  Eternal-CS329E-Group-Project
//
//  Created by Colin Day on 10/20/25.
//
//  Edited by Ori Parks

import SwiftUI
import UIKit

class Dashboard: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    private let store = HabitStore.shared
    private var pendingQueue: [Habit] = []
    private var collectionView: UICollectionView!
    
    private var theme: Theme { ThemeManager.current(from: store.settings.themeKey) }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = theme.background
        self.title = "Home"
        
        navigationController?.navigationBar.tintColor = theme.primary
        
        let titleLabel = UILabel()
        titleLabel.text = "Home"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        navigationItem.titleView = titleLabel

        // Removed large titles for centered effect
        // navigationController?.navigationBar.prefersLargeTitles = true
        // navigationItem.largeTitleDisplayMode = .always

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
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(90))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(12)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 24, trailing: 16)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Actions

    @objc private func addHabitTapped() {
        let vc = NewHabitViewController()
        vc.onCreate = { [weak self] name, icon in
            self?.store.addHabit(name: name, icon: icon)
            self?.collectionView.reloadData()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    // MARK: - DataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        store.habits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardHabitItemCell.reuseID, for: indexPath) as! DashboardHabitItemCell
        cell.configure(with: store.habits[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let habit = store.habits[indexPath.item]
        let vc = CheckInViewController(habit: habit)
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DashboardHeaderView.reuseID, for: indexPath) as! DashboardHeaderView
        header.configure(overallStreak: overallStreak())
        header.onCheckInTapped = { [weak self] in
            self?.startDailyCheckInLoop()
        }
        return header
    }

    // MARK: - Helpers

    private func overallStreak() -> Int {
        // Simple overall: max habit streak for now
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
            // Remove the just-handled habit
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
}

class DashboardCollectionView: UICollectionView {
    
    func viewDidLoad() {
        
    }
}
