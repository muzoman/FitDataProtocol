//
//  HeartRateZoneMessage.swift
//  FitDataProtocol
//
//  Created by Kevin Hoogheem on 2/10/18.
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
import FitnessUnits

/// FIT Heart Rate Zone Message
@available(swift 4.2)
@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
open class HeartRateZoneMessage: FitMessage {

    /// FIT Message Global Number
    public override class func globalMessageNumber() -> UInt16 { return 8 }

    /// Message Index
    private(set) public var messageIndex: MessageIndex?

    /// Heart Rate Zone Name
    private(set) public var name: String?

    /// Heart Rate High Level
    private(set) public var heartRate: ValidatedMeasurement<UnitCadence>?

    public required init() {}

    public init(messageIndex: MessageIndex? = nil,
                name: String? = nil,
                heartRate: UInt8? = nil) {

        self.messageIndex = messageIndex
        self.name = name

        if let hr = heartRate {
            let valid = hr.isValidForBaseType(FitCodingKeys.highBpm.baseType)
            self.heartRate = ValidatedMeasurement(value: Double(hr), valid: valid, unit: UnitCadence.beatsPerMinute)
        }
    }

    /// Decode Message Data into FitMessage
    ///
    /// - Parameters:
    ///   - fieldData: FileData
    ///   - definition: Definition Message
    ///   - dataStrategy: Decoding Strategy
    /// - Returns: FitMessage
    /// - Throws: FitError
    internal override func decode(fieldData: FieldData, definition: DefinitionMessage, dataStrategy: FitFileDecoder.DataDecodingStrategy) throws -> HeartRateZoneMessage  {

        var messageIndex: MessageIndex?
        var name: String?
        var heartRate: UInt8?

        let arch = definition.architecture

        var localDecoder = DecodeData()

        for definition in definition.fieldDefinitions {

            let key = FitCodingKeys(intValue: Int(definition.fieldDefinitionNumber))

            switch key {
            case .none:
                // We still need to pull this data off the stack
                let _ = localDecoder.decodeData(fieldData.fieldData, length: Int(definition.size))
                //print("HeartRateZoneMessage Unknown Field Number: \(definition.fieldDefinitionNumber)")

            case .some(let converter):
                switch converter {

                case .highBpm:
                    let value = localDecoder.decodeUInt8(fieldData.fieldData)
                    if value.isValidForBaseType(definition.baseType) {
                        // 1 * bpm + 0
                        heartRate = value
                    } else {
                        if let value = ValidatedBinaryInteger<UInt8>.invalidValue(definition.baseType, dataStrategy: dataStrategy) {
                            heartRate = value.value
                        } else {
                            heartRate = nil
                        }
                    }

                case .name:
                    name = String.decode(decoder: &localDecoder,
                                         definition: definition,
                                         data: fieldData,
                                         dataStrategy: dataStrategy)

                case .messageIndex:
                    messageIndex = MessageIndex.decode(decoder: &localDecoder,
                                                       endian: arch,
                                                       definition: definition,
                                                       data: fieldData)

                }
            }
        }

        return HeartRateZoneMessage(messageIndex: messageIndex,
                                    name: name,
                                    heartRate: heartRate)
    }

    /// Encodes the Definition Message for FitMessage
    ///
    /// - Parameters:
    ///   - fileType: FileType
    ///   - dataValidityStrategy: Validity Strategy
    /// - Returns: DefinitionMessage
    /// - Throws: FitError
    internal override func encodeDefinitionMessage(fileType: FileType?, dataValidityStrategy: FitFileEncoder.ValidityStrategy) throws -> DefinitionMessage {

        //try validateMessage(fileType: fileType, dataValidityStrategy: dataValidityStrategy)

        var fileDefs = [FieldDefinition]()

        for key in FitCodingKeys.allCases {

            switch key {
            case .highBpm:
                if let _ = heartRate { fileDefs.append(key.fieldDefinition()) }
            case .name:
                if let stringData = name?.data(using: .utf8) {
                    //16 typical size... but we will count the String

                    guard stringData.count <= UInt8.max else {
                        throw FitError(.encodeError(msg: "name size can not exceed 255"))
                    }

                    fileDefs.append(key.fieldDefinition(size: UInt8(stringData.count)))
                }
            case .messageIndex:
                if let _ = messageIndex { fileDefs.append(key.fieldDefinition()) }
            }
        }

        if fileDefs.count > 0 {

            let defMessage = DefinitionMessage(architecture: .little,
                                               globalMessageNumber: HeartRateZoneMessage.globalMessageNumber(),
                                               fields: UInt8(fileDefs.count),
                                               fieldDefinitions: fileDefs,
                                               developerFieldDefinitions: [DeveloperFieldDefinition]())

            return defMessage
        } else {
            throw FitError(.encodeError(msg: "HeartRateZoneMessage contains no Properties Available to Encode"))
        }
    }

    /// Encodes the Message into Data
    ///
    /// - Parameters:
    ///   - localMessageType: Message Number, that matches the defintions header number
    ///   - definition: DefinitionMessage
    /// - Returns: Data representation
    /// - Throws: FitError
    internal override func encode(localMessageType: UInt8, definition: DefinitionMessage) throws -> Data {

        guard definition.globalMessageNumber == type(of: self).globalMessageNumber() else  {
            throw FitError(.encodeError(msg: "Wrong DefinitionMessage used for Encoding HeartRateZoneMessage"))
        }

        var msgData = Data()

        for key in FitCodingKeys.allCases {

            switch key {
            case .highBpm:
                if let heartRate = heartRate {
                    // 1 * bpm + 0
                    let value = heartRate.value.resolutionUInt8(1)

                    msgData.append(value)
                }

            case .name:
                if let name = name {
                    if let stringData = name.data(using: .utf8) {
                        msgData.append(stringData)
                    }
                }

            case .messageIndex:
                if let messageIndex = messageIndex {
                    msgData.append(messageIndex.encode())
                }
            }
        }

        if msgData.count > 0 {
            var encodedMsg = Data()

            let recHeader = RecordHeader(localMessageType: localMessageType, isDataMessage: true)
            encodedMsg.append(recHeader.normalHeader)
            encodedMsg.append(msgData)

            return encodedMsg

        } else {
            throw FitError(.encodeError(msg: "HeartRateZoneMessage contains no Properties Available to Encode"))
        }
    }

}
