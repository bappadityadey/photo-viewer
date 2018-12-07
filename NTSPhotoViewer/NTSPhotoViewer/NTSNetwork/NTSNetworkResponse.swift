//
//  NTSNetworkResponse.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation

final class NTSNetworkResponse {
    var request: URL?
    let urlResponse: URLResponse?
    let data: Any?
    var error: Error?
    
    //MARK: - Init NetworkAPIResponse
    init(request: URL? = nil,
         urlResponse: URLResponse? = nil,
         data: Any? = nil,
         error: Error? = nil) {
        self.request = request
        self.urlResponse = urlResponse
        self.data = data
        self.error = error
    }
}
