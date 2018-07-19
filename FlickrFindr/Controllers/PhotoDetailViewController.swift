//
//  PhotoDetailViewController.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 19/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTitle: UILabel!
    var photosManager : PhotosManager!
    var photo : Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(photo != nil, "Photo can't be nil")
        assert(photosManager != nil, "Photo Manager can't be nil")
        
        self.imageTitle.text = photo.title
        if let imgData = self.photosManager.fetchedPhotoData(for: photo) {
            self.imageView.image = UIImage(data: imgData)
        } else {
            self.imageView.image = nil
            photosManager.asyncFetchPhoto(photo) { (data) in
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data!)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
