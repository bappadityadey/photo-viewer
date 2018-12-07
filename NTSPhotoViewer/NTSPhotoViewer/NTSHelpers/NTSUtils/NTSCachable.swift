//
//  NTSCachable.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation
import UIKit

// Cacheble protocol
protocol NTSCachable {}

// ImageCache private instance
private let imageCache = NSCache<NSString, UIImage>()

// UIImageview conforms to NTSCachable
extension UIImageView: NTSCachable {}

// On success completion
typealias SuccessHandler = (Bool) -> Void

// Creating a protocol extension to add optional function implementations,
extension NTSCachable where Self: UIImageView {
    func loadThumbnailWithUrl(_ URLString: String, placeHolder: UIImage?, completion: @escaping SuccessHandler) {
        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            DispatchQueue.main.async {
                self.image = cachedImage
                completion(true)
            }
            return
        }
        self.image = placeHolder
        
        if let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }
                if httpResponse.statusCode == StatusCode.success {
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                            DispatchQueue.main.async {
                                self.image = downloadedImage
                                completion(true)
                            }
                        }
                    }
                } else {
                    self.image = placeHolder
                    print(error?.localizedDescription ?? "Response Error")
                }
            }).resume()
        } else {
            self.image = placeHolder
        }
    }
}
