//
//  PhotoCell.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 17/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    static var identifier : String = {
        return String(describing: PhotoCell.self)
    }()
    
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0
    }

}
