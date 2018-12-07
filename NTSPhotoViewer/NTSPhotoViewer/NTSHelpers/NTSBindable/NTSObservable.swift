//
//  NTSObservable.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation

class NTSObservable<ObservedType> {
    
    // MARK: Variables
    typealias Observer = (_ observable: NTSObservable<ObservedType>, ObservedType) -> Void
    
    var observers: [Observer]
    
    var value: ObservedType? {
        didSet {
            if let value = value {
                notifyObservers(value)
            }
        }
    }
    
    // MARK: Initialisation
    init(_ value: ObservedType? = nil) {
        self.value = value
        observers = []
    }
    
    // MARK: - Binder
    func bind(observer: @escaping Observer) {
        self.observers.append(observer)
    }
    
    // MARK: - Notifier
    func notifyObservers(_ value: ObservedType) {
        self.observers.forEach { [unowned self] (observer) in
            observer(self, value)
        }
    }
    
    func removeObservers() {
        self.observers.removeAll()
    }
}
