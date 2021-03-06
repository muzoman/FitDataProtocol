//
//  UserProfileMessage.swift
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
import FitnessUnits
import AntMessageProtocol

/// FIT File User Profile Message
@available(swift 4.2)
@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
open class UserProfileMessage: FitMessage {

    /// FIT Message Global Number
    public override class func globalMessageNumber() -> UInt16 { return 3 }

    /// Timestamp
    private(set) public var timeStamp: FitTime?

    /// Message Index
    private(set) public var messageIndex: MessageIndex?

    /// Friendly Name
    private(set) public var friendlyName: String?

    /// Weight
    private(set) public var weight: ValidatedMeasurement<UnitMass>?

    /// Speed Setting
    private(set) public var speedSetting: MeasurementDisplayType?

    /// Heartrate Display Setting
    private(set) public var heartRateSetting: HeartRateDisplayType?

    /// Distance Setting
    private(set) public var distanceSetting: PositionDisplayType?

    /// Power Setting
    private(set) public var powerSetting: PowerDisplayType?

    /// Position Setting
    private(set) public var positionSetting: PositionDisplayType?

    /// Temperature Setting
    private(set) public var temperatureSetting: MeasurementDisplayType?

    /// Local ID
    private(set) public var localID: ValidatedBinaryInteger<UInt16>?

    /// Height Setting
    private(set) public var heightSetting: MeasurementDisplayType?

    /// Running Step Length
    private(set) public var runningStepLength: ValidatedMeasurement<UnitLength>?

    /// Walking Step Length
    private(set) public var walkingStepLength: ValidatedMeasurement<UnitLength>?

    /// Gender
    private(set) public var gender: Gender?

    /// Age in Years
    private(set) public var age: ValidatedMeasurement<UnitDuration>?

    /// Height
    private(set) public var height: ValidatedMeasurement<UnitLength>?

    /// Language
    private(set) public var language: Language?

    /// Elevation Settings
    private(set) public var elevationSetting: MeasurementDisplayType?

    /// Weight Settings
    private(set) public var weightSetting: MeasurementDisplayType?

    /// Resting Heart Rate
    private(set) public var restingHeartRate: ValidatedMeasurement<UnitCadence>?

    /// Max Running Heart Rate
    private(set) public var maxRunningHeartRate: ValidatedMeasurement<UnitCadence>?

    /// Max Biking Heart Rate
    private(set) public var maxBikingHeartRate: ValidatedMeasurement<UnitCadence>?

    /// Max Heart Rate
    private(set) public var maxHeartRate: ValidatedMeasurement<UnitCadence>?

    public required init() {}

