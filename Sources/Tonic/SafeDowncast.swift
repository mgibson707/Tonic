//
//  SafeDowncast.swift
//  AIMIDI
//
//  Created by Matt on 3/20/23.
//

import Foundation

extension BinaryInteger where Self: FixedWidthInteger {

    /// Safely converts `Float` to `BinaryInteger` (Uint8, Uint16, Int8, and so on), truncate remains that do not fit in the instance of BinaryInteger range value.
    /// For instance, if Float value is 300.934, and self is UInt8, it will be 255, or if Float value is -100.2342, self value will be 0
    init(truncateToFit float: Float) {
        switch float {
        case _ where float < Float(Self.min): self.init(Self.min)
        case _ where float > Float(Self.max): self.init(Self.max)
        default: self.init(float)
        }
    }

    /// Safely converts `Double` to `BinaryInteger` (Uint8, Uint16, Int8, and so on), truncate remains that do not fit in the instance of BinaryInteger range value.
    /// For instance, if Double value is 300.934, and self is UInt8, it will be 255, or if Double value is -100.2342, self value will be 0
    init(truncateToFit double: Double) {
        switch double {
        case _ where double < Double(Self.min): self.init(Self.min)
        case _ where double > Double(Self.max): self.init(Self.max)
        default: self.init(double)
        }
    }
    
    
    /// Safely converts `Int` to `BinaryInteger` (Uint8, Uint16, Int8, and so on), truncate remains that do not fit in the instance of BinaryInteger range value.
    /// For instance, if Int value is 300, and self is UInt8, it will be 255, or if Int value is -100, self value will be 0
    init(truncateToFit int: Int) {
        switch int {
        case _ where int < Self.min: self.init(Self.min)
        case _ where int > Self.max: self.init(Self.max)
        default: self.init(int)
        }
    }
}
