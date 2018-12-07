//
//  NTSThumbnailCellViewModel.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation

final class NTSThumbnailCellViewModel {
    // MARK: Variables
    var title: String?
    var thumbnailUrl: String?
    var url: String?
    var id: Int16?
    var albumId: Int16?
    
    /// Method that initializes Thumbnail cell view model
    ///
    /// - Parameters:
    ///     - id: unique photo id
    ///     - albumId: photo album id
    ///     - title: photo title
    ///     - thumbnailUrl: photo thumbnail url
    ///     - url: actual photo url
    /// - Returns: nil
    init(id: Int16?, albumId: Int16?, title: String?, thumbnailUrl: String?, url: String?) {
        self.id = id
        self.albumId = albumId
        self.title = title
        self.thumbnailUrl = thumbnailUrl
        self.url = url
    }
}
