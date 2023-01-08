//
//  MonthData.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-10-15.
//

import Foundation

//struct MonthData: Identifiable {
//    var id = UUID()
//    var minutesFocused: Int
//    var day: Int
//    var caption: String
//}

struct TimeDistributionEntries: Identifiable {
    var id = UUID()
    var minutesFocused: Int
    var hourOrDay: Int
    var caption: String
}

var emptyDayTimeDistributionData: [TimeDistributionEntries] =
[
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 0, caption: "00:00"),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 1, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 2, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 3, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 4, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 5, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 6, caption: "06:00"),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 7, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 8, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 9, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 10, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 11, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 12, caption: "12:00"),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 13, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 14, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 15, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 16, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 17, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 18, caption: "18:00"),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 19, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 20, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 21, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 22, caption: ""),
    TimeDistributionEntries(minutesFocused: 0, hourOrDay: 23, caption: "23:00")
]

func calculateFocusedMinutes(startTime: Date, endTime: Date) -> Int {
    let calendar = Calendar.current
    let start = calendar.dateComponents([.hour, .minute], from: startTime)
    let end = calendar.dateComponents([.hour, .minute], from: endTime)
    return calendar.dateComponents([.minute], from: start, to: end).minute!
}

func getHour(time: Date) -> Int {
    let calendar = Calendar.current
    return calendar.dateComponents([.hour], from: time).hour!
}

func getMinutes(time: Date) -> Int {
    let calendar = Calendar.current
    return calendar.dateComponents([.minute], from: time).minute!
}

func getStartOfMonth(date: Date) -> Date {
    let calendar = Calendar.current
    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: date)))!
    return (startOfMonth)
}

func getEndOfMonth(date: Date) -> Date {
    let calendar = Calendar.current
    let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: getStartOfMonth(date: date))!
    return endOfMonth
}

func getCurrentMonth(date: Date) -> Int? {
    let calendar = Calendar.current
    let startOfMonth = getStartOfMonth(date: date)
    let components = calendar.dateComponents([.month], from: startOfMonth)
    return components.month
}
