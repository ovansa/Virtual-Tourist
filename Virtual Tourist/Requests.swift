//
//  Requests.swift
//  Virtual Tourist
//
//  Created by Muhammed Ibrahim on 15/08/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import CoreData

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
            URLQueryItem(name: "api_key", value: "d2f8674bbf96cb652663f7eeba742af0"),
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
    
    func isImageTitleAvailable(basedOn val: String, isEmpty: @escaping (Bool) -> Void) {
        let savedImageData: NSFetchRequest<Images> = Images.fetchRequest()
        let savedImages: [Images]
        do {
            let saved = try Persistence.context.fetch(savedImageData)
            savedImages = saved
            
            let result = savedImages.filter{ $0.name == val }
            
            isEmpty(result.isEmpty)
            
        } catch {}
    }
    
    func getImagesFromStorage(basedOn val: String, images: @escaping ([String]) -> Void) {
        let savedImageData: NSFetchRequest<Images> = Images.fetchRequest()
        var theSavedImages = [Images]()
        do {
            let saved = try Persistence.context.fetch(savedImageData)
            theSavedImages = saved
            
            let result = theSavedImages.filter{$0.name == val}
            
            images(result[0].imageList!)
            
        } catch {}
    }
    
    func isImageTitleEmpty(basedOn val: String, isEmpty: @escaping (Bool) -> Void) {
        let savedImageData: NSFetchRequest<Images> = Images.fetchRequest()
        var theSavedImages = [Images]()
        do {
            let saved = try Persistence.context.fetch(savedImageData)
            theSavedImages = saved
            
            let result = theSavedImages.filter{$0.name == val}
            
            isEmpty(result.isEmpty)
            
        } catch {}
    }
    
    func getOneSavedImage(with name: String, images: [String]) {
        let fetchImages: NSFetchRequest<Images> = Images.fetchRequest()
        fetchImages.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try Persistence.context.fetch(fetchImages)
            if result.count != 0 {
                print("There are some results")
                print(result[0].imageList!)
                result[0].setValue(images, forKey: "imageList")
                print("------- After replacing image -------")
                print(result[0].imageList!)
            } else {
                print("No result")
            }
        } catch { }
    }
    
    func deleteLocationData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Images")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try Persistence.context.execute(deleteRequest)
        } catch { }
    }
}
