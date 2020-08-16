//
//  Requests.swift
//  Virtual Tourist
//
//  Created by Muhammed Ibrahim on 15/08/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit

class Requests {
    static let shared = Requests()
    
    private init() {}
    
    let session = URLSession.shared
    
    func getImageDataFromLocation(lat: Double, lon: Double, success successBloc: @escaping([Photo]) -> Void) {
        let latitude = String(lat)
        let longitude = String(lon)
        
        guard var urlString = URLComponents(string: "https://www.flickr.com/services/rest/") else { return }
        
        urlString.queryItems = [
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "api_key", value: "c9f2ed0c550e444fe4df3c0c1374632c"),
            URLQueryItem(name: "privacy_filter", value: "1"),
            URLQueryItem(name: "lat", value: latitude),
            URLQueryItem(name: "lon", value: longitude),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]
    
        let request = URLRequest(url: urlString.url!)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let photoData = try JSONDecoder().decode(PhotosBody.self, from: data)
                    let photos = photoData.photos.photo
//                    for photo in photos {
//                        print(photo.secret)
//                    }
                    DispatchQueue.main.async {
                        successBloc(photos)
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func downloadImage(fromLink link: String, success successBlock: @escaping(UIImage) -> Void) {
        guard let url = URL(string: link) else { return }
        
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data,
            let image = UIImage(data: data)
            else { return }
            
            DispatchQueue.main.async {
                successBlock(image)
            }
        }.resume()
    }
}
