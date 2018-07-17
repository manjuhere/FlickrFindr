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
    private var collectionView : UICollectionView!
    private var flowLayout : UICollectionViewFlowLayout!
    var searchNavBtn: UIBarButtonItem!
    
    let photosManager = PhotosManager()
    var photosData : [Photo]! = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        // show recent searches
        // show a tableview under the navbar for half the screen size.
        // this can be a containerVC which can be added and removed
        // VC within containerVC holds the tableview.
        // this class is a delegate of VC and when didSelectRowAtIndexPath of tableview
        // pass on to this VC via delegate : fire the API in here, remove containerVC & reload collectionView
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
        // fire the api
        // add searchTerm to recently used
        // remove container view
        // reload collection view
        NetworkManager().fetchPhotosData(searchText: searchBar.text!) { (success, message, data) in
            guard success == true else {
                //alert with message
                return
            }
            self.photosData = data
        }
    }
}

extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            fatalError("Cell Not found")
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
}

extension ViewController : UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        for indexPath in indexPaths {
            let photo = photosData[indexPath.row]
            photosManager.asyncFetchPhoto(photo, completion: nil)
        }
    }
}
