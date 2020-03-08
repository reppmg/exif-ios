//
//  PHAsset.swift
//  exifdemo-ios
//
//  Created by Farrux Hewson on 06/03/2020.
//  Copyright © 2020 bakerystud. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {

    var originalFilename: String? {
        var fname:String?
        let resources = PHAssetResource.assetResources(for: self)
        if let resource = resources.first {
            fname = resource.originalFilename
        }
        return fname?.fileName()
    }
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        }
    }
}
