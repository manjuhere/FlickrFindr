//
//  PhotosModel.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 16/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import Foundation

struct PhotosData: Codable {
    var stat    : String
    var code    : Int?
    var message : String?
    var photos  : Photos
}

struct Photos: Codable {
    var page    : Int
    var pages   : Int
    var perpage : Int
    var total   : String
    var photo   : [Photo]
}

struct Photo: Codable, Hashable {
    var id       : String
    var owner    : String
    var secret   : String
    var server   : String
    var farm     : Int
    var title    : String
    var ispublic : Int
    var isfriend : Int
    var isfamily : Int
}

class PhotosManager {
    
    private var photosCache = NSCache<NSString, NSData>()
    
    private func getPhotoCacheKey(_ photo: Photo) -> NSString {
        return NSString(string: "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")
    }

    
    /// Fetch photo image data from cache.
    ///
    /// - Parameter photo: A Photo Model object
    /// - Returns: Returns a Data object of photo image
    func fetchedPhotoData(for photo: Photo) -> Data? {
        let cachedPhotoKey = self.getPhotoCacheKey(photo)
        if let cachedPhotoData = photosCache.object(forKey: cachedPhotoKey) {
            return Data(referencing: cachedPhotoData)
        }
        return nil
    }

    
    /// Function to fetch the imageData of a given photo asynchronously, or from cache if it exists
    ///
    /// - Parameters:
    ///   - photo: A Photo Model object
    ///   - completion: Returns a Data object of photo image
    func asyncFetchPhoto(_ photo: Photo, completion : ((_ photoData : Data?) -> Void)? ) {
        if let data = self.fetchedPhotoData(for: photo){
            if completion != nil {
                completion!(data)
            }
        } else {
            let urlPathStr = "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
            URLSession.shared.dataTask(with: URL(string: urlPathStr)!, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                let cachedPhotoKey = self.getPhotoCacheKey(photo)
                self.photosCache.setObject(NSData(data: data!), forKey: cachedPhotoKey)
                if completion != nil {
                    completion!(data)
                }
            }).resume()
        }
    }

    
}
