//
//  NTSPhotoDetailViewModel.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 25/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation

final class NTSPhotoDetailViewModel: NSObject {
    // MARK: Variables
    var actualUrl: String?
    var error: NTSObservable<Error> = NTSObservable()
    var imagePath: NTSObservable<String> = NTSObservable("")
    
    /// Method that initializes Photo Detail view model
    ///
    /// - Parameters:
    ///     - actualUrl: actual photo url
    /// - Returns: nil
    init(with actualUrl: String?) {
        self.actualUrl = actualUrl
    }
    
    /// Method that returns screen title
    ///
    /// - Parameters:
    ///     - nil
    /// - Returns: Title
    func getTitle() -> String {
        return NSLocalizedString("Photo Detail", comment: "Photo Detail Title")
    }
    
    /// Method that gets actual photo/ Download API request
    ///
    /// - Parameters:
    ///     - nil
    /// - Returns: nil
    func downloadActualPhoto() {
        if let imageUrl = actualUrl, let imgUrl = URL(string: imageUrl) {
            let fetcher = NTSPhotoFetcher()
            // invokes API request
            fetcher.invokePhotoDownloadAPIRequest(with: imgUrl) { (imagePath, error) in
                self.imagePath.value = imagePath
                self.error.value = error
            }
        }
    }
}
