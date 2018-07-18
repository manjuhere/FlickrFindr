//
//  SearchManager.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 16/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import Foundation
import UIKit

/// Delegates to notify new Search Data and change in recent searches
protocol SearchManagerDelegate : class {
    func dataFetched(success: Bool, message: String?, data: [Photo]?)
    func recentSearchesChanged()
}

class SearchManager {
    
    var searchText : String! {
        didSet { // reset page related data as it is a new search
            self.totalPages = nil
            self.requestPage = 1
        }
    }
    private var totalPages : Int!
    private var requestPage : Int = 1
    
    var isBeingFetched : Bool = false // flag to not fire multiple requests
    weak var delegate : SearchManagerDelegate?
    
    var recentSearches : [String] = {
        guard let searches = UserDefaults.standard.array(forKey: StorageKeys.RecentSearches.rawValue) as? [String] else {
            return []
        }
        return searches
    }()
    
    
    /// Fetches all photo related data for a given search Term. Also considers paging internally
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
    
    /// Private function to store successful searches into user defaults.
    private func storeSearch() {
        if !recentSearches.contains(searchText) {
            recentSearches.insert(searchText, at: 0)
        } else {
            recentSearches.remove(at: recentSearches.index(of: searchText)!)
            recentSearches.insert(searchText, at: 0)
        }
        UserDefaults.standard.set(recentSearches, forKey: StorageKeys.RecentSearches.rawValue)
        UserDefaults.standard.synchronize()
        self.delegate?.recentSearchesChanged()
    }
    
}
