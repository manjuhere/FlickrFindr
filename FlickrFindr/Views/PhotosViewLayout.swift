//
//  PhotosViewLayout.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 17/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import Foundation
import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        self.minimumLineSpacing = 0.0
        self.minimumInteritemSpacing = 0.0
        
        guard let cv = collectionView else { return }
        
        var numOfItems: Int
        if cv.bounds.width >= cv.bounds.height {
            numOfItems = 3 //landscape mode - 3 rows
        } else {
            numOfItems = 2 //portrait mode - 2 rows
        }
        // calculate row size by eliminating safeArea and contentInsets
        let availWidth = cv.bounds.width - (cv.safeAreaInsets.left + cv.safeAreaInsets.right) - (cv.contentInset.left + cv.contentInset.right)
        let itemSpacingWidth = self.minimumInteritemSpacing * CGFloat(numOfItems)
        let cellWidth = floor((availWidth - itemSpacingWidth) / CGFloat(numOfItems))
        self.itemSize = CGSize(width: cellWidth , height: cellWidth)

        self.sectionInsetReference = .fromSafeArea
    }
}
