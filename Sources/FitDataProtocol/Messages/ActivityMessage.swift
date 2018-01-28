//
//  ActivityMessage.swift
//  FitDataProtocol
//
//  Created by Kevin Hoogheem on 1/28/18.
//

import Foundation
import DataDecoder

/// FIT Activity Message
@available(swift 3.1)
@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
open class ActivityMessage: FitMessage, FitMessageKeys {

    public override func globalMessageNumber() -> UInt16 {
        return 34
    }

    public enum MessageKeys: Int, CodingKey {
        case totalTimerTime     = 0
        case numberOfSessions   = 1
        case activityType       = 2
        case event              = 3
        case eventType          = 4
        case localTimestamp     = 5
        case eventGroup         = 6

        case timestamp          = 253
    }

    public typealias FitCodingKeys = MessageKeys

    /// Timestamp
    private(set) public var timeStamp: FitTime?

    /// Total Timer Time
    ///
    /// Excludes pauses
    private(set) public var totalTimerTime: Measurement<UnitDuration>?

    /// Local Timestamp
    /// Timestamp
    private(set) public var localTimeStamp: FitTime?

    /// Number of Sessions
    private(set) public var numberOfSessions: UInt16?

    /// Activity
    private(set) public var activity: Activity?

    /// Event
    private(set) public var event: Event?

    /// Event Type
    private(set) public var eventType: EventType?

    /// Event Group
    private(set) public var eventGroup: UInt8?


    public required init() {}

    public init(timeStamp: FitTime?, totalTimerTime: Measurement<UnitDuration>?, localTimeStamp: FitTime?, numberOfSessions: UInt16?, activity: Activity?, event: Event?, eventType: EventType?, eventGroup: UInt8?) {
        self.timeStamp = timeStamp
        self.totalTimerTime = totalTimerTime
        self.localTimeStamp = localTimeStamp
        self.numberOfSessions = numberOfSessions
        self.event = event
        self.eventType = eventType
        self.eventGroup = eventGroup
    }

    internal override func decode(fieldData: Data, definition: DefinitionMessage) throws -> ActivityMessage  {

        var timeStamp: FitTime?
        var totalTimerTime: Measurement<UnitDuration>?
        var localTimeStamp: FitTime?
        var numberOfSessions: UInt16?
        var activity: Activity?
        var event: Event?
        var eventType: EventType?
        var eventGroup: UInt8?

        let arch = definition.architecture

        var localDecoder = DataDecoder(fieldData)

        for definition in definition.fieldDefinitions {

            let key = FitCodingKeys(intValue: Int(definition.fieldDefinitionNumber))

            switch key {
            case .none:
                // We still need to pull this data off the stack
                let _ = localDecoder.decodeData(length: Int(definition.size))
                print("Unknown Field Number: \(definition.fieldDefinitionNumber)")

            case .some(let converter):
                switch converter {
                case .totalTimerTime:
                    let value = arch == .little ? localDecoder.decodeUInt32().littleEndian : localDecoder.decodeUInt32().bigEndian
                    if UInt64(value) != definition.baseType.invalid {
                        // 1000 * s + 0
                        let value = Double(value) / 1000
                        totalTimerTime = Measurement(value: value, unit: UnitDuration.seconds)
                    }

                case .numberOfSessions:
                    let value = arch == .little ? localDecoder.decodeUInt16().littleEndian : localDecoder.decodeUInt16().bigEndian
                    if UInt64(value) != definition.baseType.invalid {
                        numberOfSessions = value
                    }
                    
                case .activityType:
                    let value = localDecoder.decodeUInt8()
                    activity = Activity(rawValue: value)

                case .event:
                    let value = localDecoder.decodeUInt8()
                    event = Event(rawValue: value)

                case .eventType:
                    let value = localDecoder.decodeUInt8()
                    eventType = EventType(rawValue: value)

                case .localTimestamp:
                    let value = arch == .little ? localDecoder.decodeUInt32().littleEndian : localDecoder.decodeUInt32().bigEndian
                    if UInt64(value) != definition.baseType.invalid {
                        localTimeStamp = FitTime(time: value, isLocal: true)
                    }

                case .eventGroup:
                    let value = localDecoder.decodeUInt8()
                    if UInt64(value) != definition.baseType.invalid {
                        eventGroup = value
                    }
                    
                case .timestamp:
                    let value = arch == .little ? localDecoder.decodeUInt32().littleEndian : localDecoder.decodeUInt32().bigEndian
                    if UInt64(value) != definition.baseType.invalid {
                        timeStamp = FitTime(time: value)
                    }
                }

            }
        }

        return ActivityMessage(timeStamp: timeStamp,
                               totalTimerTime: totalTimerTime,
                               localTimeStamp: localTimeStamp,
                               numberOfSessions: numberOfSessions,
                               activity: activity,
                               event: event, eventType: eventType,
                               eventGroup: eventGroup)
    }

}
