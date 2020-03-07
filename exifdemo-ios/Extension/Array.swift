//
//  Array.swift
//  exifdemo-ios
//
//  Created by Farrux Hewson on 07/03/2020.
//  Copyright © 2020 bakerystud. All rights reserved.
//

import Foundation

extension Array {
    mutating func modifyForEach(_ body: (_ index: Index, _ element: inout Element) -> ()) {
        for index in indices {
            modifyElement(atIndex: index) { body(index, &$0) }
        }
    }
    
    private mutating func modifyElement(atIndex index: Index, _ modifyElement: (_ element: inout Element) -> ()) {
        var element = self[index]
        modifyElement(&element)
        self[index] = element
    }
}
