//
//  Photos.swift
//  
//
//  Created by Muhammed Ibrahim on 15/08/2020.
//

import Foundation

struct PhotosBody: Decodable {
    let photos: Photos
}

struct Photos: Decodable {
    let photo: [Photo]
}

struct Photo: Decodable {
    let id: String
    let farm: Int
    let owner: String
    let secret: String
    let server: String
    let title: String
}
