//
//  DayBarGraphData.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-13.
//

import Foundation

struct WeekTimeDistributionEntries: Identifiable {
    var id = UUID()
    var minutesFocused: Int
    var day: String
}

var emptyWeekData: [WeekTimeDistributionEntries] =
[
    WeekTimeDistributionEntries(minutesFocused: 0, day: "Sun"),
    WeekTimeDistributionEntries(minutesFocused: 0, day: "Mon"),
    WeekTimeDistributionEntries(minutesFocused: 0, day: "Tue"),
    WeekTimeDistributionEntries(minutesFocused: 0, day: "Wed"),
    WeekTimeDistributionEntries(minutesFocused: 0, day: "Thu"),
    WeekTimeDistributionEntries(minutesFocused: 0, day: "Fri"),
    WeekTimeDistributionEntries(minutesFocused: 0, day: "Sat")
]

