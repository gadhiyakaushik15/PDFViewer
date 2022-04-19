//
//  SearchTableViewController.swift
//  PDFViewer
//
//  Created by Macbook Pro on 08/05/18.
//  Copyright © 2018 Kaushik Gadhiya. All rights reserved.
//

import UIKit
import PDFKit
import Firebase

class SearchTableViewController: UITableViewController, UISearchBarDelegate, PDFDocumentDelegate, GADBannerViewDelegate {
    
   @IBOutlet weak var bannerView: GADBannerView!
    
    var pdfDocument: PDFDocument?
    weak var delegate: SearchViewControllerDelegate?
    
    var searchController = UISearchController()
    
    var searchResults = [PDFSelection]()
        
    deinit
    {
        pdfDocument?.cancelFindString()
        pdfDocument?.delegate = nil
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.rowHeight = 88
        tableView.tableFooterView = UIView()
        
        
        searchController = UISearchController.init(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.sizeToFit()
       
    
        if #available(iOS 11.0, *)
        {
            navigationItem.hidesSearchBarWhenScrolling = false
            navigationItem.searchController = searchController
        }
        else
        {
            navigationItem.titleView = searchController.searchBar
        }

        self.definesPresentationContext = true
        
        self.tableView.tableHeaderView = bannerView
        
        bannerView.adUnitID = adsBannerID
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
    }
    
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("Ads fail error =", error.localizedDescription)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.text = ""
        searchResults.removeAll()
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        pdfDocument?.delegate = nil
        pdfDocument?.cancelFindString()
        
        searchResults.removeAll()
        tableView.reloadData()
        pdfDocument?.delegate = self
        pdfDocument?.beginFindString(searchText, withOptions: .caseInsensitive)
    }
    
    func didMatchString(_ instance: PDFSelection)
    {
        searchResults.append(instance)
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Search Result"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchResultsCell
        
        let selection = searchResults[indexPath.row]
        
        let extendedSelection = selection.copy() as! PDFSelection
        extendedSelection.extendForLineBoundaries()
        
        let outline = pdfDocument?.outlineItem(for: selection)
        cell.section = outline?.label
        
        let page = selection.pages[0]
        cell.page = page.label
        
        cell.resultText = extendedSelection.string
        cell.searchText = selection.string
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selection = searchResults[indexPath.row]
        searchController.searchBar.resignFirstResponder()
        delegate?.searchViewController(self, didSelectSearchResult: selection)
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}

protocol SearchViewControllerDelegate: AnyObject
{
    func searchViewController(_ SearchTableViewController: SearchTableViewController, didSelectSearchResult selection: PDFSelection)
}


