//
//  NetworkManager.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 16/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import Foundation
import UIKit

class NetworkManager {
    func fetchPhotosData(searchText: String, dataFetched : @escaping (_ success: Bool, _ message: String?, _ photosData : [Photo]?) -> Void) {
        let url = APIConfig().getSearchURL(searchText: searchText)
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                guard data != nil else {
                    print("Data Not Found")
                    return
                }
                
                do {
                    let photosData = try JSONDecoder().decode(PhotosData.self, from: data!)
                    if photosData.stat == "ok" {
                        dataFetched(true, nil, photosData.photos.photo)
                    } else if photosData.stat == "fail" {
                        dataFetched(false, "Something went wrong", nil)
                    }
                } catch {
                    print("JSON decoding failed")
                }
            }
        }
        task.resume()
    }
}
