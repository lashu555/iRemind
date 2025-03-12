//
//  PhotosTransformer.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 12.03.25.
//

import Foundation
import UIKit

@objc(PhotosTransformer)
class PhotosTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let images = value as? [UIImage] else { return nil }
        return images.compactMap { $0.pngData() }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let dataArray = value as? [Data] else { return nil }
        return dataArray.compactMap { UIImage(data: $0) }
    }
}
