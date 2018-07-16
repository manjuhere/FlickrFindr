//
//  Constants.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 16/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import Foundation


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

    func getSearchURL(searchText: String) -> String {
        let searchParam = "&text=\(searchText)"
        let URL = API_ENDPOINT + API_PARAM_METHOD + API_PARAM_KEY + API_PARAM_RESP_FORMAT + API_PARAM_NO_CALLBACK + API_PARAM_SAFE_SEARCH + searchParam
        return URL
    }
    
}

