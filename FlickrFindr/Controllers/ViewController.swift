//
//  ViewController.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 16/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet var searchBar: UISearchBar!
    private var searchNavBtn: UIBarButtonItem!
    private var recentsList : UITableView!
    private var collectionView : UICollectionView!
    private var flowLayout : UICollectionViewFlowLayout!
    private var searchTerm : String!
    
    private let photosManager = PhotosManager()
    private let searchManager = SearchManager()
    
    var photosData : [Photo]! = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Setup Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchManager.delegate = self
        self.searchBar.delegate = self
        searchNavBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.showSearchBar))
        self.resetNavBar(title: "FlickrFindr")
        self.setupRecentsList()
        self.setupCollectionView()
    }
    
    func setupCollectionView() {
        flowLayout = ColumnFlowLayout()
        
        collectionView = UICollectionView.init(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.contentInset = UIEdgeInsetsMake(0.0, 1.0, 10.0, 1.0)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.indicatorStyle = .white
        view.addSubview(collectionView)
        
        self.collectionView.register(UINib.init(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: PhotoCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
    }

    func setupRecentsList() {
        recentsList = UITableView(frame: CGRect(x: 0.0, y: self.view.safeAreaInsets.top, width: self.view.bounds.width, height: self.view.bounds.height/2))
        recentsList.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        recentsList.rowHeight = UITableViewAutomaticDimension
        recentsList.estimatedRowHeight = 40
        self.view.addSubview(recentsList)
        
        recentsList.backgroundColor = .clear
        recentsList.separatorColor = .lightGray
        
        self.sendRecentListsBack()
        
        self.recentsList.register(UITableViewCell.self, forCellReuseIdentifier: "RecentsCell")
        recentsList.delegate = self
        recentsList.dataSource = self
    }
    
    // MARK: - Helper methods
    @objc func showSearchBar() {
        self.navigationItem.titleView = self.searchBar
        self.navigationItem.title = nil
        self.navigationItem.rightBarButtonItem = nil
        self.searchBar.becomeFirstResponder()
        recentsList.isHidden = false
        self.view.bringSubview(toFront: recentsList)
    }
    
    @objc func resetNavBar(title: String?) {
        self.navigationItem.titleView = nil
        self.navigationItem.title = (title != nil) ? title! : self.searchManager.searchText
        self.navigationItem.rightBarButtonItem = searchNavBtn
    }
    
    fileprivate func sendRecentListsBack()  {
        recentsList.isHidden = true
        self.view.sendSubview(toBack: recentsList)
    }
    
    fileprivate func resetSearch(searchTerm: String) {
        self.sendRecentListsBack()
        self.resetNavBar(title: searchTerm)
        self.searchManager.searchText = searchTerm
        self.photosData.removeAll()
        self.searchManager.fetchPhotosData()
    }
    
}
// MARK: - SearchBar Delegate methods
extension ViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.sendRecentListsBack()
        self.resetNavBar(title: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.resetSearch(searchTerm: searchBar.text!)
    }
}

// MARK: - UICollectionView DataSource, Delegate & Prefetching Methods
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
            // already in cache
            cell.configure(with: photo, imgData: imgData)
        } else {
            // reset the cell to avoid mismatches
            cell.configure(with: nil, imgData: nil)
            photosManager.asyncFetchPhoto(photo) { (data) in
                DispatchQueue.main.async {
                    // check if cell hasn't been recycled
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
        // only when collectionView is scrolled, new data needs to be fetched
        if scrollView == collectionView {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            if offsetY > contentHeight - scrollView.frame.height * 3 {
                if !self.searchManager.isBeingFetched {
                    self.searchManager.fetchPhotosData()
                }
            }
        }
    }
}

// MARK: - RecentSearches TableViewDelegate and DataSource methods
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchManager.recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentsCell", for: indexPath)
        cell.textLabel?.text = self.searchManager.recentSearches[indexPath.row]
        cell.textLabel?.textColor = .lightText
        cell.backgroundColor = .darkGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let searchTerm = self.searchManager.recentSearches[indexPath.row]
        self.resetSearch(searchTerm: searchTerm)
    }
}

// MARK: - SearchManager Delegates to notify new Search Data and change in recent searches
extension ViewController : SearchManagerDelegate {
    func recentSearchesChanged() {
        DispatchQueue.main.async {
            self.recentsList.reloadData()
        }
    }
    
    func dataFetched(success: Bool, message: String?, data: [Photo]?) {
        guard success == true else {
            self.showToast(error: message!)
            return
        }
        self.photosData.append(contentsOf: data!)
    }
}
