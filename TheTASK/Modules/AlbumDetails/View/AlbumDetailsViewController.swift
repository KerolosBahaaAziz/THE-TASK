//
//  AlbumDetailsViewController.swift
//  TheTASK
//
//  Created by Kerlos on 15/09/2025.
//

import Foundation
import UIKit
import Combine
import SkeletonView

final class AlbumDetailsViewController: UIViewController {
    
    private let viewModel = AlbumDetailsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let collectionView: UICollectionView
    private let searchBar = UISearchBar()
    
    var albumId : Int = 0
    
    init(albumId: Int, title: String) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.albumId = albumId
        viewModel.fetchPhotos(albumId: albumId)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        bindViewModel()

    }
    
    private func setupUI() {
        searchBar.placeholder = "Search photos"
        searchBar.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.keyboardDismissMode = .onDrag
        collectionView.isSkeletonable = true
        collectionView.showAnimatedGradientSkeleton()

        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor , constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$filteredPhotos
            .receive(on: RunLoop.main)
            .sink { [weak self] photos in
                guard let self = self else { return }
                if photos.isEmpty {
                    self.collectionView.showAnimatedGradientSkeleton()
                } else {
                    self.collectionView.hideSkeleton()
                    self.collectionView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                self?.showErrorAlert(message: message) { [weak self] in
                    self?.viewModel.fetchPhotos(albumId: self?.albumId ?? 0)
                }
            }
            .store(in: &cancellables)
    }

}

extension AlbumDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("filteredPhotos.count: \(viewModel.filteredPhotos.count)")
        return viewModel.filteredPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let photo = viewModel.filteredPhotos[indexPath.item]
        cell.configure(with: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = viewModel.filteredPhotos[indexPath.item]
        let viewerVC = PhotoViewerViewController(photo: photo)
        navigationController?.pushViewController(viewerVC, animated: true)
    }
}

extension AlbumDetailsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchQuery = searchText
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}

extension AlbumDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let spacing: CGFloat = 4
        let totalSpacing = (itemsPerRow - 1) * spacing
        let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow
        return CGSize(width: width, height: width)
    }
}

// MARK: - Skeleton DataSource
extension AlbumDetailsViewController: SkeletonCollectionViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "PhotoCell"
    }
}


