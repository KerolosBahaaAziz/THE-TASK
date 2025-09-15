//
//  ProfileViewController.swift
//  TheTASK
//
//  Created by Kerlos on 15/09/2025.
//

import Foundation
import UIKit
import Combine

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
        headerNameLabel.font = .boldSystemFont(ofSize: 20)
        headerNameLabel.textAlignment = .center

        headerAddressLabel.font = .systemFont(ofSize: 16)
        headerAddressLabel.textColor = .secondaryLabel
        headerAddressLabel.textAlignment = .center
        headerAddressLabel.numberOfLines = 0

        let headerStack = UIStackView(arrangedSubviews: [headerNameLabel, headerAddressLabel])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 4

        view.addSubview(headerStack)
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AlbumCell")
        
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
        // Show loading when fetch starts
        
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
            .sink { [weak self] _ in
                self?.tableView.reloadData()
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = viewModel.albums[indexPath.row]
        let detailsVC = AlbumDetailsViewController(albumId: album.id, title: album.title)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Albums"
    }

}
