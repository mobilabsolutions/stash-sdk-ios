//
//  Logger.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 15/08/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

// Logging level determines how much output will be logged in console
@objc public enum LoggingLevel: Int, Comparable {
    case none
    // logs errors and network requests/responses
    case normal
    // logs normal + important points in SDK lifecycle
    case developer

    public static func < (lhs: LoggingLevel, rhs: LoggingLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// A class used for logging data in a console
public class Log {
    /// Prints message if logging level is equal or greater then .normal
    ///
    /// - Parameters:
    ///   - message: The message that should be printed to console
    public static func normal(message: String) {
        if self.loggingLevel >= LoggingLevel.normal {
            print("\(self.dateFormatter.string(from: Date())) Stash SDK -> \(message)")
        }
    }

    /// Prints error description if logging level is equal or greater then .normal.
    ///
    /// - Parameters:
    ///   - description: Error description that should be printed to console
    ///   - filename: Name of the file from which this function has been called.
    ///   - line: Code line on which this function has been called.
    ///   - funcName: Name of the function in which this function has been called.
    public static func error(description: String,
                             filename: String,
                             line: Int,
                             funcName: String) {
        if self.loggingLevel >= LoggingLevel.normal {
            print("\(self.dateFormatter.string(from: Date())) Stash SDK Error [\(self.sourceFileName(filePath: filename))]:\(line) \(funcName) -> \(description)")
        }
    }

    /// Prints important SDK flow/lifecycle events if logging level is equal or greater then .developer
    ///
    /// - Parameters:
    ///   - message: The message that should be printed to console
    ///   - filename: Name of the file from which this function has been called. Autopopulated by special literal available in Swift
    ///   - funcName: Name of the function in which this function has been called. Autopopulated by special literal available in Swift
    public static func event(description: String,
                             filename _: String = #file,
                             funcName: String = #function) {
        if self.loggingLevel >= LoggingLevel.developer {
            print("\(self.dateFormatter.string(from: Date())) Stash SDK \(funcName) -> \(description)")
        }
    }

    private static var loggingLevel: LoggingLevel {
        return InternalPaymentSDK.sharedInstance.configuration.loggingLevel
    }

    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }

    private static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
}
