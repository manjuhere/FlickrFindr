//
//  NetworkManager.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 16/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkManagerDelegate : class {
    func dataFetched(success: Bool, message: String?, data: [Photo]?)
}

class NetworkManager {
    
    private var searchText : String!
    private var totalPages : Int!
    private var requestPage : Int = 1
    
    var isBeingFetched : Bool = false
    weak var delegate : NetworkManagerDelegate?
    
    func setSearchText(_ text: String) {
        self.searchText = text
        self.totalPages = nil
        self.requestPage = 1
    }
    
    func fetchPhotosData() {
        guard searchText != nil, !searchText!.isEmpty else {
            return
        }
        var searchURL : String
        if totalPages == nil {
            searchURL = APIConfig().getSearchURL(searchText: searchText)
        } else {
            if requestPage <= totalPages {
                searchURL = APIConfig().getSearchURL(searchText: searchText, page: self.requestPage)
            } else {
                delegate?.dataFetched(success: false, message: "Search Results Ended", data: nil)
                return
            }
        }
        
        self.isBeingFetched = true
        let task = URLSession.shared.dataTask(with: URL(string: searchURL)!) { (data, response, error) in
            self.isBeingFetched = false
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
                        if photosData.photos.pages != 0 {
                            self.totalPages = photosData.photos.pages
                        } else {
                            self.delegate?.dataFetched(success: false, message: "No Results Found", data: nil)
                            return
                        }
                        self.storeSearch()
                        self.requestPage += 1
                        self.delegate?.dataFetched(success: true, message: nil, data: photosData.photos.photo)
                    } else if photosData.stat == "fail" {
                        self.delegate?.dataFetched(success: false, message: "Something went wrong", data: nil)
                    }
                } catch {
                    print("JSON decoding failed")
                }
            }
        }
        task.resume()
    }
    
    private func storeSearch() {
        guard var searches = UserDefaults.standard.array(forKey: "recentSearches") as? [String] else {
            return
        }
        if !searches.contains(self.searchText) {
            searches.append(searchText)
        } else {
            searches.swapAt(0, searches.index(of: searchText)!)
        }
        UserDefaults.standard.set(searches, forKey: "recentSearches")
        UserDefaults.standard.synchronize()
    }
    
}
