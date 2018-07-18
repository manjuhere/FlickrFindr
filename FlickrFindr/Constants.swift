//
//  Constants.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 16/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import Foundation

// UserDefaults keys
enum StorageKeys : String {
    case RecentSearches = "RecentSearches"
}


struct APIConfig {
    
    private let API_ENDPOINT = "https://api.flickr.com/services/rest/"
    private let API_PARAM_METHOD = "?method=flickr.photos.search"

    private let API_PARAM_KEY: String = {
        var api: String?
        guard let path = Bundle.main.path(forResource: "api_key", ofType: "txt") else {
            assertionFailure("Could not locate API Key")
            return ""
        }
        do {
            api = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        } catch {
            assertionFailure("Could not locate API Key")
        }
        api = api!.trimmingCharacters(in: .whitespacesAndNewlines)
        return "&api_key=\(api!)"
    }()
    
    // TODO: - certain properties can be tweaked in runtime based on user settings
    private let API_PARAM_RESP_FORMAT = "&format=json"
    private let API_PARAM_NO_CALLBACK = "&nojsoncallback=1"
    private let API_PARAM_SAFE_SEARCH = "&safe_search=1"

    
    /// Build Search URL using query parameters and given search inputs
    ///
    /// - Parameters:
    ///   - searchText: A string which is to be searched
    ///   - page: corresponding page of search result to be fetched. By default fetches the first page
    /// - Returns: Returns a fully formed URL by combining all parameters.
    func getSearchURL(searchText: String, page: Int? = nil) -> String {
        var searchParam = "&text=\(searchText)"
        searchParam = searchParam.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        var URL = API_ENDPOINT + API_PARAM_METHOD + API_PARAM_KEY + API_PARAM_RESP_FORMAT + API_PARAM_NO_CALLBACK + API_PARAM_SAFE_SEARCH + searchParam
        if page != nil {
            let pageParam = "&page=\(page!)"
            URL = URL + pageParam
        }
        return URL
    }
    
}

