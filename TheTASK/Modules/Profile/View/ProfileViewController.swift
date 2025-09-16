//
//  ProfileViewController.swift
//  TheTASK
//
//  Created by Kerlos on 15/09/2025.
//

import Foundation
import UIKit
import Combine
import SkeletonView

final class ProfileViewController: UIViewController {
    
    private let viewModel = ProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView = UITableView()
    private let headerNameLabel = UILabel()
    private let headerAddressLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        setupUI()
        bindViewModel()
        
        viewModel.fetchUserAndAlbums()
    }
    
    private func setupUI() {
        headerNameLabel.font = .boldSystemFont(ofSize: 24)
        headerNameLabel.textAlignment = .center
        
        headerAddressLabel.font = .systemFont(ofSize: 18)
        headerAddressLabel.textColor = .secondaryLabel
        headerAddressLabel.textAlignment = .center
        headerAddressLabel.numberOfLines = 0
        
        let headerStack = UIStackView(arrangedSubviews: [headerNameLabel, headerAddressLabel])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 4
        
        view.addSubview(headerStack)
        view.addSubview(tableView)
        
        let headerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "My Albums"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .left
        
        headerView.addSubview(titleLabel)
        headerView.backgroundColor = .systemGroupedBackground
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 35)
        
        tableView.tableHeaderView = headerView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AlbumCell")
        tableView.isSkeletonable = true
        tableView.showAnimatedGradientSkeleton()
        
        view.addSubview(tableView)
        
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$user
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                guard let self, let user else { return }
                self.headerNameLabel.text = user.name
                self.headerAddressLabel.text = "\(user.address.street), \(user.address.city)"
            }
            .store(in: &cancellables)
        
        viewModel.$albums
            .receive(on: RunLoop.main)
            .sink { [weak self] albums in
                guard let self = self else { return }
                if albums.isEmpty {
                    self.tableView.showAnimatedGradientSkeleton()
                } else {
                    self.tableView.hideSkeleton()
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                guard let self else { return }
                self.showErrorAlert(message: message) { [weak self] in
                    self?.viewModel.fetchUserAndAlbums()
                }
            }
            .store(in: &cancellables)
    }

}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath)
        cell.textLabel?.text = viewModel.albums[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.textLabel?.isSkeletonable = true
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = viewModel.albums[indexPath.row]
        let detailsVC = AlbumDetailsViewController(albumId: album.id, title: album.title)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
}

extension ProfileViewController: SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "AlbumCell"
    }
}
