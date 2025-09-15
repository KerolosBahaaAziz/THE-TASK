//
//  AlbumDetailsViewModel.swift
//  TheTASK
//
//  Created by Kerlos on 15/09/2025.
//

import Foundation
import Combine
import Moya
import CombineMoya

final class AlbumDetailsViewModel {
    @Published private(set) var photos: [Photo] = []
    @Published private(set) var filteredPhotos: [Photo] = []
    @Published var searchQuery: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchPhotos(albumId: Int) {
        let target = ApiService.getPhotos(albumId: albumId)
        print("➡️ Fetching photos from: \(target.baseURL.absoluteString)\(target.path)?albumId=\(albumId)")
        
        provider.requestPublisher(target)
            .map([Photo].self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Error: \(error)")
                    }
                },
                receiveValue: { [weak self] photos in
                    self?.photos = photos
                    self?.filteredPhotos = photos
                    print("✅ Received \(photos.count) photos")
                }
            )
            .store(in: &cancellables)
        
        
        // bind search query
        $searchQuery
            .combineLatest($photos)
            .map { query, photos in
                query.isEmpty ? photos :
                photos.filter { $0.title.lowercased().contains(query.lowercased()) }
            }
            .assign(to: &$filteredPhotos)
    }
}
