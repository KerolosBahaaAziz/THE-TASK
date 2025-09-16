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
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let provider = MoyaProvider<ApiService>()
        
    func fetchPhotos(albumId: Int) {
        let target = ApiService.getPhotos(albumId: albumId)
        print("➡️ Fetching photos from: \(target.baseURL.absoluteString)\(target.path)?albumId=\(albumId)")
        
        provider.requestPublisher(target)
            .map([Photo].self)
            .mapError { $0 as Error }  // unify error type
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print(" Error: \(error)")
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] photos in
                    self?.photos = photos
                    self?.filteredPhotos = photos
                    print(" Received \(photos.count) photos")
                }
            )
            .store(in: &cancellables)
        
        $searchQuery
            .combineLatest($photos)
            .map { query, photos in
                query.isEmpty ? photos :
                photos.filter { $0.title.lowercased().contains(query.lowercased()) }
            }
            .assign(to: &$filteredPhotos)
    }
}
