//
//  NTSExtensions.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation
import UIKit

// MARK: - General Extensions
extension NSObject {
    /// Gives the string value of any NSObject instance
    var className: String {
        return String(describing: type(of: self))
    }
    /// Gives the string value of any NSObject instance
    class var className: String {
        return String(describing: self)
    }
}

extension UIViewController {
    /// Initialises Any type of UIViewController
    ///
    /// - Parameters:
    ///   - type: A generic instance of type UIViewController
    ///   - storyboardName: A String value which defines the storyboard name from which the UIViewController should be initialised
    ///   - storyboardId: A String value which defines an unique identifier for each UIViewController instance
    ///   - bundle: A Bundle instance
    /// - Returns: Type of UIViewController
    class func getViewController<T>(ofType type: T.Type,
                                    fromStoryboardName storyboardName: String,
                                    storyboardId: String,
                                    bundle: Bundle) -> T? where T: UIViewController {
        let designatedViewController = UIStoryboard(name: storyboardName, bundle: bundle).instantiateViewController(withIdentifier: storyboardId)
        return designatedViewController as? T
    }
}
