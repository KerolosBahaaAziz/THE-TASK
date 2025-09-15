//
//  ProfileViewModel.swift
//  TheTASK
//
//  Created by Kerlos on 15/09/2025.
//

import Foundation
import Combine
import Moya
import CombineMoya

final class ProfileViewModel {
    @Published private(set) var user: User?
    @Published private(set) var albums: [Album] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let provider = MoyaProvider<ApiService>()
    
    func fetchUserAndAlbums() {
        isLoading = true
        
        provider.requestPublisher(ApiService.getUsers)
            .map([User].self)
            .mapError { $0 as Error }
            .compactMap { $0.randomElement() }
            .flatMap { user -> AnyPublisher<(User, [Album]), Error> in
                self.provider.requestPublisher(ApiService.getAlbums(userId: user.id))
                    .map([Album].self)
                    .map { (user, $0) }
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription // 👈 publish error
                }
            }, receiveValue: { [weak self] user, albums in
                self?.user = user
                self?.albums = albums
            })
            .store(in: &cancellables)
    }
    
}
