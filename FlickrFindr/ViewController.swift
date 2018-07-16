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
    let searchBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.searchBtn.action = #selector(self.showSearchBar)
        
        self.resetNavBar(title: "FlickrFindr")
    }
    
    @objc func showSearchBar() {
        self.navigationItem.titleView = self.searchBar
        self.navigationItem.title = nil
        self.navigationItem.rightBarButtonItem = nil
        
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
        self.navigationItem.rightBarButtonItem = searchBtn
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
    }
}
