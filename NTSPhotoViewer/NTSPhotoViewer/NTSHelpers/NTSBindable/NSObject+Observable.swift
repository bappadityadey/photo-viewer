//
//  NSObject+Observable.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation

extension NSObject {
    func observe<T>(for observables: [NTSObservable<T>], with: @escaping (T) -> Void) {
        for observable in observables {
            observable.bind { (_, value)  in
                DispatchQueue.main.async {
                    with(value)
                }
            }
        }
    }
}
