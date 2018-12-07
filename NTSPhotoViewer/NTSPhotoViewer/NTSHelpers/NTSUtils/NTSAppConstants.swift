//
//  NTSAppConstants.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation
import UIKit

/// All storyboard ids
struct StoryboardId {
    static let photoViewer = "NTSPhotoViewer"
}

/// All Reusable Identifiers
struct ReusableIdentifiers {
    static let photoThumbnailCell = "PhotoThumbnailCell"
}

/// All SegueIdentifiers
struct SegueIdentifiers {
    static let seguePhotoDetail = "SeguePhotoDetail"
}

/// All API urls
struct APIRequests {
    static let photoListUrl = "http://jsonplaceholder.typicode.com/photos"
}

/// Status success code
struct StatusCode {
    static let success = 200
}
