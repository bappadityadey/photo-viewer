//
//  NTSPhotoFetcher.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation

class NTSPhotoFetcher {
    //Mark: Variables
    /// checks the network availability
    var isNetworkAvailable: Bool {
        return NTSAppDelegate.appDelegateInstance?.isReachable ?? false
    }
    //MARK: Photo List API Request
    func invokePhotoListAPIReuest(with handler: @escaping (_ photos: [NTSPhotoModel]?, _ error: Error?) -> Void) {
        if isNetworkAvailable {
            NTSAPIClient.sendPhotoListRequest { (response) in
                if let json = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
                        let photos = try decoder.decode(Array<NTSPhotoModel>.self, from: jsonData)
                        handler(photos, nil)
                    } catch {
                        print(error.localizedDescription)
                    }
                } else {
                    handler(nil, response.error)
                }
            }
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No internet connection available"])
            handler(nil, error)
        }
    }
}

//MARK: Photo Download API Request
extension NTSPhotoFetcher {
    func invokePhotoDownloadAPIRequest(with imageUrl: URL, handler: @escaping (PhotoDownloadHandler)) {
        if isNetworkAvailable {
            NTSAPIClient.sendDownloadFileAsync(url: imageUrl) { (imagePath, error) in
                handler(imagePath, error)
            }
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No internet connection available"])
            handler(nil, error)
        }
    }
}
