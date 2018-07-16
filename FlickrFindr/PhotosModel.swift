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

struct Photo: Codable {
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
