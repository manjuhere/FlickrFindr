//
//  PhotoCell.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 17/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    var photo: Photo?
    static var identifier : String = {
        return String(describing: PhotoCell.self)
    }()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor(displayP3Red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0).cgColor
        self.layer.borderWidth = 2.0
    }

    func configure(with photo: Photo?, imgData: Data?) {
        self.backgroundColor = UIColor(displayP3Red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
        self.titleLabel.text = photo?.title
        if imgData != nil {
            self.photoView.image = UIImage(data: imgData!)
            self.loadingIndicator.stopAnimating()
        } else {
            self.photoView.image = nil
        }
    }
    
}
