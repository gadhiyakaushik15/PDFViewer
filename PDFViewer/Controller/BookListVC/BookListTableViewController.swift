//
//  BookListTableViewController.swift
//  PDFViewer
//
//  Created by Macbook Pro on 04/05/18.
//  Copyright © 2018 Kaushik Gadhiya. All rights reserved.
//

import UIKit
import PDFKit
import Firebase

class BookListTableViewController: UITableViewController,UISearchBarDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var documents = [PDFDocument]()
    var searchDocuments = [PDFDocument]()
    var searchController: UISearchController!
    var isSeaching : Bool = false
    
    let thumbnailCache = NSCache<NSURL, UIImage>()
    private let downloadQueue = DispatchQueue(label: "com.app.PDFViewer.thumbnail")

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorInset.left = 56
        tableView.tableFooterView = UIView()
        refreshData()
        NotificationCenter.default.addObserver(self, selector: #selector(documentDirectoryDidChange(_:)), name: .documentDirectoryDidChange, object: nil)
        
        
        searchController = UISearchController.init(searchResultsController: nil)
        searchController.searchBar.delegate = self
        
        if #available(iOS 11.0, *)
        {
            self.navigationItem.searchController = searchController
        }
        else
        {
            self.tableView.tableHeaderView = searchController.searchBar
        }
        
        self.tableView.tableHeaderView = bannerView
        
        bannerView.adUnitID = adsBannerID
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if isSeaching
        {
            present(searchController, animated: true, completion: nil)
        }
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
        searchBar.resignFirstResponder()
        isSeaching = false
        searchDocuments.removeAll()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchDocuments.removeAll()
        let searchText = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if searchText.count == 0
        {
             isSeaching = false
        }
        else
        {
            isSeaching = true
            for document in documents
            {
                if let title = document.documentAttributes!["Title"] as? String
                {
                    if (title.lowercased().contains(searchText.lowercased()))
                    {
                        searchDocuments.append(document)
                    }
                }
            }
        }
        
        
         tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     // MARK: - Local Class Private Method
    private func refreshData()
    {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let contents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        documents = contents.compactMap { PDFDocument(url: $0) }
        
        tableView.reloadData()
    }

    @objc func documentDirectoryDidChange(_ notification: Notification)
    {
        refreshData()
    }
    // MARK: - Table view data source
   
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isSeaching
        {
            return searchDocuments.count
        }
        else
        {
            return documents.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BookListTableViewCell
        
        let document: PDFDocument!
        if isSeaching
        {
            document = searchDocuments[indexPath.row]
        }
        else
        {
            document = documents[indexPath.row]
        }
       
        if var path = document.documentURL
        {
            path = path.deletingPathExtension()
            cell.title = path.lastPathComponent
            cell.author = self.getfileModifiedDateAndSize(theFile: document.documentURL!.path)
        }
        
        if document.pageCount > 0 {
            if let page = document.page(at: 0), let key = document.documentURL as NSURL? {
                cell.url = key
                
                if let thumbnail = thumbnailCache.object(forKey: key) {
                    cell.thumbnail = thumbnail
                } else {
                    downloadQueue.async {
                        let thumbnail = page.thumbnail(of: CGSize(width: 40, height: 60), for: .cropBox)
                        self.thumbnailCache.setObject(thumbnail, forKey: key)
                        if cell.url == key {
                            DispatchQueue.main.async {
                                cell.thumbnail = thumbnail
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        dismiss(animated: true, completion: nil)
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
        if isSeaching
        {
            controller.pdfDocument = searchDocuments[indexPath.row]
        }
        else
        {
            controller.pdfDocument = documents[indexPath.row]
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            
            let deleteAlert = UIAlertController(title: "Warning", message: "Are you sure you want to delete.", preferredStyle: UIAlertController.Style.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
               
                let fileManager = FileManager.default
                
                // Delete 'hello.swift' file
                
                do {
                    if let strURL = self.documents[indexPath.row].documentURL?.path
                    {
                        try fileManager.removeItem(atPath: strURL)
                        
                        self.documents.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    }
                }
                catch let error
                {
                    print("Ooops! Something went wrong: \(error.localizedDescription)")
                }
                
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            
            self.present(deleteAlert, animated: true, completion: nil)
            
        })
        deleteAction.backgroundColor = UIColor.red
        
        let editAction = UITableViewRowAction(style: .default, title: "Rename", handler: { (action, indexPath) in
            
            let alertController = UIAlertController(title: "Rename", message: "", preferredStyle: .alert)
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter file name"
                if var path = self.documents[indexPath.row].documentURL
                {
                    path = path.deletingPathExtension()
                    textField.text = path.lastPathComponent
                }
            }
            
            let renameAction = UIAlertAction(title: "Rename", style: .default, handler: { alert -> Void in
                let renameTextField = alertController.textFields![0] as UITextField
                if let text = renameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                {
                    if text.count > 0
                    {
                        do {

                            let originPath = self.documents[indexPath.row].documentURL
                            var destinationPath = self.documents[indexPath.row].documentURL?.deletingLastPathComponent()
                            destinationPath = destinationPath?.appendingPathComponent("\(text).pdf")
                            try FileManager.default.moveItem(at: originPath!, to: destinationPath!)

                            self.refreshData()
                            self.tableView.reloadData()

                        }
                        catch let error
                        {
                            print("Ooops! Something went wrong: \(error.localizedDescription)")
                        }
                    }
                }
                
            })
                        
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:alertController.textFields?[0], queue: OperationQueue.main) { (notification) -> Void in
                                                                        
                let renameTextField = alertController.textFields![0] as UITextField
                if let text = renameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                {
                    if text.count > 0
                    {
                        renameAction.isEnabled = true
                    }
                    else
                    {
                        renameAction.isEnabled = false
                    }
                }
                else
                {
                    renameAction.isEnabled = false
                }
            }

            
            alertController.addAction(renameAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        })
        editAction.backgroundColor = UIColor.green
        
        return [deleteAction, editAction]
    }
    
    func getfileModifiedDateAndSize(theFile: String) -> String {
        
        var theCreationDate = ""
        do{
            let aFileAttributes = try FileManager.default.attributesOfItem(atPath: theFile) as [FileAttributeKey:Any]
            let date = aFileAttributes[FileAttributeKey.modificationDate] as! Date
            let size = aFileAttributes[FileAttributeKey.size] as! UInt64
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy"
            theCreationDate = "\(formatter.string(from: date))  \(self.covertToFileString(with: size))"
        } catch let theError {
            print("file not found \(theError.localizedDescription)")
        }
        return theCreationDate
    }

    func covertToFileString(with size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }

}
