//
//  SearchResultsCell.swift
//  PDFViewer
//
//  Created by Macbook Pro on 08/05/18.
//  Copyright © 2018 Kaushik Gadhiya. All rights reserved.
//

import UIKit

class SearchResultsCell: UITableViewCell {
    var section: String? = nil {
        didSet {
            sectionLabel.text = section
        }
    }
    var page: String? = nil {
        didSet {
            pageNumberLabel.text = page
        }
    }
    var resultText: String? = nil
    var searchText: String? = nil

    @IBOutlet private weak var sectionLabel: UILabel!
    @IBOutlet private weak var pageNumberLabel: UILabel!
    @IBOutlet private weak var resultTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        sectionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        pageNumberLabel.textColor = .gray
        pageNumberLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        resultTextLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let highlightRange = (resultText! as NSString).range(of: searchText!, options: .caseInsensitive)
        let attributedString = NSMutableAttributedString(string: resultText!)
        attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: resultTextLabel.font.pointSize)], range: highlightRange)
        resultTextLabel.attributedText = attributedString
    }
}
