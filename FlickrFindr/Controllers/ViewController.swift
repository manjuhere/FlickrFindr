//
//  ViewController.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 16/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    private var searchNavBtn: UIBarButtonItem!
    private var collectionView : UICollectionView!
    private var flowLayout : UICollectionViewFlowLayout!
    private var searchTerm : String!
    
    private let photosManager = PhotosManager()
    private let networkManager = NetworkManager()
    
    var photosData : [Photo]! = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.networkManager.delegate = self
        self.searchBar.delegate = self
        searchNavBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.showSearchBar))
        self.resetNavBar(title: "FlickrFindr")
        self.setupCollectionView()
    }
    
    func setupCollectionView() {
        flowLayout = ColumnFlowLayout()
        
        collectionView = UICollectionView.init(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.contentInset = UIEdgeInsetsMake(10.0, 1.0, 10.0, 1.0)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.clear
        view.addSubview(collectionView)
        
        self.collectionView.register(UINib.init(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: PhotoCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
    }

    @objc func showSearchBar() {
        self.navigationItem.titleView = self.searchBar
        self.navigationItem.title = nil
        self.navigationItem.rightBarButtonItem = nil
        self.searchBar.becomeFirstResponder()
    }
    
    @objc func resetNavBar(title: String?) {
        self.navigationItem.titleView = nil
        self.navigationItem.title = title
        self.navigationItem.rightBarButtonItem = searchNavBtn
    }
}

extension ViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.resetNavBar(title: "FlickrFindr")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.resetNavBar(title: searchBar.text)
        self.networkManager.setSearchText(searchBar.text!)
        self.photosData.removeAll()
        self.networkManager.fetchPhotosData()
    }
}

extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        for indexPath in indexPaths {
            let photo = photosData[indexPath.row]
            photosManager.asyncFetchPhoto(photo, completion: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            fatalError("Cell of type - \(PhotoCell.self) Not found")
        }
        let photo = photosData[indexPath.row]
        cell.photo = photo
        if let imgData = photosManager.fetchedPhotoData(for: photo) {
            cell.configure(with: photo, imgData: imgData)
        } else {
            cell.configure(with: nil, imgData: nil)
            photosManager.asyncFetchPhoto(photo) { (data) in
                DispatchQueue.main.async {
                    guard cell.photo == photo else {
                        return
                    }
                    cell.configure(with: photo, imgData: data)
                }
            }
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height * 3 {
            if !self.networkManager.isBeingFetched {
                self.networkManager.fetchPhotosData()
            }
        }
    }
}

extension ViewController : NetworkManagerDelegate {
    func dataFetched(success: Bool, message: String?, data: [Photo]?) {
        guard success == true else {
            self.showToast(error: message!)
            return
        }
        self.photosData.append(contentsOf: data!)
    }
}
