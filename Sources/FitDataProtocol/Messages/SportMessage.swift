//
//  SportMessage.swift
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
import AntMessageProtocol

/// FIT Sport Message
@available(swift 4.2)
@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
open class SportMessage: FitMessage {

    /// FIT Message Global Number
    public override class func globalMessageNumber() -> UInt16 { return 12 }

    /// Sport Name
    private(set) public var name: String?

    /// Sport
    private(set) public var sport: Sport?

    /// Sub Sport
    private(set) public var subSport: SubSport?

    public required init() {}

    public init(name: String? = nil, sport: Sport? = nil, subSport: SubSport? = nil) {
        self.name = name
        self.sport = sport
        self.subSport = subSport
    }

    /// Decode Message Data into FitMessage
    ///
    /// - Parameters:
    ///   - fieldData: FileData
    ///   - definition: Definition Message
    ///   - dataStrategy: Decoding Strategy
    /// - Returns: FitMessage
    /// - Throws: FitError
    internal override func decode(fieldData: FieldData, definition: DefinitionMessage, dataStrategy: FitFileDecoder.DataDecodingStrategy) throws -> SportMessage  {

        var name: String?
        var sport: Sport?
        var subSport: SubSport?

        ///let arch = definition.architecture

        var localDecoder = DecodeData()

        for definition in definition.fieldDefinitions {

            let key = FitCodingKeys(intValue: Int(definition.fieldDefinitionNumber))

            switch key {
            case .none:
                // We still need to pull this data off the stack
                let _ = localDecoder.decodeData(fieldData.fieldData, length: Int(definition.size))
                //print("SportMessage Unknown Field Number: \(definition.fieldDefinitionNumber)")

            case .some(let converter):
                switch converter {

                case .sport:
                    sport = Sport.decode(decoder: &localDecoder,
                                         definition: definition,
                                         data: fieldData,
                                         dataStrategy: dataStrategy)

                case .subSport:
                    subSport = SubSport.decode(decoder: &localDecoder,
                                               definition: definition,
                                               data: fieldData,
                                               dataStrategy: dataStrategy)

                case .name:
                    name = String.decode(decoder: &localDecoder,
                                         definition: definition,
                                         data: fieldData,
                                         dataStrategy: dataStrategy)

                case .timestamp:
                    let _ = localDecoder.decodeData(fieldData.fieldData, length: Int(definition.size))

                }
            }
        }

        return SportMessage(name: name,
                            sport: sport,
                            subSport: subSport)
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
            case .sport:
                if let _ = sport { fileDefs.append(key.fieldDefinition()) }
            case .subSport:
                if let _ = subSport { fileDefs.append(key.fieldDefinition()) }
            case .name:
                if let stringData = name?.data(using: .utf8) {
                    //16 typical size... but we will count the String

                    guard stringData.count <= UInt8.max else {
                        throw FitError(.encodeError(msg: "name size can not exceed 255"))
                    }

                    fileDefs.append(key.fieldDefinition(size: UInt8(stringData.count)))
                }
            case .timestamp:
                break
            }
        }

        if fileDefs.count > 0 {

            let defMessage = DefinitionMessage(architecture: .little,
                                               globalMessageNumber: SportMessage.globalMessageNumber(),
                                               fields: UInt8(fileDefs.count),
                                               fieldDefinitions: fileDefs,
                                               developerFieldDefinitions: [DeveloperFieldDefinition]())

            return defMessage
        } else {
            throw FitError(.encodeError(msg: "SportMessage contains no Properties Available to Encode"))
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
            throw FitError(.encodeError(msg: "Wrong DefinitionMessage used for Encoding SportMessage"))
        }

        var msgData = Data()

        for key in FitCodingKeys.allCases {

            switch key {
            case .sport:
                if let sport = sport {
                    msgData.append(sport.rawValue)
                }

            case .subSport:
                if let subSport = subSport {
                    msgData.append(subSport.rawValue)
                }

            case .name:
                if let name = name {
                    if let stringData = name.data(using: .utf8) {
                        msgData.append(stringData)
                    }
                }

            case .timestamp:
                break
            }
        }

        if msgData.count > 0 {
            var encodedMsg = Data()

            let recHeader = RecordHeader(localMessageType: localMessageType, isDataMessage: true)
            encodedMsg.append(recHeader.normalHeader)
            encodedMsg.append(msgData)

            return encodedMsg

        } else {
            throw FitError(.encodeError(msg: "SportMessage contains no Properties Available to Encode"))
        }
    }

}
