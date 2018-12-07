//
//  NTSPhotoModel.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation

struct NTSPhotoModel: Codable {
    var albumId: Int16?
    var id: Int16?
    var title: String?
    var url: String?
    var thumbnailUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case albumId
        case id
        case title
        case url
        case thumbnailUrl
    }
}
