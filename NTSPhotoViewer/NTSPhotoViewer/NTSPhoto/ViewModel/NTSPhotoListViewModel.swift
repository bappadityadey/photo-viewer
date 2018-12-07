//
//  NTSPhotoListViewModel.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation

final class NTSPhotoListViewModel: NSObject {
    
    // MARK: Variables
    // cell view models array for photo list
    var cellViewModels: NTSObservable<[NTSThumbnailCellViewModel]> = NTSObservable([])
    var error: NTSObservable<Error> = NTSObservable()

    /// Method that returns thumbnail cell model at perticular indexPath
    ///
    /// - Parameters:
    ///     - index: subscript index of the photo data source
    /// - Returns: Thumbnail cell Model
    func getThumbnailCellModel(at index: Int) -> NTSThumbnailCellViewModel? {
        if let dataSourceItems = cellViewModels.value, !dataSourceItems.isEmpty {
            let photo = dataSourceItems[index]
            return photo
        }
        return nil
    }
    
    /// Method that returns screen title
    ///
    /// - Parameters:
    ///     - nil
    /// - Returns: Title
    func getTitle() -> String {
        return NSLocalizedString("Photo List", comment: "Photo List Title")
    }
    
    /// Method that gets photo list/ API request
    ///
    /// - Parameters:
    ///     - nil
    /// - Returns: nil
    func getPhotoList() {
        let fetcher = NTSPhotoFetcher()
        // invokes photo list API request
        fetcher.invokePhotoListAPIReuest { (photos, error) in
            self.updateDataSource(photos, error)
        }
    }
    
    /// Method that returns photo list items
    ///
    /// - Parameters:
    ///     - nil
    /// - Returns: number of items
    func numberOfRows() -> Int {
        return cellViewModels.value?.count ?? 0
    }
}

//MARK: Update the data source/cell view models based on API response
extension NTSPhotoListViewModel {
    private func updateDataSource(_ photos: [NTSPhotoModel]?, _ error: Error?) {
        var cellModels: [NTSThumbnailCellViewModel] = []
        if let photos = photos, !photos.isEmpty {
            for photo in photos {
                let cellViewModel = NTSThumbnailCellViewModel(id: photo.id, albumId: photo.albumId, title: photo.title, thumbnailUrl: photo.thumbnailUrl, url: photo.url)
                cellModels.append(cellViewModel)
            }
        }
        self.cellViewModels.value = cellModels
        self.error.value = error
    }
    
    /// Method that reloads the data source on pull to refresh
    ///
    /// - Parameters:
    ///     - isRefreshing: Bool to recognize if it's refreshing
    /// - Returns: nil
    func reloadDataSource(_ isRefreshing: Bool = false) {
        getPhotoList()
    }
}
