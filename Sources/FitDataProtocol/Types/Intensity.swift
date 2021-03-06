//
//  Intensity.swift
//  FitDataProtocol
//
//  Created by Kevin Hoogheem on 2/3/18.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import DataDecoder

/// Intensity
public enum Intensity: UInt8 {
    /// Active
    case active         = 0
    /// Rest
    case rest           = 1
    /// Warmup
    case warmup         = 2
    /// Cooldown
    case cooldown       = 3

    /// Invalid
    case invalid        = 255
}

internal extension Intensity {

    internal static func decode(decoder: inout DecodeData, definition: FieldDefinition, data: FieldData, dataStrategy: FitFileDecoder.DataDecodingStrategy) -> Intensity? {

        let value = decoder.decodeUInt8(data.fieldData)
        if value.isValidForBaseType(definition.baseType) {
            return Intensity(rawValue: value)
        } else {

            switch dataStrategy {
            case .nil:
                return nil
            case .useInvalid:
                return Intensity.invalid
            }
        }
    }
}
