//
//  Double.swift
//  exifdemo-ios
//
//  Created by Farrux Hewson on 07/03/2020.
//  Copyright © 2020 bakerystud. All rights reserved.
//

import Foundation

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
