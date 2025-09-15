//
//  Photo.swift
//  TheTASK
//
//  Created by Kerlos on 15/09/2025.
//

import Foundation

struct Photo: Codable {
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}
