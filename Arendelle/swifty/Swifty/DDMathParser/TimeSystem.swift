//
//  TimeSystem.swift
//  Swifty
//
//  Created by Pouya Kary on 1/27/15.
//  Copyright (c) 2015 Arendelle Language. All rights reserved.
//

import Foundation


func timeDate () -> String {
    var calendar: NSCalendar = NSCalendar.currentCalendar()
    let now = NSDate()
    let seventies = NSDate(timeIntervalSince1970: 0)
    let flags = NSCalendarUnit.DayCalendarUnit
    let components = calendar.components(flags, fromDate: now, toDate: seventies, options: nil)
    return "\(-components.day)"
}


func timeYear () -> String {
    let calendar = NSCalendar.currentCalendar()
    let date = NSDate()
    let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMonth, fromDate: date)
    return "\(components.year)"
}