    public init(timeStamp: FitTime? = nil,
                messageIndex: MessageIndex? = nil,
                friendlyName: String? = nil,
                weight: ValidatedMeasurement<UnitMass>? = nil,
                speedSetting: MeasurementDisplayType? = nil,
                heartRateSetting: HeartRateDisplayType? = nil,
                distanceSetting: PositionDisplayType? = nil,
                powerSetting: PowerDisplayType? = nil,
                positionSetting: PositionDisplayType? = nil,
                temperatureSetting: MeasurementDisplayType? = nil,
                localID: ValidatedBinaryInteger<UInt16>? = nil,
                heightSetting: MeasurementDisplayType? = nil,
                runningStepLength: ValidatedMeasurement<UnitLength>? = nil,
                walkingStepLength: ValidatedMeasurement<UnitLength>? = nil,
                gender: Gender? = nil,
                age: UInt8? = nil,
                height: ValidatedMeasurement<UnitLength>? = nil,
                language: Language? = nil,
                elevationSetting: MeasurementDisplayType? = nil,
                weightSetting: MeasurementDisplayType? = nil,
                restingHeartRate: UInt8? = nil,
                maxRunningHeartRate: UInt8? = nil,
                maxBikingHeartRate: UInt8? = nil,
                maxHeartRate: UInt8? = nil) {

        self.timeStamp = timeStamp
        self.messageIndex = messageIndex

        self.friendlyName = friendlyName
        self.weight = weight
        self.speedSetting = speedSetting
        self.heartRateSetting = heartRateSetting
        self.distanceSetting = distanceSetting
        self.powerSetting = powerSetting
        self.positionSetting = positionSetting
        self.temperatureSetting = temperatureSetting
        self.localID = localID
        self.heightSetting = heightSetting
        self.runningStepLength = runningStepLength
        self.walkingStepLength = walkingStepLength
        self.gender = gender

        if let age = age {
            let valid = age.isValidForBaseType(FitCodingKeys.age.baseType)
            self.age = ValidatedMeasurement(value: Double(age), valid: valid, unit: UnitDuration.year)
        }

        self.height = height
        self.language = language
        self.elevationSetting = elevationSetting
        self.weightSetting = weightSetting

        if let hr = restingHeartRate {
            let valid = hr.isValidForBaseType(FitCodingKeys.restingHeartRate.baseType)
            self.restingHeartRate = ValidatedMeasurement(value: Double(hr), valid: valid, unit: UnitCadence.beatsPerMinute)
        }

        if let hr = maxRunningHeartRate {
            let valid = hr.isValidForBaseType(FitCodingKeys.defaultMaxRunningHeartRate.baseType)
            self.maxRunningHeartRate = ValidatedMeasurement(value: Double(hr), valid: valid, unit: UnitCadence.beatsPerMinute)
        }

        if let hr = maxBikingHeartRate {
            let valid = hr.isValidForBaseType(FitCodingKeys.defaultMaxRunningHeartRate.baseType)
            self.maxBikingHeartRate = ValidatedMeasurement(value: Double(hr), valid: valid, unit: UnitCadence.beatsPerMinute)
        }

        if let hr = maxHeartRate {
            let valid = hr.isValidForBaseType(FitCodingKeys.defaultMaxHeartRate.baseType)
            self.maxHeartRate = ValidatedMeasurement(value: Double(hr), valid: valid, unit: UnitCadence.beatsPerMinute)
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
    internal override func decode(fieldData: FieldData, definition: DefinitionMessage, dataStrategy: FitFileDecoder.DataDecodingStrategy) throws -> UserProfileMessage  {

        var timestamp: FitTime?
        var messageIndex: MessageIndex?
        var friendlyName: String?
        var weight: ValidatedMeasurement<UnitMass>?
        var speedSetting: MeasurementDisplayType?
        var heartRateSetting: HeartRateDisplayType?
        var distanceSetting: PositionDisplayType?
        var powerSetting: PowerDisplayType?
        var positionSetting: PositionDisplayType?
        var temperatureSetting: MeasurementDisplayType?
        var localID: ValidatedBinaryInteger<UInt16>?
        var heightSetting: MeasurementDisplayType?
        var runningStepLength: ValidatedMeasurement<UnitLength>?
        var walkingStepLength: ValidatedMeasurement<UnitLength>?
        var gender: Gender?
        var age: UInt8?
        var height: ValidatedMeasurement<UnitLength>?
        var language: Language?
        var elevationSetting: MeasurementDisplayType?
        var weightSetting: MeasurementDisplayType?
        var restingHeartRate: UInt8?
        var maxRunningHeartRate: UInt8?
        var maxBikingHeartRate: UInt8?
        var maxHeartRate: UInt8?

        let arch = definition.architecture

        var localDecoder = DecodeData()

        for definition in definition.fieldDefinitions {

            let key = FitCodingKeys(intValue: Int(definition.fieldDefinitionNumber))

            switch key {
            case .none:
                // We still need to pull this data off the stack
                let _ = localDecoder.decodeData(fieldData.fieldData, length: Int(definition.size))
                //print("UserProfileMessage Unknown Field Number: \(definition.fieldDefinitionNumber)")

            case .some(let converter):
                switch converter {

                case .friendlyName:
                    friendlyName = String.decode(decoder: &localDecoder,
                                                 definition: definition,
                                                 data: fieldData,
                                                 dataStrategy: dataStrategy)

                case .gender:
                    gender = Gender.decode(decoder: &localDecoder,
                                           definition: definition,
                                           data: fieldData,
                                           dataStrategy: dataStrategy)

                case .age:
                    let value = localDecoder.decodeUInt8(fieldData.fieldData)
                    if value.isValidForBaseType(definition.baseType) {
                        /// 1 * years + 0
                        age = value
                    } else {
                        if let value = ValidatedBinaryInteger<UInt8>.invalidValue(definition.baseType, dataStrategy: dataStrategy) {
                            age = value.value
                        } else {
                            age = nil
                        }
                    }

                case .height:
                    let value = localDecoder.decodeUInt8(fieldData.fieldData)
                    if value.isValidForBaseType(definition.baseType) {
                        //  100 * m + 0
                        let value = value.resolution(1 / 100)
                        height = ValidatedMeasurement(value: value, valid: true, unit: UnitLength.meters)
                    } else {
                        height = ValidatedMeasurement.invalidValue(definition.baseType, dataStrategy: dataStrategy, unit: UnitLength.meters)
                    }

                case .weight:
                    let value = decodeUInt16(decoder: &localDecoder, endian: arch, data: fieldData)
                    if value.isValidForBaseType(definition.baseType) {
                        //  10 * kg + 0
                        let value = value.resolution(1 / 10)
                        weight = ValidatedMeasurement(value: value, valid: true, unit: UnitMass.kilograms)
                    } else {
                        weight = ValidatedMeasurement.invalidValue(definition.baseType, dataStrategy: dataStrategy, unit: UnitMass.kilograms)
                    }

                case .language:
                    language = Language.decode(decoder: &localDecoder,
                                               definition: definition,
                                               data: fieldData,
                                               dataStrategy: dataStrategy)

                case .elevationSetting:
                    elevationSetting = MeasurementDisplayType.decode(decoder: &localDecoder,
                                                                     definition: definition,
                                                                     data: fieldData,
                                                                     dataStrategy: dataStrategy)

                case .weightSetting:
                    weightSetting = MeasurementDisplayType.decode(decoder: &localDecoder,
                                                                  definition: definition,
                                                                  data: fieldData,
                                                                  dataStrategy: dataStrategy)

                case .restingHeartRate:
                    let value = localDecoder.decodeUInt8(fieldData.fieldData)
                    if value.isValidForBaseType(definition.baseType) {
                        // 1 * bpm + 0
                        restingHeartRate = value
                    } else {
                        if let value = ValidatedBinaryInteger<UInt8>.invalidValue(definition.baseType, dataStrategy: dataStrategy) {
                            restingHeartRate = value.value
                        } else {
                            restingHeartRate = nil
                        }
                    }

                case .defaultMaxRunningHeartRate:
                    let value = localDecoder.decodeUInt8(fieldData.fieldData)
                    if value.isValidForBaseType(definition.baseType) {
                        // 1 * bpm + 0
                        maxRunningHeartRate = value
                    } else {
                        if let value = ValidatedBinaryInteger<UInt8>.invalidValue(definition.baseType, dataStrategy: dataStrategy) {
                            maxRunningHeartRate = value.value
                        } else {
                            maxRunningHeartRate = nil
                        }
                    }

                case .defaultMaxBikingHeartRate:
                    let value = localDecoder.decodeUInt8(fieldData.fieldData)
                    if value.isValidForBaseType(definition.baseType) {
                        // 1 * bpm + 0
                        maxBikingHeartRate = value
                    } else {
                        if let value = ValidatedBinaryInteger<UInt8>.invalidValue(definition.baseType, dataStrategy: dataStrategy) {
                            maxBikingHeartRate = value.value
                        } else {
                            maxBikingHeartRate = nil
                        }
                    }

                case .defaultMaxHeartRate:
                    let value = localDecoder.decodeUInt8(fieldData.fieldData)
                    if value.isValidForBaseType(definition.baseType) {
                        // 1 * bpm + 0
                        maxHeartRate = value
                    } else {
                        if let value = ValidatedBinaryInteger<UInt8>.invalidValue(definition.baseType, dataStrategy: dataStrategy) {
                            maxHeartRate = value.value
                        } else {
                            maxHeartRate = nil
                        }
                    }

                case .heartRateSetting:
                    heartRateSetting = HeartRateDisplayType.decode(decoder: &localDecoder,
                                                                   definition: definition,
                                                                   data: fieldData,
                                                                   dataStrategy: dataStrategy)

                case .speedSetting:
                    speedSetting = MeasurementDisplayType.decode(decoder: &localDecoder,
                                                                 definition: definition,
                                                                 data: fieldData,
                                                                 dataStrategy: dataStrategy)

                case .distanceSetting:
                    distanceSetting = PositionDisplayType.decode(decoder: &localDecoder,
                                                                 definition: definition,
                                                                 data: fieldData,
                                                                 dataStrategy: dataStrategy)

                case .powerSetting:
                    powerSetting = PowerDisplayType.decode(decoder: &localDecoder,
                                                           definition: definition,
                                                           data: fieldData,
                                                           dataStrategy: dataStrategy)

                case .activityClass:
                    let _ = localDecoder.decodeData(fieldData.fieldData, length: Int(definition.size))

                case .positionSetting:
                    positionSetting = PositionDisplayType.decode(decoder: &localDecoder,
                                                                 definition: definition,
                                                                 data: fieldData,
                                                                 dataStrategy: dataStrategy)

                case .temperatureSetting:
                    temperatureSetting = MeasurementDisplayType.decode(decoder: &localDecoder,
                                                                       definition: definition,
                                                                       data: fieldData,
                                                                       dataStrategy: dataStrategy)

                case .localID:
                    let value = decodeUInt16(decoder: &localDecoder, endian: arch, data: fieldData)
                    localID = ValidatedBinaryInteger<UInt16>.validated(value: value,
                                                                       definition: definition,
                                                                       dataStrategy: dataStrategy)

                case .globalID:
                    let _ = localDecoder.decodeData(fieldData.fieldData, length: Int(definition.size))

                case .heightSetting:
                    heightSetting = MeasurementDisplayType.decode(decoder: &localDecoder,
                                                                  definition: definition,
                                                                  data: fieldData,
                                                                  dataStrategy: dataStrategy)

                case .runningStepLength:
                    let value = decodeUInt16(decoder: &localDecoder, endian: arch, data: fieldData)
                    if value.isValidForBaseType(definition.baseType) {
                        // 1000 * m + 0, User defined running step length set to 0 for auto length
                        let value = value.resolution(1 / 1000)
                        runningStepLength = ValidatedMeasurement(value: value, valid: true, unit: UnitLength.meters)
                    } else {
                        runningStepLength = ValidatedMeasurement.invalidValue(definition.baseType, dataStrategy: dataStrategy, unit: UnitLength.meters)
                    }

                case .walkingStepLength:
                    let value = decodeUInt16(decoder: &localDecoder, endian: arch, data: fieldData)
                    if value.isValidForBaseType(definition.baseType) {
                        // 1000 * m + 0, User defined running step length set to 0 for auto length
                        let value = value.resolution(1 / 1000)
                        walkingStepLength = ValidatedMeasurement(value: value, valid: true, unit: UnitLength.meters)
                    } else {
                        walkingStepLength = ValidatedMeasurement.invalidValue(definition.baseType, dataStrategy: dataStrategy, unit: UnitLength.meters)
                    }

                case .timestamp:
                    timestamp = FitTime.decode(decoder: &localDecoder,
                                               endian: arch,
                                               definition: definition,
                                               data: fieldData)

                case .messageIndex:
                    messageIndex = MessageIndex.decode(decoder: &localDecoder,
                                                       endian: arch,
                                                       definition: definition,
                                                       data: fieldData)

                }
            }
        }

        return UserProfileMessage(timeStamp: timestamp,
                                  messageIndex: messageIndex,
                                  friendlyName: friendlyName,
                                  weight: weight,
                                  speedSetting: speedSetting,
                                  heartRateSetting: heartRateSetting,
                                  distanceSetting: distanceSetting,
                                  powerSetting: powerSetting,
                                  positionSetting: positionSetting,
                                  temperatureSetting: temperatureSetting,
                                  localID: localID,
                                  heightSetting: heightSetting,
                                  runningStepLength: runningStepLength,
                                  walkingStepLength: walkingStepLength,
                                  gender: gender,
                                  age: age,
                                  height: height,
                                  language: language,
                                  elevationSetting: elevationSetting,
                                  weightSetting: weightSetting,
                                  restingHeartRate: restingHeartRate,
                                  maxRunningHeartRate: maxRunningHeartRate,
                                  maxBikingHeartRate: maxBikingHeartRate,
                                  maxHeartRate: maxHeartRate)
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
            case .friendlyName:
                if let stringData = friendlyName?.data(using: .utf8) {
                    //16 typical size... but we will count the String

                    guard stringData.count <= UInt8.max else {
                        throw FitError(.encodeError(msg: "friendlyName size can not exceed 255"))
                    }

                    fileDefs.append(key.fieldDefinition(size: UInt8(stringData.count)))
                }
            case .gender:
                if let _ = gender { fileDefs.append(key.fieldDefinition()) }
            case .age:
                if let _ = age { fileDefs.append(key.fieldDefinition()) }
            case .height:
                if let _ = height { fileDefs.append(key.fieldDefinition()) }
            case .weight:
                if let _ = weight { fileDefs.append(key.fieldDefinition()) }
            case .language:
                if let _ = language { fileDefs.append(key.fieldDefinition()) }
            case .elevationSetting:
                if let _ = elevationSetting { fileDefs.append(key.fieldDefinition()) }
            case .weightSetting:
                if let _ = weightSetting { fileDefs.append(key.fieldDefinition()) }
            case .restingHeartRate:
                if let _ = restingHeartRate { fileDefs.append(key.fieldDefinition()) }
            case .defaultMaxRunningHeartRate:
                if let _ = maxRunningHeartRate { fileDefs.append(key.fieldDefinition()) }
            case .defaultMaxBikingHeartRate:
                if let _ = maxBikingHeartRate { fileDefs.append(key.fieldDefinition()) }
            case .defaultMaxHeartRate:
                if let _ = maxHeartRate { fileDefs.append(key.fieldDefinition()) }
            case .heartRateSetting:
                if let _ = heartRateSetting { fileDefs.append(key.fieldDefinition()) }
            case .speedSetting:
                if let _ = speedSetting { fileDefs.append(key.fieldDefinition()) }
            case .distanceSetting:
                if let _ = distanceSetting { fileDefs.append(key.fieldDefinition()) }
            case .powerSetting:
                if let _ = powerSetting { fileDefs.append(key.fieldDefinition()) }
            case .activityClass:
                break
            case .positionSetting:
                if let _ = positionSetting { fileDefs.append(key.fieldDefinition()) }
            case .temperatureSetting:
                if let _ = temperatureSetting { fileDefs.append(key.fieldDefinition()) }
            case .localID:
                if let _ = localID { fileDefs.append(key.fieldDefinition()) }
            case .globalID:
                break
            case .heightSetting:
                if let _ = heightSetting { fileDefs.append(key.fieldDefinition()) }
            case .runningStepLength:
                if let _ = runningStepLength { fileDefs.append(key.fieldDefinition()) }
            case .walkingStepLength:
                if let _ = walkingStepLength { fileDefs.append(key.fieldDefinition()) }
            case .timestamp:
                if let _ = timeStamp { fileDefs.append(key.fieldDefinition()) }
            case .messageIndex:
                if let _ = messageIndex { fileDefs.append(key.fieldDefinition()) }
            }
        }

        if fileDefs.count > 0 {

            let defMessage = DefinitionMessage(architecture: .little,
                                               globalMessageNumber: UserProfileMessage.globalMessageNumber(),
                                               fields: UInt8(fileDefs.count),
                                               fieldDefinitions: fileDefs,
                                               developerFieldDefinitions: [DeveloperFieldDefinition]())

            return defMessage
        } else {
            throw FitError(.encodeError(msg: "UserProfileMessage contains no Properties Available to Encode"))
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
            throw FitError(.encodeError(msg: "Wrong DefinitionMessage used for Encoding UserProfileMessage"))
        }

        var msgData = Data()

        for key in FitCodingKeys.allCases {

            switch key {
            case .friendlyName:
                if let friendlyName = friendlyName {
                    if let stringData = friendlyName.data(using: .utf8) {
                        msgData.append(stringData)
                    }
                }

            case .gender:
                if let gender = gender {
                    msgData.append(gender.rawValue)
                }

            case .age:
                if var age = age {
                    /// 1 * years
                    age = age.converted(to: UnitDuration.year)
                    let value = age.value.resolutionUInt8(1)

                    msgData.append(value)
                }

            case .height:
                if var height = height {
                    //  100 * m + 0
                    height = height.converted(to: UnitLength.meters)
                    let value = height.value.resolutionUInt8(100)

                    msgData.append(value)
                }

            case .weight:
                if var weight = weight {
                    //  10 * kg + 0
                    weight = weight.converted(to: UnitMass.kilograms)
                    let value = weight.value.resolutionUInt16(10)

                    msgData.append(Data(from: value.littleEndian))
                }

            case .language:
                if let language = language {
                    msgData.append(language.rawValue)
                }

            case .elevationSetting:
                if let elevationSetting = elevationSetting {
                    msgData.append(elevationSetting.rawValue)
                }

            case .weightSetting:
                if let weightSetting = weightSetting {
                    msgData.append(weightSetting.rawValue)
                }

            case .restingHeartRate:
                if let restingHeartRate = restingHeartRate {
                    // 1 * bpm + 0
                    let value = restingHeartRate.value.resolutionUInt8(1)

                    msgData.append(UInt8(value))
                }

            case .defaultMaxRunningHeartRate:
                if let maxRunningHeartRate = maxRunningHeartRate {
                    // 1 * bpm + 0
                    let value = maxRunningHeartRate.value.resolutionUInt8(1)

                    msgData.append(UInt8(value))
                }

            case .defaultMaxBikingHeartRate:
                if let maxBikingHeartRate = maxBikingHeartRate {
                    // 1 * bpm + 0
                    let value = maxBikingHeartRate.value.resolutionUInt8(1)

                    msgData.append(UInt8(value))
                }

            case .defaultMaxHeartRate:
                if let maxHeartRate = maxHeartRate {
                    // 1 * bpm + 0
                    let value = maxHeartRate.value.resolutionUInt8(1)

                    msgData.append(UInt8(value))
                }

            case .heartRateSetting:
                if let heartRateSetting = heartRateSetting {
                    msgData.append(heartRateSetting.rawValue)
                }

            case .speedSetting:
                if let speedSetting = speedSetting {
                    msgData.append(speedSetting.rawValue)
                }

            case .distanceSetting:
                if let distanceSetting = distanceSetting {
                    msgData.append(distanceSetting.rawValue)
                }

            case .powerSetting:
                if let powerSetting = powerSetting {
                    msgData.append(powerSetting.rawValue)
                }

            case .activityClass:
                break

            case .positionSetting:
                if let positionSetting = positionSetting {
                    msgData.append(positionSetting.rawValue)
                }

            case .temperatureSetting:
                if let temperatureSetting = temperatureSetting {
                    msgData.append(temperatureSetting.rawValue)
                }

            case .localID:
                if let localID = localID {
                    msgData.append(Data(from: localID.value.littleEndian))
                }

            case .globalID:
                break

            case .heightSetting:
                if let heightSetting = heightSetting {
                    msgData.append(heightSetting.rawValue)
                }

            case .runningStepLength:
                if var runningStepLength = runningStepLength {
                    // 1000 * m + 0, User defined running step length set to 0 for auto length
                    runningStepLength = runningStepLength.converted(to: UnitLength.meters)
                    let value = runningStepLength.value.resolutionUInt16(1000)

                    msgData.append(Data(from: value.littleEndian))
                }

            case .walkingStepLength:
                if var walkingStepLength = walkingStepLength {
                    // 1000 * m + 0, User defined running step length set to 0 for auto length
                    walkingStepLength = walkingStepLength.converted(to: UnitLength.meters)
                    let value = walkingStepLength.value.resolutionUInt16(1000)

                    msgData.append(Data(from: value.littleEndian))
                }

            case .timestamp:
                if let timestamp = timeStamp {
                    msgData.append(timestamp.encode())
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
            throw FitError(.encodeError(msg: "UserProfileMessage contains no Properties Available to Encode"))
        }
    }

}
