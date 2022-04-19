//
//  ThumbnailGridCell.swift
//  PDFViewer
//
//  Created by Macbook Pro on 07/05/18.
//  Copyright © 2018 Kaushik Gadhiya. All rights reserved.
//

import UIKit

class ThumbnailGridCell: UICollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            imageView.alpha = isHighlighted ? 0.8 : 1
        }
    }
    var image: UIImage? = nil {
        didSet {
            imageView.image = image
        }
    }
    var pageNumber = 0 {
        didSet {
            pageNumberLabel.text = String(pageNumber + 1)
        }
    }
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var pageNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
//        pageNumberLabel.isHidden = true
    }

    override func prepareForReuse() {
        imageView.image = nil
    }
}
