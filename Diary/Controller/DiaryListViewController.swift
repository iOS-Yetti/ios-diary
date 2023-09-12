//
//  Diary - DiaryListViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreData

final class DiaryListViewController: UIViewController {
    var diaries: [Diary] = []
    
    private lazy var collectionView: UICollectionView = {
        var configuration: UICollectionLayoutListConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
            guard let uuid = CoreDataManager.shared.fetchAllDiaries()[indexPath.item].identifier else {
                return UISwipeActionsConfiguration()
            }
            
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
                CoreDataManager.shared.delete(diary: uuid)
                self?.diaries = CoreDataManager.shared.fetchAllDiaries()
                self?.collectionView.reloadData()
                
                completionHandler(true)
            }
            
            let share = UIContextualAction(style: .normal, title: "Share") {_, _, completionHandler in
                let alertManager: AlertManager = AlertManager(uuid: uuid)
                self.showActivityView()
                completionHandler(true)
            }
            
            return UISwipeActionsConfiguration(actions: [delete, share])
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(DiaryCollectionViewListCell.self, forCellWithReuseIdentifier: DiaryCollectionViewListCell.identifier)
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigation()
        configureUI()
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.diaries = CoreDataManager.shared.fetchAllDiaries()
        diaries.forEach { diary in
            if diary.body == nil {
                CoreDataManager.shared.delete(diary: diary.identifier!)
            }
        }
        self.diaries = CoreDataManager.shared.fetchAllDiaries()
        collectionView.reloadData()
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        // diffableDatasource
    }
    
    private func configureNavigation() {
        let addDiary: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(createNewDiaryButtonTapped))
        self.navigationItem.rightBarButtonItem = addDiary
        navigationItem.title = "일기장"
    }
    
    private func configureUI() {
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
    }
    
    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    @objc private func createNewDiaryButtonTapped() {
        let uuid: UUID = UUID()
        CoreDataManager.shared.create(diary: uuid)
        let diary: Diary = CoreDataManager.shared.fetchSingleDiary(by: uuid)[safe: 0]!
        let diaryDetailViewController: DiaryDetailViewController = DiaryDetailViewController(diary: diary)
        navigationController?.pushViewController(diaryDetailViewController, animated: true)
    }
    
    func showActivityView() {
        let activityViewController = UIActivityViewController(activityItems: ["타이틀 넣어야함"], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
}

extension DiaryListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewListCell.identifier, for: indexPath) as? DiaryCollectionViewListCell else {
            return UICollectionViewCell()
        }
        
        guard let diary = diaries[safe: indexPath.item] else {
            return cell
        }
        
        cell.configureLabel(with: diary)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let diary = diaries[safe: indexPath.item] else {
            return
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
        let diaryDetailViewController: DiaryDetailViewController = DiaryDetailViewController(diary: diary)
        navigationController?.pushViewController(diaryDetailViewController, animated: true)
    }
    
}
