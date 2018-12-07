//
//  NTSThumbnailCell.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import UIKit

final class NTSThumbnailCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    // NTSThumbnailCellViewModel instance
    private var viewModel: NTSThumbnailCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: Populate the photo cell with title and thumbnail photo
    func populate(from model: NTSThumbnailCellViewModel?) {
        title?.text = model?.title
        if let imageUrl = model?.thumbnailUrl {
            thumbnailImageView?.loadThumbnailWithUrl(imageUrl, placeHolder: #imageLiteral(resourceName: "previewThumbnail")) { (_) in
            }
        }
    }
}

// MARK: - Configurable
extension NTSThumbnailCell: Configurable {
    func bind(to model: NTSThumbnailCellViewModel) {
        viewModel = model
    }
}
