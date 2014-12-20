//
//  Logger.swift
//  MagicalMapper
//
//  Created by Aryan on 9/1/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

public class Logger {
    
    var logLevel: LogLevel
    
    init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }
    
    func logInfo(message: String) {
        log(message, level: .Info)
    }
    
    func logWarning(message: String) {
        log(message, level: .Warning)
    }
    
    func logError(message: String) {
        log(message, level: .Error)
    }
    
    func log(message: String, level: LogLevel) {
        if (level.rawValue >= self.logLevel.rawValue) {
            println(message)
        }
    }
    
}
