//
//  AvgTimesEntries.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-10-17.
//

import Foundation

struct AvgTimesEntries: Identifiable {
    var id = UUID()
    var hour: Int
    var totalTime: Int
    var averageTime: Double
    var caption: String
    var stringHour: String
}

var emptyAvgTimesData: [AvgTimesEntries] =
[
    AvgTimesEntries(hour: 0, totalTime: 0, averageTime: 0, caption: "00:00", stringHour: "00:00"),
    AvgTimesEntries(hour: 1, totalTime: 0, averageTime: 0, caption: "", stringHour: "01:00"),
    AvgTimesEntries(hour: 2, totalTime: 0, averageTime: 0, caption: "", stringHour: "02:00"),
    AvgTimesEntries(hour: 3, totalTime: 0, averageTime: 0, caption: "", stringHour: "03:00"),
    AvgTimesEntries(hour: 4, totalTime: 0, averageTime: 0, caption: "", stringHour: "04:00"),
    AvgTimesEntries(hour: 5, totalTime: 0, averageTime: 0, caption: "", stringHour: "05:00"),
    AvgTimesEntries(hour: 6, totalTime: 0, averageTime: 0, caption: "06:00", stringHour: "06:00"),
    AvgTimesEntries(hour: 7, totalTime: 0, averageTime: 0, caption: "", stringHour: "07:00"),
    AvgTimesEntries(hour: 8, totalTime: 0, averageTime: 0, caption: "", stringHour: "08:00"),
    AvgTimesEntries(hour: 9, totalTime: 0, averageTime: 0, caption: "", stringHour: "09:00"),
    AvgTimesEntries(hour: 10, totalTime: 0, averageTime: 0, caption: "", stringHour: "10:00"),
    AvgTimesEntries(hour: 11, totalTime: 0, averageTime: 0, caption: "", stringHour: "11:00"),
    AvgTimesEntries(hour: 12, totalTime: 0, averageTime: 0, caption: "12:00", stringHour: "12:00"),
    AvgTimesEntries(hour: 13, totalTime: 0, averageTime: 0, caption: "", stringHour: "13:00"),
    AvgTimesEntries(hour: 14, totalTime: 0, averageTime: 0, caption: "", stringHour: "14:00"),
    AvgTimesEntries(hour: 15, totalTime: 0, averageTime: 0, caption: "", stringHour: "15:00"),
    AvgTimesEntries(hour: 16, totalTime: 0, averageTime: 0, caption: "", stringHour: "16:00"),
    AvgTimesEntries(hour: 17, totalTime: 0, averageTime: 0, caption: "", stringHour: "17:00"),
    AvgTimesEntries(hour: 18, totalTime: 0, averageTime: 0, caption: "18:00", stringHour: "18:00"),
    AvgTimesEntries(hour: 19, totalTime: 0, averageTime: 0, caption: "", stringHour: "19:00"),
    AvgTimesEntries(hour: 20, totalTime: 0, averageTime: 0, caption: "", stringHour: "20:00"),
    AvgTimesEntries(hour: 21, totalTime: 0, averageTime: 0, caption: "", stringHour: "21:00"),
    AvgTimesEntries(hour: 22, totalTime: 0, averageTime: 0, caption: "", stringHour: "22:00"),
    AvgTimesEntries(hour: 23, totalTime: 0, averageTime: 0, caption: "23:00", stringHour: "23:00")
]

struct AvgTimesEntriesMonth: Identifiable {
    var id = UUID()
    var division: Int
    var totalTime: Int
    var averageTime: Double
    var weekString: String
}

var emptyAvgTimesDataMonth: [AvgTimesEntriesMonth] =
[
    AvgTimesEntriesMonth(division: 0, totalTime: 0, averageTime: 0, weekString: "Sun"),
    AvgTimesEntriesMonth(division: 0, totalTime: 0, averageTime: 0, weekString: "Mon"),
    AvgTimesEntriesMonth(division: 0, totalTime: 0, averageTime: 0, weekString: "Tue"),
    AvgTimesEntriesMonth(division: 0, totalTime: 0, averageTime: 0, weekString: "Wed"),
    AvgTimesEntriesMonth(division: 0, totalTime: 0, averageTime: 0, weekString: "Thu"),
    AvgTimesEntriesMonth(division: 0, totalTime: 0, averageTime: 0, weekString: "Fri"),
    AvgTimesEntriesMonth(division: 0, totalTime: 0, averageTime: 0, weekString: "Sat")
]
