//
//  NetworkManager.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 16/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import Foundation

class NetworkManager {
    func fetchPhotos(searchText: String) {
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
                    print(photosData)
                } catch {
                    print("JSON decoding failed")
                }
            }
        }
        task.resume()
    }
}
