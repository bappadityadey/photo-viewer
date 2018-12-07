//
//  NTSProtocols.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Enum Collection
/// Enum Collection Handler protocol
protocol EnumCollection: Hashable {
    /// Gives all case conditions of the enum
    static func cases() -> AnySequence<Self>
    /// Gives all values of the enum
    static var allValues: [Self] { get }
}

// MARK: - Generic Configurable
/// Generic Configurable Protocol.
/// Mostly useful for binding different types of ViewModels to the ViewController
protocol Configurable {
    /// Generic Type
    associatedtype T
    /// Binds generic model to the conforming class
    ///
    /// - Parameters:
    ///   - model: generic type model
    func bind(to model: T)
}

/// Two way binding protocol
protocol TwoWayBinding: Configurable {
    /// Bind UI elements with the ViewModel (Two-Way binding)
    /// - Parameters:
    ///   - model: Any type of ViewModel
    func bindUI(with viewModel: T?)
}
