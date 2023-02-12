//
//  NSCache+Subscript.swift
//  textExample
//
//  Created by youme on 2023/02/12.
//

import Foundation

extension NSCache where KeyType == NSString, ObjectType == CacheEntryObject {
    subscript(_ url: URL) -> CacheEntry? {
        get {
            let key = url.absoluteString as NSString
            let value = self.object(forKey: key)
            return value?.entry
        }
        set {
            let key = url.absoluteString as NSString
            if let entry = newValue {
                let value = CacheEntryObject(entry: entry)
                self.setObject(value, forKey: key)
            } else {
                self.removeObject(forKey: key)
            }
        }
    }
}
