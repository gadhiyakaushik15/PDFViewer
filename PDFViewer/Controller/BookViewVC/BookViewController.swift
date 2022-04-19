//
//  BookViewController.swift
//  PDFViewer
//
//  Created by Macbook Pro on 04/05/18.
//  Copyright © 2018 Kaushik Gadhiya. All rights reserved.
//

import UIKit
import PDFKit
import Firebase

class BookViewController: UIViewController,PDFViewDelegate,UIGestureRecognizerDelegate,BookmarkViewControllerDelegate, SearchViewControllerDelegate, GADInterstitialDelegate {
    
    var interstitial: GADInterstitial!
    
    var pdfDocument: PDFDocument?
    var pdfView: PDFView!
    var selectedAnnotation: PDFAnnotation?
    var isAnnotationClicked : Bool = false
    var isViewAppear : Bool!
    
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var pageNumberLabelContainer: UIView!
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(pdfViewPageChanged(_:)), name: .PDFViewPageChanged, object: nil)
       
         NotificationCenter.default.addObserver(self, selector: #selector(pdfViewAnnotationClicked(_:)), name: .PDFViewAnnotationHit, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(MenuControllerWillHideMenu(_:)), name: UIMenuController.willHideMenuNotification, object: nil)
       
        
        pdfView = PDFView.init(frame: self.view.bounds)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        pdfView.addGestureRecognizer(tap)
        
        self.view.addSubview(pdfView)
        self.view.bringSubviewToFront(pageNumberLabelContainer)
        
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
       
        if var path = pdfDocument!.documentURL
        {
            path = path.deletingPathExtension()
            self.title = path.lastPathComponent
        }
        pageNumberLabelContainer.layer.cornerRadius = 4
        pageNumberLabel.text = pdfView.currentPage?.label
        updateBookmarkStatus()
        
        interstitial = createAndLoadInterstitial()

        // Do any additional setup after loading the view.
    }

    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: adsInterstitialID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial)
    {
        if ad.isReady
        {
            ad.present(fromRootViewController: self)
        }
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError)
    {
        interstitial = createAndLoadInterstitial()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func handleTap (_ sender: UITapGestureRecognizer )
    {
        if (pdfView.currentSelection != nil)
        {
            pdfView.clearSelection()
        }
        else
        {
            self.navigationController?.setToolbarHidden(!(self.navigationController?.isToolbarHidden)!, animated: true)
            self.navigationController?.setNavigationBarHidden(!(self.navigationController?.isNavigationBarHidden)!, animated: true)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
        isViewAppear = true
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
        isViewAppear = false
    }
    
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        let copyMenuItem = UIMenuItem(title: "Copy", action: #selector(self.copy_Action))
        
        let highlightMenuItem = UIMenuItem(title: "Highlight", action: #selector(self.hightLight_Action))
        
        let strikethroughMenuItem = UIMenuItem(title: "Strikethrough", action: #selector(self.strikethrough_Action))
        
        let underlineMenuItem = UIMenuItem(title: "Underline", action: #selector(self.underline_Action))
        
        let defineMenuItem = UIMenuItem(title: "Define", action: #selector(self.define_Action))
        
        let noteMenuItem = UIMenuItem(title: "Note", action: #selector(self.note_Action))
        
        let textMenuItem = UIMenuItem(title: "Text", action: #selector(self.text_Action))
        
        let freehandMenuItem = UIMenuItem(title: "Freehand", action: #selector(self.freehand_Action))
        
        let clearMenuItem = UIMenuItem(title: "Clear", action: #selector(self.clear_Action))
        
        UIMenuController.shared.menuItems = [copyMenuItem, highlightMenuItem,strikethroughMenuItem,underlineMenuItem,defineMenuItem,noteMenuItem,textMenuItem,freehandMenuItem,clearMenuItem]
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        UIMenuController.shared.menuItems = nil
    }
    
    
    @IBAction func hightLight_Action()
    {
        guard let selections = pdfView.currentSelection?.selectionsByLine() else { return }
        guard let page = selections.first?.pages.first else { return }
        
        for selection in selections
        {
            let highlight = PDFAnnotation(bounds: selection.bounds(for: page), forType: .highlight, withProperties: nil)
            
            highlight.startLineStyle = .square
            highlight.endLineStyle = .square
            highlight.color = UIColor.yellow
            
            page.addAnnotation(highlight)
            page.displaysAnnotations = true
        }
        
       
    }
    @IBAction func copy_Action()
    {
        print(pdfView.currentSelection?.selectionsByLine().first?.string as Any)
        UIPasteboard.general.string =  pdfView.currentSelection?.selectionsByLine().first?.string
    }
    @IBAction func strikethrough_Action()
    {
        
        guard let selections = pdfView.currentSelection?.selectionsByLine() else { return }
        guard let page = selections.first?.pages.first else { return }
        
        for selection in selections
        {
            let strikethrough = PDFAnnotation(bounds: selection.bounds(for: page), forType: .strikeOut, withProperties: nil)
            
            strikethrough.startLineStyle = .square
            strikethrough.endLineStyle = .square
            strikethrough.color = UIColor.red
            
            page.addAnnotation(strikethrough)
            page.displaysAnnotations = true
        }
        
    }
    @IBAction func underline_Action()
    {
        guard let selections = pdfView.currentSelection?.selectionsByLine() else { return }
        guard let page = selections.first?.pages.first else { return }
        
        for selection in selections
        {
            let underline = PDFAnnotation(bounds: selection.bounds(for: page), forType: .underline, withProperties: nil)
            
            underline.startLineStyle = .square
            underline.endLineStyle = .square
            underline.color = UIColor.red
            
            page.addAnnotation(underline)
            page.displaysAnnotations = true
        }
        
    }
    @IBAction func define_Action()
    {
        guard let word = pdfView.currentSelection?.selectionsByLine().first?.string else { return }
        let ref  = UIReferenceLibraryViewController(term: word)
        ref.title = word
        let nav = UINavigationController.init(rootViewController: ref)
        nav.navigationBar.prefersLargeTitles = true
        nav.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        self.present(nav, animated: true, completion: nil)
        
    }
    @IBAction func note_Action()
    {
        guard let selections = pdfView.currentSelection?.selectionsByLine() else { return }
        guard let page = selections.first?.pages.first else { return }
        
        for selection in selections
        {
            let note = PDFAnnotation(bounds: selection.bounds(for: page), forType: .circle, withProperties: nil)
          
            note.iconType = .comment
            note.caption = "Test Comments"
            
            page.addAnnotation(note)
            page.displaysAnnotations = true
        }
    }
    @IBAction func text_Action()
    {
        
    }
    @IBAction func freehand_Action()
    {
        
    }
    
    @IBAction func clear_Action()
    {
        pdfView.currentPage?.removeAnnotation(selectedAnnotation!)
    }
    
    @objc func pdfViewPageChanged(_ notification: Notification)
    {
        pageNumberLabel.text = pdfView.currentPage?.label
        updateBookmarkStatus()
    }
    func updateBookmarkStatus()
    {
        if let documentURL = pdfDocument?.documentURL?.absoluteString,
            let bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int],
            let currentPage = pdfView.currentPage,
            let index = pdfDocument?.index(for: currentPage)
        {
            bookmarkButton.image = bookmarks.contains(index) ? #imageLiteral(resourceName: "BookmarkRemove") : #imageLiteral(resourceName: "BookmarkAdd")
        }
    }
    @objc func pdfViewAnnotationClicked(_ notification: Notification)
    {
        isAnnotationClicked = true
        guard let anootation = notification.userInfo?["PDFAnnotationHit"] as? PDFAnnotation else { return }
         selectedAnnotation = anootation
        
        let frame = pdfView.convert((selectedAnnotation?.bounds)!, from:(selectedAnnotation?.page)!)
        
        let menuController = UIMenuController.shared
        menuController.setTargetRect(frame, in: pdfView)
        menuController.setMenuVisible(true, animated: true)
    }
    
    @objc func MenuControllerWillHideMenu(_ notification: Notification)
    {
        if isAnnotationClicked
        {
            isAnnotationClicked = false
        }
        
    }
    
    @IBAction func save_Action(_ sender: Any)
    {
        
        DispatchQueue.global(qos: .background).async
        {
            if (self.pdfView.document?.write(to: (self.pdfDocument?.documentURL)!))!
            {
                Helper.sharedInstance.showAlert(delegate: self, alertContentText: "File saved successfully.")
            }
            else
            {
                Helper.sharedInstance.showAlert(delegate: self, alertContentText: "Please try again.")
            }
        }
        
    }
    
    @IBAction func share_Action(_ sender: Any)
    {
        let activityVC = UIActivityViewController(activityItems: [self.pdfDocument?.documentURL as Any], applicationActivities: nil)
        
        self.present(activityVC, animated: true, completion: nil)
    }
    @IBAction func pageList_Action(_ sender: Any)
    {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "BookmarkViewController") as! BookmarkViewController
       
        controller.pdfDocument = pdfDocument
        controller.isBookmark = false
        controller.delegate = self
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func bookMarks_Action(_ sender: Any)
    {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "BookmarkViewController") as! BookmarkViewController
        
        controller.pdfDocument = pdfDocument
        controller.isBookmark = true
        controller.delegate = self
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func addOrRemoveBookmark_Action(_ sender: Any)
    {
        if let documentURL = pdfDocument?.documentURL?.absoluteString
        {
            var bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int] ?? [Int]()
            if let currentPage = pdfView.currentPage,
                let pageIndex = pdfDocument?.index(for: currentPage)
            {
                if let index = bookmarks.firstIndex(of: pageIndex)
                {
                    bookmarks.remove(at: index)
                    UserDefaults.standard.set(bookmarks, forKey: documentURL)
                    bookmarkButton.image = #imageLiteral(resourceName: "BookmarkAdd")
                }
                else
                {
                    UserDefaults.standard.set((bookmarks + [pageIndex]).sorted(), forKey: documentURL)
                    bookmarkButton.image = #imageLiteral(resourceName: "BookmarkRemove")
                }
            }
        }
    }
    @IBAction func search_Action(_ sender: Any)
    {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        controller.delegate = self
        controller.pdfDocument = pdfDocument
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - BookmarkViewControllerDelegate
    func bookmarkViewController(_ bookmarkViewController: BookmarkViewController, didSelectPage page: PDFPage)
    {
         pdfView.go(to: page)
    }
     // MARK: - SearchViewControllerDelegate
    func searchViewController(_ SearchTableViewController: SearchTableViewController, didSelectSearchResult selection: PDFSelection)
    {
        selection.color = .yellow
        pdfView.currentSelection = selection
        pdfView.go(to: selection.pages.first!)
    }
    
    // MARK: - UIMenuController override Method
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool
    {
        
        if isAnnotationClicked
        {
            if action == #selector(self.clear_Action)
            {
                return true
            }
            else
            {
                return false
            }
            
        }
        
        else
        {
            if action == #selector(self.copy_Action)
            {
                return true
            }
            else if action == #selector(self.hightLight_Action)
            {
                return true
            }
            else if action == #selector(self.strikethrough_Action)
            {
                return true
            }
            else if action == #selector(self.underline_Action)
            {
                return true
            }
            else if action == #selector(self.define_Action)
            {
                return true
            }
            else if action == #selector(self.note_Action)
            {
                return true
            }
            else if action == #selector(self.text_Action)
            {
                return true
            }
            else if action == #selector(self.freehand_Action)
            {
                return true
            }
            else
            {
                return false
            }
           
        }
       
    }
    override var canBecomeFirstResponder: Bool
    {
        if isViewAppear
        {
            return true
        }
        else
        {
            return false
        }
        
    }
   
    override var canResignFirstResponder: Bool
    {
        if isViewAppear
        {
            return false
        }
        else
        {
            return true
        }
    }
   

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
         if let navController = segue.destination as? UINavigationController
        {
            if let viewController = navController.topViewController as? SearchTableViewController
            {
                viewController.pdfDocument = pdfDocument
                viewController.delegate = self
            }
        }
    }

}
