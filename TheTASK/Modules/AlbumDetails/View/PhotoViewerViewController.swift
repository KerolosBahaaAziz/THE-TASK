//
//  PhotoViewerViewController.swift
//  TheTASK
//
//  Created by Kerlos on 15/09/2025.
//

import Foundation
import UIKit

final class PhotoViewerViewController: UIViewController {
    
    private let imageView = UIImageView()
    private let placeholderLabel = UILabel()
    private let photo: Photo
    
    init(photo: Photo) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // ImageView setup
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)
        
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Placeholder setup
        placeholderLabel.text = "No Photo"
        placeholderLabel.textColor = .white
        placeholderLabel.font = UIFont.boldSystemFont(ofSize: 24)
        placeholderLabel.textAlignment = .center
        placeholderLabel.alpha = 0.8
        view.addSubview(placeholderLabel)
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Try to load image
        if let url = URL(string: photo.url) {
            imageView.sd_setImage(with: url) { [weak self] image, error, _, _ in
                if image == nil || error != nil {
                    self?.showPlaceholder()
                } else {
                    self?.hidePlaceholder()
                }
            }
        } else {
            showPlaceholder()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(sharePhoto)
        )
    }
    
    private func showPlaceholder() {
        imageView.isHidden = true
        placeholderLabel.isHidden = false
    }
    
    private func hidePlaceholder() {
        imageView.isHidden = false
        placeholderLabel.isHidden = true
    }
    
    @objc private func sharePhoto() {
        guard let image = imageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

