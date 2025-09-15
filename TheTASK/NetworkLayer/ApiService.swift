//
//  ApiService.swift
//  TheTASK
//
//  Created by Kerlos on 14/09/2025.
//

import Foundation
import Moya

enum ApiService {
    case getUsers
    case getAlbums(userId: Int)
    case getPhotos(albumId: Int)
}

extension ApiService: TargetType {
    var baseURL: URL { URL(string: "https://jsonplaceholder.typicode.com")! }

    var path: String {
        switch self {
        case .getUsers: return "/users"
        case .getAlbums: return "/albums"
        case .getPhotos: return "/photos"
        }
    }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case .getUsers:
            return .requestPlain
        case .getAlbums(let userId):
            return .requestParameters(parameters: ["userId": userId], encoding: URLEncoding.default)
        case .getPhotos(let albumId):
            return .requestParameters(parameters: ["albumId": albumId], encoding: URLEncoding.default)
        }
    }

    var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }
}

let provider = MoyaProvider<ApiService>()

