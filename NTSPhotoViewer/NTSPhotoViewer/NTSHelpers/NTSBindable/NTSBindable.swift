//
//  NTSBindable.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation
import UIKit

protocol NTSBindable: NSObjectProtocol {
    associatedtype BindingType: Equatable
    
    func observingValue() -> BindingType?
    func updateValue(with value: BindingType)
    func bind(with observable: NTSObservable<BindingType>)
}

private struct AssociatedKeys {
    static var binder: UInt8 = 0
}

extension NTSBindable where Self: NSObject {
    
    private var binder: NTSObservable<BindingType> {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.binder) as? NTSObservable<BindingType> else {
                let newValue = NTSObservable<BindingType>()
                
                objc_setAssociatedObject(self, &AssociatedKeys.binder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return newValue
            }
            
            return value
            
        } set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.binder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func getBinderValue() -> BindingType? {
        return binder.value
    }
    
    func setBinderValue(with value: BindingType?) {
        binder.value = value
    }
    
    func register(for observable: NTSObservable<BindingType>) {
        binder = observable
    }
    
    func valueChanged() {
        if binder.value != self.observingValue() {
            setBinderValue(with: self.observingValue())
        }
    }
    
    func bind(with observable: NTSObservable<BindingType>) {
        
        if let _self = self as? UIControl {
            _self.addTarget(Selector, action: Selector { self.valueChanged() }, for: [.editingChanged, .valueChanged])
        }
        
        self.binder = observable
        
        if let val = observable.value {
            self.updateValue(with: val)
        }
        
        self.observe(for: [observable]) { (value) in
            self.updateValue(with: value)
        }
    }
}
