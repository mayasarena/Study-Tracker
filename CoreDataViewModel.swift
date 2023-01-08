//
//  CoreDataTut.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-04.
//

import SwiftUI
import CoreData


class CoreDataViewModel: ObservableObject {
    
    static let instance = CoreDataViewModel() // Singleton
    let container: NSPersistentContainer
    
    @Published var timerViewSelectedTopicEntity: TopicEntity? = nil
    @Published var topicEditorSelectedTopic: TopicEntity? = nil
    @Published var times: [TimeEntity] = []
    @Published var sortedTimes: [TimeEntity] = []
    @Published var topics: [TopicEntity] = []
    @Published var topicSearchedByName: [TopicEntity] = []
    @Published var groupedByDateTimes: [[TimeEntity]] = [[]]
    
    // FOR STATS VIEW
    @Published var dayTimeDistributionData: [TimeDistributionEntries] = []
    @Published var dayPieChartData: [PieChartEntries] = []
    @Published var dayFocusTrend: [FocusTrendsEntries] = []
    
    @Published var weekTimeDistributionData: [WeekTimeDistributionEntries] = []
    @Published var weekPieChartData: [PieChartEntries] = []
    @Published var weekAvgTimesData: [AvgTimesEntries] = []
    @Published var weekFocusTrend: [WeekFocusTrendsEntries] = []
    
    @Published var monthTimeDistributionData: [TimeDistributionEntries] = []
    @Published var monthPieChartData: [PieChartEntries] = []
    //@Published var monthAvgTimesData: [AvgTimesEntries] = []
    @Published var monthAvgTimes: [AvgTimesEntriesMonth] = []
    @Published var monthFocusTrend: [MonthFocusTrendsEntries] = []
    
    private var filteredByDayTimes: [TimeEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "CoreDataContainer")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("ERROR LOADING CORE DATA. \(error)")
            }
        }
        getTimes()
        getTopics()
        fetchMonthFocusTrend(date: Date())
        fetchWeekFocusTrend(date: Date())
        fetchWeekData(date: Date())
        fetchMonthData(date: Date())
        fetchDayFocusTrend(date: Date())
        //fetchWeekPieChartData(date: Date())
        //fetchMonthPieChartData(date: Date())
        getTimes(forDay: Date())
    }
    
    func save() {
        do {
            try container.viewContext.save()
            print("Saved successfully!")
        } catch let error {
            print("Error saving Core Data. \(error.localizedDescription)")
        }
    }
    
    func getTimes() {
        let request = NSFetchRequest<TimeEntity>(entityName: "TimeEntity")
        let sortedRequest = NSFetchRequest<TimeEntity>(entityName: "TimeEntity")
        let sort = NSSortDescriptor(keyPath: \TimeEntity.startTime, ascending: true)
        sortedRequest.sortDescriptors = [sort]
        
        do {
            times = try container.viewContext.fetch(request)
            sortedTimes = try container.viewContext.fetch(sortedRequest)
            print("Data fetched successfully.")
            
            // Sectioned times
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd yyyy"
            dateFormatter.locale = Calendar.current.locale!
            groupedByDateTimes = Dictionary(grouping: times) { (entity: TimeEntity) in dateFormatter.string(from: entity.startTime ?? Date())}.map(\.value)
        } catch let error {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    // Fetching times for specific date
    func getTimes(forDay date: Date) {
        let request = NSFetchRequest<TimeEntity>(entityName: "TimeEntity")
        
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)
        
        let sort = NSSortDescriptor(keyPath: \TimeEntity.startTime, ascending: true)
        request.sortDescriptors = [sort]
        
        let filter = NSPredicate(format: "startTime >= %@ AND startTime < %@", start as NSDate, end! as NSDate)
        request.predicate = filter
        
        do {
            filteredByDayTimes = try container.viewContext.fetch(request)
            fetchDayData(filteredTimes: filteredByDayTimes)
            //fetchDayPieChartData(filteredTimes: filteredByDayTimes)
            print("Data fetched successfully.")
        } catch let error {
            print("Error fetching. \(error.localizedDescription)")
        }
    }

    func fetchDayData(filteredTimes: [TimeEntity]) {
        dayTimeDistributionData = emptyDayTimeDistributionData
        dayPieChartData = []
        
        for entity in filteredTimes {
            let startTime = entity.startTime ?? Date()
            let endTime = entity.endTime ?? Date()
            let minsFocused = calculateFocusedMinutes(startTime: startTime, endTime: endTime)
            var minsLeft = minsFocused
            let index = dayPieChartData.firstIndex(where: {$0.topicEntity == entity.topic})
            // For pie chart data
            if index != nil {
                dayPieChartData[index ?? 0].totalMinsFocused = dayPieChartData[index ?? 0].totalMinsFocused + CGFloat(minsFocused)
            }
            else if let topicEntity = entity.topic {
                dayPieChartData.append(PieChartEntries(topicEntity: topicEntity, color: TopicColors().convertStringToColor(color: topicEntity.color ?? ""), totalMinsFocused: CGFloat(minsFocused), percent: 0, topicName: topicEntity.topic ?? ""))
            }
            else {
                dayPieChartData.append(PieChartEntries(topicEntity: nil, color: UIColor(Color.theme.defaultTopicColor), totalMinsFocused: CGFloat(minsFocused), percent: 0, topicName: "Untagged")) // Adding blank topic
            }
            // For bar chart data
            if getHour(time: entity.startTime ?? Date()) != getHour(time: endTime) {
                var currentHour = getHour(time: startTime)
                let endingHour = getHour(time: endTime)
                dayTimeDistributionData[currentHour].minutesFocused = dayTimeDistributionData[currentHour].minutesFocused + (60 - getMinutes(time: startTime))
                minsLeft -= (60 - getMinutes(time: startTime))
                currentHour += 1
                while currentHour < endingHour {
                    dayTimeDistributionData[currentHour].minutesFocused = 60
                    currentHour += 1
                }
                dayTimeDistributionData[currentHour].minutesFocused = dayTimeDistributionData[currentHour].minutesFocused + getMinutes(time: endTime)
            } else {
                dayTimeDistributionData[getHour(time: entity.startTime ?? Date())].minutesFocused = dayTimeDistributionData[getHour(time: entity.startTime ?? Date())].minutesFocused + minsFocused
            }
        }
        // Find total minutes (FOR PIE CHART)
        var totalMinsFocusedToday = CGFloat(0)
        for item in dayPieChartData {
            totalMinsFocusedToday = totalMinsFocusedToday + item.totalMinsFocused
        }
        // Calculate percentages (FOR PIE CHART)
        for i in 0..<dayPieChartData.count {
            let value = dayPieChartData[i].totalMinsFocused / totalMinsFocusedToday
            let rounded = round(value * 100) / 100.0
            dayPieChartData[i].percent = rounded * 100
        }
    }
    
    func fetchDayFocusTrend(date: Date) {
        dayFocusTrend = emptyTrendData
        var beforeYesterdayFocusedTime = 0
        var yesterdayFocusedTime = 0
        var todayFocusedTime = 0
        // get current time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let currentTime = dateFormatter.string(from: date)
        // get yesterday
        let calendar = Calendar.current
        let beforeYesterday = calendar.date(byAdding: .day, value: -2, to: date)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: date)
        // get yesterday times
        getTimes(forDay: beforeYesterday ?? Date())
        
        // DAY BEFORE YESTERDAY
        for timeEntity in filteredByDayTimes {
            let beforeYesterdayStartTime = dateFormatter.string(from: timeEntity.startTime ?? Date())
            let beforeYesterdayEndTime = dateFormatter.string(from: timeEntity.endTime ?? Date())
            if beforeYesterdayEndTime < currentTime {
                let focusedMins = calculateFocusedMinutes(startTime: timeEntity.startTime ?? Date(), endTime: timeEntity.endTime ?? Date())
                beforeYesterdayFocusedTime = beforeYesterdayFocusedTime + focusedMins
            }
            else if ((beforeYesterdayStartTime < currentTime) && (beforeYesterdayEndTime > currentTime)) {
                let focusedMins = calculateFocusedMinutes(startTime: timeEntity.startTime ?? Date(), endTime: beforeYesterday ?? Date())
                beforeYesterdayFocusedTime = beforeYesterdayFocusedTime + focusedMins
            }
        }
        let totalFocusedMinsBeforeYesterday = getTotalMinutesDay()
        
        getTimes(forDay: yesterday ?? Date())
        // YESTERDAY
        for timeEntity in filteredByDayTimes {
            let yesterdayStartTime = dateFormatter.string(from: timeEntity.startTime ?? Date())
            let yesterdayEndTime = dateFormatter.string(from: timeEntity.endTime ?? Date())
            if yesterdayEndTime < currentTime {
                let focusedMins = calculateFocusedMinutes(startTime: timeEntity.startTime ?? Date(), endTime: timeEntity.endTime ?? Date())
                yesterdayFocusedTime = yesterdayFocusedTime + focusedMins
            }
            else if ((yesterdayStartTime < currentTime) && (yesterdayEndTime > currentTime)) {
                let focusedMins = calculateFocusedMinutes(startTime: timeEntity.startTime ?? Date(), endTime: yesterday ?? Date())
                yesterdayFocusedTime = yesterdayFocusedTime + focusedMins
            }
        }
        let totalFocusedMinsYesterday = getTotalMinutesDay()
        
        // TODAY
        getTimes(forDay: Date())
        for timeEntity in filteredByDayTimes {
            let focusedMins = calculateFocusedMinutes(startTime: timeEntity.startTime ?? Date(), endTime: timeEntity.endTime ?? Date())
            todayFocusedTime = todayFocusedTime + focusedMins
        }
        let totalFocusedMinsToday = getTotalMinutesDay()
        
        dayFocusTrend[0].minsUpToNow = todayFocusedTime
        dayFocusTrend[0].totalMins = totalFocusedMinsToday
        dayFocusTrend[1].minsUpToNow = yesterdayFocusedTime
        dayFocusTrend[1].totalMins = totalFocusedMinsYesterday
        dayFocusTrend[2].minsUpToNow = beforeYesterdayFocusedTime
        dayFocusTrend[2].totalMins = totalFocusedMinsBeforeYesterday
        dayFocusTrend[0].time = currentTime
        dayFocusTrend[1].time = currentTime
        dayFocusTrend[2].time = currentTime
    }

    func fetchWeekData(date: Date) {
        weekTimeDistributionData = emptyWeekData
        weekAvgTimesData = emptyAvgTimesData
        weekPieChartData = []
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: date)
        
        guard let firstDayOfWeek = week?.start else {
            return
        }
        
        (0...6).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstDayOfWeek) {
                var totalFocusedMinutes = 0
                getTimes(forDay: weekday)
                // For bar graph data
                for item in dayTimeDistributionData {
                    totalFocusedMinutes = totalFocusedMinutes + item.minutesFocused
                    weekAvgTimesData[item.hourOrDay].totalTime = weekAvgTimesData[item.hourOrDay].totalTime + item.minutesFocused
                }
                weekTimeDistributionData[day].minutesFocused = totalFocusedMinutes
                
                // For Pie chart data
                for entity in filteredByDayTimes {
                    let startTime = entity.startTime ?? Date()
                    let endTime = entity.endTime ?? Date()
                    let minsFocused = calculateFocusedMinutes(startTime: startTime, endTime: endTime)
                    let index = weekPieChartData.firstIndex(where: {$0.topicEntity == entity.topic})
                    if index != nil {
                        weekPieChartData[index ?? 0].totalMinsFocused = weekPieChartData[index ?? 0].totalMinsFocused + CGFloat(minsFocused)
                    }
                    else if let topicEntity = entity.topic {
                        weekPieChartData.append(PieChartEntries(topicEntity: topicEntity, color: TopicColors().convertStringToColor(color: topicEntity.color ?? ""), totalMinsFocused: CGFloat(minsFocused), percent: 0, topicName: topicEntity.topic ?? ""))
                    }
                    else {
                        weekPieChartData.append(PieChartEntries(topicEntity: nil, color: UIColor(Color.theme.defaultTopicColor), totalMinsFocused: CGFloat(minsFocused), percent: 0, topicName: "Untagged")) // Adding blank topic
                    }
                }
            }
        }
        // Find total minutes (FOR PIE CHART)
        var totalMinsFocusedThisWeek = CGFloat(0)
        for item in weekPieChartData {
            totalMinsFocusedThisWeek = totalMinsFocusedThisWeek + item.totalMinsFocused
        }
        // Calculate percentages (FOR PIE CHART)
        for i in 0..<weekPieChartData.count {
            let value = weekPieChartData[i].totalMinsFocused / totalMinsFocusedThisWeek
            let rounded = round(value * 100) / 100.0
            weekPieChartData[i].percent = rounded * 100
        }
        
        // FOR AVG TIMES PLOT
        // getting current week
        let currentWeekStartDay = calendar.dateInterval(of: .weekOfMonth, for: Date())
        let givenWeekStartDay = calendar.dateInterval(of: .weekOfMonth, for: date)
        
        if givenWeekStartDay == currentWeekStartDay {
            let comps = calendar.dateComponents([.weekday], from: Date())
            let currentWeekday = Double(comps.weekday ?? 0)
            for i in 0..<weekAvgTimesData.count {
                weekAvgTimesData[i].averageTime = Double(Double(weekAvgTimesData[i].totalTime) / currentWeekday)
            }
        }
        else {
            for i in 0..<weekAvgTimesData.count {
                weekAvgTimesData[i].averageTime = Double(Double(weekAvgTimesData[i].totalTime) / 7.0)
            }
        }
    }
    
    func fetchWeekFocusTrend(date: Date) {
        weekFocusTrend = emptyWeekTrendData
        var weekBeforeLastFocusedTime = 0
        var lastWeekFocusedTime = 0
        var thisWeekFocusedTime = 0
        
        // get weekday string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        let weekdayString = dateFormatter.string(from: date)
        
        let calendar = Calendar.current
        // get week start date and weekday
        let comps = calendar.dateComponents([.weekday], from: date)
        let weekDayInt = Int(comps.weekday ?? 0)
        let week = calendar.dateInterval(of: .weekOfMonth, for: date)
        
        guard let sunday = week?.start else {
            return
        }
        // get last week and week before last
        let lastWeekSunday = calendar.date(byAdding: .day, value: -7, to: sunday)
        let weekBeforeLastSunday = calendar.date(byAdding: .day, value: -14, to: sunday)
        
        // get week before last week times
        fetchWeekData(date: weekBeforeLastSunday ?? Date())
        for i in 0...weekDayInt {
            if i < weekTimeDistributionData.count {
                weekBeforeLastFocusedTime = weekBeforeLastFocusedTime + weekTimeDistributionData[i].minutesFocused
            }
        }
        let weekBeforeLastTotalFocusedTime = getTotalMinutesWeek()
        let weekBeforeLastSaturday = calendar.date(byAdding: .day, value: 6, to: weekBeforeLastSunday ?? Date())
        dateFormatter.dateFormat = "dd MMM"
        let weekBeforeLastSunString = dateFormatter.string(from: weekBeforeLastSunday ?? Date())
        let weekBeforeLastSatString = dateFormatter.string(from: weekBeforeLastSaturday ?? Date())
        weekFocusTrend[2].title = ("\(weekBeforeLastSunString) - \(weekBeforeLastSatString)")

        // get last week times
        fetchWeekData(date: lastWeekSunday ?? Date())
        for i in 0...weekDayInt {
            if i < weekTimeDistributionData.count {
                lastWeekFocusedTime = lastWeekFocusedTime + weekTimeDistributionData[i].minutesFocused
            }
        }
        let lastWeekTotalFocusedTime = getTotalMinutesWeek()
        
        // get this week times
        fetchWeekData(date: date)
        thisWeekFocusedTime = getTotalMinutesWeek()
        let totalThisWeekFocusedTime = getTotalMinutesWeek()
        
        weekFocusTrend[0].minsUpToNow = thisWeekFocusedTime
        weekFocusTrend[0].totalMins = totalThisWeekFocusedTime
        weekFocusTrend[1].minsUpToNow = lastWeekFocusedTime
        weekFocusTrend[1].totalMins = lastWeekTotalFocusedTime
        weekFocusTrend[2].minsUpToNow = weekBeforeLastFocusedTime
        weekFocusTrend[2].totalMins = weekBeforeLastTotalFocusedTime
        weekFocusTrend[0].weekday = weekdayString
        weekFocusTrend[1].weekday = weekdayString
        weekFocusTrend[2].weekday = weekdayString
    }
    
    func fetchMonthData(date: Date) {
        monthPieChartData = []
        //monthAvgTimesData = emptyAvgTimesData
        monthAvgTimes = emptyAvgTimesDataMonth
        monthTimeDistributionData = []
        let calendar = Calendar.current
        let startOfMonth = getStartOfMonth(date: date)
        let month = getCurrentMonth(date: startOfMonth)
        var currentDay = startOfMonth
        
        let components = calendar.dateComponents([.day], from: getEndOfMonth(date: startOfMonth))
        let numberOfDays = Int(components.day!)
        
        var i = 0
        var n = 7
        var day = 1
        while getCurrentMonth(date: currentDay) == month {
            currentDay = calendar.date(byAdding: .day, value: i, to: startOfMonth)!
            let currentWeekDay = calendar.dateComponents([.weekday], from: currentDay)
            var totalFocusedMinutes = 0
            getTimes(forDay: currentDay)
            if (day < numberOfDays + 1) {
                for item in dayTimeDistributionData {
                    totalFocusedMinutes = totalFocusedMinutes + item.minutesFocused
                    //monthAvgTimesData[item.hourOrDay].totalTime = monthAvgTimesData[item.hourOrDay].totalTime + item.minutesFocused
                }
                print("current day: \(currentDay)")
                print("current week day: \(currentWeekDay)")
                monthAvgTimes[(currentWeekDay.weekday ?? 0) - 1].totalTime = monthAvgTimes[(currentWeekDay.weekday ?? 0) - 1].totalTime + totalFocusedMinutes
                monthAvgTimes[(currentWeekDay.weekday ?? 0) - 1].division += 1
                
                if (n == 7) {
                    let caption = "\(month ?? 0)/\(day)"
                    monthTimeDistributionData.append(TimeDistributionEntries(minutesFocused: totalFocusedMinutes, hourOrDay: day, caption: caption))
                    n = 0
                }
                else {
                    monthTimeDistributionData.append(TimeDistributionEntries(minutesFocused: totalFocusedMinutes, hourOrDay: day, caption: ""))
                }
                // FOR PIE CHART DATA:
                for entity in filteredByDayTimes {
                    let startTime = entity.startTime ?? Date()
                    let endTime = entity.endTime ?? Date()
                    let minsFocused = calculateFocusedMinutes(startTime: startTime, endTime: endTime)
                    let index = monthPieChartData.firstIndex(where: {$0.topicEntity == entity.topic})
                    if index != nil {
                        monthPieChartData[index ?? 0].totalMinsFocused = monthPieChartData[index ?? 0].totalMinsFocused + CGFloat(minsFocused)
                    }
                    else if let topicEntity = entity.topic {
                        monthPieChartData.append(PieChartEntries(topicEntity: topicEntity, color: TopicColors().convertStringToColor(color: topicEntity.color ?? ""), totalMinsFocused: CGFloat(minsFocused), percent: 0, topicName: topicEntity.topic ?? ""))
                    }
                    else {
                        monthPieChartData.append(PieChartEntries(topicEntity: nil, color: UIColor(Color.theme.defaultTopicColor), totalMinsFocused: CGFloat(minsFocused), percent: 0, topicName: "Untagged")) // Adding blank topic
                    }
                }
            }
            i += 1
            n += 1
            day += 1
        }
        // FOR AVG GRAPH PLOT
//        for i in 0..<monthAvgTimesData.count {
//            monthAvgTimesData[i].averageTime = Double(Double(monthAvgTimesData[i].totalTime) / 7.0)
//        }
        
        for i in 0..<monthAvgTimes.count {
            monthAvgTimes[i].averageTime = Double(Double(monthAvgTimes[i].totalTime) / Double(monthAvgTimes[i].division))
        }
        
        // Find total minutes (FOR PIE CHART)
        var totalMinsFocusedThisMonth = CGFloat(0)
        for item in monthPieChartData {
            totalMinsFocusedThisMonth = totalMinsFocusedThisMonth + item.totalMinsFocused
        }
        // Calculate percentages (FOR PIE CHART)
        for i in 0..<monthPieChartData.count {
            let value = monthPieChartData[i].totalMinsFocused / totalMinsFocusedThisMonth
            let rounded = round(value * 100) / 100.0
            monthPieChartData[i].percent = rounded * 100
        }
    }
    
    func fetchMonthFocusTrend(date: Date) {
        monthFocusTrend = emptyMonthTrendData
        var monthBeforeLastFocusedTime = 0
        var lastMonthFocusedTime = 0
        var thisMonthFocusedTime = 0
        
        // month string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        let calendar = Calendar.current
        // get current day number
        
        // get month info
        let startOfMonth = getStartOfMonth(date: date)
        
        // get current day
        let comps = calendar.dateComponents([.day], from: date)
        let dayInt = Int(comps.day ?? 0)
        
        // get last month and month before last
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)
        let monthBeforeLastMonth = calendar.date(byAdding: .month, value: -2, to: startOfMonth)
        
        // get month before last month times
        fetchMonthData(date: monthBeforeLastMonth ?? Date())
        monthFocusTrend[2].title = dateFormatter.string(from: monthBeforeLastMonth ?? Date())
        for i in 0...dayInt {
            if i < monthTimeDistributionData.count {
                monthBeforeLastFocusedTime = monthBeforeLastFocusedTime + monthTimeDistributionData[i].minutesFocused
                monthFocusTrend[2].monthday = dayInt
            }
            else {
                monthFocusTrend[2].monthday = monthTimeDistributionData.count
            }
        }
        let monthBeforeLastTotalFocusedTime = getTotalMinutesMonth()

        // get last month
        fetchMonthData(date: lastMonth ?? Date())
        monthFocusTrend[1].title = dateFormatter.string(from: lastMonth ?? Date())
        for i in 0...dayInt {
            if i < monthTimeDistributionData.count {
                lastMonthFocusedTime = lastMonthFocusedTime + monthTimeDistributionData[i].minutesFocused
                monthFocusTrend[1].monthday = dayInt
            }
            else {
                monthFocusTrend[1].monthday = monthTimeDistributionData.count
            }
        }
        let lastMonthTotalFocusedTime = getTotalMinutesMonth()
        
        // get this month times
        fetchMonthData(date: date)
        thisMonthFocusedTime = getTotalMinutesMonth()
        let totalThisMonthFocusedTime = getTotalMinutesMonth()
        
        monthFocusTrend[0].minsUpToNow = thisMonthFocusedTime
        monthFocusTrend[0].totalMins = totalThisMonthFocusedTime
        monthFocusTrend[1].minsUpToNow = lastMonthFocusedTime
        monthFocusTrend[1].totalMins = lastMonthTotalFocusedTime
        monthFocusTrend[2].minsUpToNow = monthBeforeLastFocusedTime
        monthFocusTrend[2].totalMins = monthBeforeLastTotalFocusedTime
        monthFocusTrend[0].monthday = dayInt

    }
    
    // MARK: Calculating total focused minutes
    func getTotalMinutesDay() -> Int {
        let sum = dayTimeDistributionData.map({$0.minutesFocused}).reduce(0, +)
        return sum
    }
    
    func getTotalMinutesWeek() -> Int {
        let sum = weekTimeDistributionData.map({$0.minutesFocused}).reduce(0, +)
        return sum
    }
    
    func getTotalMinutesMonth() -> Int {
        let sum = monthTimeDistributionData.map({$0.minutesFocused}).reduce(0, +)
        return sum
    }
    
    func getTopSubject(data: [PieChartEntries]) -> (String, UIColor) {
        let maxTopicName = data.max { first, scnd in
            return scnd.totalMinsFocused > first.totalMinsFocused
        }?.topicName ?? "Untagged"
        
        let maxTopicColor = data.max { first, scnd in
            return scnd.totalMinsFocused > first.totalMinsFocused
        }?.color ?? .gray

        return (maxTopicName, maxTopicColor)
    }
    
    func getTopics() {
        let request = NSFetchRequest<TopicEntity>(entityName: "TopicEntity")
        
        do {
            topics = try container.viewContext.fetch(request)
            print("Data fetched successfully.")
        } catch let error {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    func getTopic(name: String) {
        let request = NSFetchRequest<TopicEntity>(entityName: "TopicEntity")
        
        let filter = NSPredicate(format: "topic == %@", name)
        request.predicate = filter
        
        do {
            topicSearchedByName = try container.viewContext.fetch(request)
            print("Data fetched successfully.")
        } catch let error {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    func getNumberOfSessionsDay(date: Date) -> Int {
        let request = NSFetchRequest<TimeEntity>(entityName: "TimeEntity")
        
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)
        
        let sort = NSSortDescriptor(keyPath: \TimeEntity.startTime, ascending: true)
        request.sortDescriptors = [sort]
        
        let filter = NSPredicate(format: "startTime >= %@ AND startTime < %@", start as NSDate, end! as NSDate)
        request.predicate = filter
        
        do {
            let filtered = try container.viewContext.fetch(request)
            return filtered.count
        } catch let error {
            print("Error fetching. \(error.localizedDescription)")
            return 0
        }
    }
    
    func getNumberOfSessionsWeek(date: Date) -> Int {
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: date)
        var totalSessions = 0
        
        guard let firstDayOfWeek = week?.start else {
            return 0
        }
        
        (0...6).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstDayOfWeek) {
                totalSessions = totalSessions + getNumberOfSessionsDay(date: weekday)
            }
        }
        return totalSessions
    }
    
    func getNumberOfSessionsMonth(date: Date) -> Int {
        let calendar = Calendar.current
        let startOfMonth = getStartOfMonth(date: date)
        let month = getCurrentMonth(date: startOfMonth)
        var currentDay = startOfMonth
        var totalSessions = 0
        
        let components = calendar.dateComponents([.day], from: getEndOfMonth(date: startOfMonth))
        let numberOfDays = Int(components.day!)
        
        var i = 0
        var day = 1
        while getCurrentMonth(date: currentDay) == month {
            currentDay = calendar.date(byAdding: .day, value: i, to: startOfMonth)!
            if (day < numberOfDays + 1) {
                totalSessions = totalSessions + getNumberOfSessionsDay(date: currentDay)
            }
        i += 1
        day += 1
        }
        return totalSessions
    }
    
    func addTimeData(startTime: Date, endTime: Date, topicEntity: TopicEntity? = nil) {
        let newTimeEntity = TimeEntity(context: container.viewContext)
        newTimeEntity.startTime = startTime
        newTimeEntity.endTime = endTime
        newTimeEntity.topic = topicEntity
        save()
        getTimes()
        getTimes(forDay: Date())
    }
    
    func addTopicData(topic: String, color: String) {
        let newTopicEntity = TopicEntity(context: container.viewContext)
        newTopicEntity.topic = topic
        newTopicEntity.color = color
        save()
        getTopics()
        print("topic data added")
    }
    
    func updateTopicName(entity: TopicEntity, newTopicName: String) {
        entity.topic = newTopicName
        save()
        getTopics()
    }
    
    func updateTopicColor(entity: TopicEntity, newTopicColor: String) {
        entity.color = newTopicColor
        save()
        getTopics()
    }
    
    func updateStartTime(entity: TimeEntity? = nil, newStartTime: Date) {
        if entity != nil {
            entity!.startTime = newStartTime
            save()
            getTimes()
            getTimes(forDay: Date())
        }
    }
    
    func updateEndTime(entity: TimeEntity? = nil, newEndTime: Date) {
        if entity != nil {
            entity!.endTime = newEndTime
            save()
            getTimes()
            getTimes(forDay: Date())
        }
    }
    
    func updateTimeEntityTopic(entity: TimeEntity? = nil, topicEntity: TopicEntity? = nil) {
        if entity != nil && topicEntity != nil {
            entity!.topic = topicEntity
            save()
            getTimes()
            getTimes(forDay: Date())
        }
    }
    
    func updateTimerViewSelectedTopic(entity: TopicEntity? = nil) {
        timerViewSelectedTopicEntity = entity
    }
    
    func updateTopicEditorSelectedTopic(entity: TopicEntity? = nil) {
        topicEditorSelectedTopic = entity
    }
    
    func deleteTimeData(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let timeEntity = times[index]
        container.viewContext.delete(timeEntity)
        save()
        getTimes()
        getTimes(forDay: Date())
    }
    
    func deleteTopicData(indexSet: IndexSet) {
        print(timerViewSelectedTopicEntity?.topic ?? "Empty")
        guard let index = indexSet.first else { return }
        let topicEntity = topics[index]
        if topicEntity == timerViewSelectedTopicEntity {
            timerViewSelectedTopicEntity = nil
        }
        container.viewContext.delete(topicEntity)
        save()
        getTopics()
    }
    
    func deleteTopicData2(topicEntity: TopicEntity) {
        if topicEntity == timerViewSelectedTopicEntity {
            timerViewSelectedTopicEntity = nil
        }
        container.viewContext.delete(topicEntity)
        save()
        getTopics()
    }
    
    func deleteTimeData2(timeEntity: TimeEntity?) {
        if timeEntity != nil {
            container.viewContext.delete(timeEntity!)
            save()
            getTimes()
            getTimes(forDay: Date())
        }
    }
}

extension Date {
    var date: Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.day], from: self))!
    }
    
    var prettyDay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        dateFormatter.locale = Calendar.current.locale!
        return dateFormatter.string(from: self)
    }
    
    var prettyMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Calendar.current.locale!
        return dateFormatter.string(from: self)
    }
}

extension TimeEntity {
    
    @objc
    var dateWithoutTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self.startTime ?? Date())
    }
}

struct CoreDataBootcamp: View {
    
    @StateObject var coreDataViewModel = CoreDataViewModel.instance
    
    var body: some View {
        
        NavigationView {
            VStack(spacing: 5) {
                Button {
                    print("----Topic----")

                } label: {
                    Text("Find Topic Entity From String")
                }

                List {
                    ForEach(coreDataViewModel.groupedByDateTimes, id: \.self) { timeSection in
                        Section(header: Text("\(timeSection[0].startTime?.prettyMonth ?? Date().prettyDay)")) {
                            ForEach(timeSection) { timeEntity in
                                Text("\(timeEntity.startTime ?? Date())")
                            }
                        }
                    }
                }
                .frame(maxHeight: 100)
                // MARK: ADD A TOPIC
                
                addTopic()
                
                // MARK: ADD A TIME
                addTime()
                
                // TOPICS
                Text("Topics")
                    .bold()
                List {
                    ForEach(coreDataViewModel.topics) { entity in
                        Text("\(entity.topic ?? ""), Color: \(entity.color ?? "")")
                            .font(.system(size: 10, design: .rounded))
                    }
                    .onDelete(perform: coreDataViewModel.deleteTopicData)
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: 100)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                
                // TIMES
                Text("Times")
                    .bold()
                List {
                    ForEach(coreDataViewModel.sortedTimes) { entity in
                        Text("Start time: \(entity.startTime ?? Date()), End time: \(entity.endTime ?? Date()), Topic: \(entity.topic?.topic ?? "No Topic"), Color: \(entity.topic?.color ?? "")")
                            .font(.system(size: 10, design: .rounded))
                    }
                    .onDelete(perform: coreDataViewModel.deleteTimeData)
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: 100)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Core Data")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CoreDataBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataBootcamp()
    }
}

struct addTopic: View {
    @State var textFieldText: String = ""
    @State var textFieldText2: String = ""
    @ObservedObject var dataManager = CoreDataViewModel.instance
    
    var body: some View {
        Text("Add a topic:")
            .bold()
            .font(.caption)
        
        TextField("Topic here...", text: $textFieldText)
            .padding(.leading)
            .frame(height: 30)
            .background(Color(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)))
            .cornerRadius(10)
            .padding(.horizontal)
        
        TextField("Topic color here...", text: $textFieldText2)
            .padding(.leading)
            .frame(height: 30)
            .background(Color(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)))
            .cornerRadius(10)
            .padding(.horizontal)
        
        Button(action: {
            guard !textFieldText.isEmpty else { return }
            guard !textFieldText2.isEmpty else { return }
            dataManager.addTopicData(topic: textFieldText, color: textFieldText2)
            textFieldText = ""
            textFieldText2 = ""
        }, label: {
            Text("Add Topic Data")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 30)
                .frame(maxWidth: .infinity)
                .background(.gray)
                .cornerRadius(10)
        })
        
        .padding(.horizontal)
    }
}

struct addTime: View {
    @State var textFieldText: String = ""
    @State var textFieldText2: String = ""
    @StateObject var dataManager = CoreDataViewModel.instance
    @State var selectedDate: Date = Date()
    @State var selectedDate2: Date = Date()
    @State var selectedTopic: TopicEntity? = nil
    
    var body: some View {
        Text("Add a time data:")
            .bold()
            .font(.caption)
        DatePicker("Start time", selection: $selectedDate)
        DatePicker("End time", selection: $selectedDate2)
        
        List {
            ForEach(dataManager.topics) { topic in
                Text(topic.topic ?? "No name")
                    .onTapGesture{
                        selectedTopic = topic
                    }
            }
        }
        
        Button(action: {
            dataManager.addTimeData(startTime: selectedDate, endTime: selectedDate2, topicEntity: selectedTopic)
        }, label: {
            Text("Add Time Data")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 30)
                .frame(maxWidth: .infinity)
                .background(.gray)
                .cornerRadius(10)
        })
        .padding(.horizontal)
    }
}


//    func fetchDayPieChartData(filteredTimes: [TimeEntity]) {
//        dayPieChartData = []
//        for entity in filteredTimes {
//            let startTime = entity.startTime ?? Date()
//            let endTime = entity.endTime ?? Date()
//            let minsFocused = calculateFocusedMinutes(startTime: startTime, endTime: endTime)
//            let index = dayPieChartData.firstIndex(where: {$0.topicEntity == entity.topic})
//            if index != nil {
//                //print(dayPieChartData[index ?? 0].totalMinsFocused)
//                dayPieChartData[index ?? 0].totalMinsFocused = dayPieChartData[index ?? 0].totalMinsFocused + CGFloat(minsFocused)
//                //print(dayPieChartData[index ?? 0].totalMinsFocused)
//            }
//            else if let topicEntity = entity.topic {
//                dayPieChartData.append(PieChartEntries(topicEntity: topicEntity, color: TopicColors().convertStringToColor(color: topicEntity.color ?? ""), totalMinsFocused: CGFloat(minsFocused), percent: 0, topicName: topicEntity.topic ?? ""))
//            }
//        }
//        // Find total minutes
//        var totalMinsFocusedToday = CGFloat(0)
//        for item in dayPieChartData {
//            totalMinsFocusedToday = totalMinsFocusedToday + item.totalMinsFocused
//        }
//        // Calculate percentages
//        for i in 0..<dayPieChartData.count {
//            let value = dayPieChartData[i].totalMinsFocused / totalMinsFocusedToday
//            let rounded = round(value * 100) / 100.0
//            dayPieChartData[i].percent = rounded * 100
//        }
//    }


//    func fetchWeekPieChartData(date: Date) {
//        weekPieChartData = []
//        let calendar = Calendar.current
//        let week = calendar.dateInterval(of: .weekOfMonth, for: date)
//
//        guard let firstDayOfWeek = week?.start else {
//            return
//        }
//
//        (0...6).forEach { day in
//            if let weekday = calendar.date(byAdding: .day, value: day, to: firstDayOfWeek) {
//                getTimes(forDay: weekday)
//                print(weekday)
//                for entity in filteredByDayTimes {
//                    let startTime = entity.startTime ?? Date()
//                    let endTime = entity.endTime ?? Date()
//                    let minsFocused = calculateFocusedMinutes(startTime: startTime, endTime: endTime)
//                    let index = weekPieChartData.firstIndex(where: {$0.topicEntity == entity.topic})
//                    if index != nil {
//                        weekPieChartData[index ?? 0].totalMinsFocused = weekPieChartData[index ?? 0].totalMinsFocused + CGFloat(minsFocused)
//                    }
//                    else if let topicEntity = entity.topic {
//                        weekPieChartData.append(PieChartEntries(topicEntity: topicEntity, color: TopicColors().convertStringToColor(color: topicEntity.color ?? ""), totalMinsFocused: CGFloat(minsFocused), percent: 0, topicName: topicEntity.topic ?? ""))
//                    }
//                }
//            }
//        }
//        // Find total minutes
//        var totalMinsFocusedToday = CGFloat(0)
//        for item in weekPieChartData {
//            totalMinsFocusedToday = totalMinsFocusedToday + item.totalMinsFocused
//        }
//        // Calculate percentages
//        for i in 0..<weekPieChartData.count {
//            let value = weekPieChartData[i].totalMinsFocused / totalMinsFocusedToday
//            let rounded = round(value * 100) / 100.0
//            weekPieChartData[i].percent = rounded * 100
//        }
//    }

//    func fetchMonthPieChartData(date: Date) {
//        monthPieChartData = []
//        let calendar = Calendar.current
//        let startOfMonth = getStartOfMonth(date: date)
//        let month = getCurrentMonth(date: startOfMonth)
//        var currentDay = startOfMonth
//
//        let components = calendar.dateComponents([.day], from: getEndOfMonth(date: startOfMonth))
//        let numberOfDays = Int(components.day!)
//
//        var i = 0
//        var day = 1
//        while getCurrentMonth(date: currentDay) == month {
//            currentDay = calendar.date(byAdding: .day, value: i, to: startOfMonth)!
//            getTimes(forDay: currentDay)
//            if (day < numberOfDays + 1) {
//                for entity in filteredByDayTimes {
//                    let startTime = entity.startTime ?? Date()
//                    let endTime = entity.endTime ?? Date()
//                    let minsFocused = calculateFocusedMinutes(startTime: startTime, endTime: endTime)
//                    let index = monthPieChartData.firstIndex(where: {$0.topicEntity == entity.topic})
//                    if index != nil {
//                        monthPieChartData[index ?? 0].totalMinsFocused = monthPieChartData[index ?? 0].totalMinsFocused + CGFloat(minsFocused)
//                    }
//                    else if let topicEntity = entity.topic {
//                        monthPieChartData.append(PieChartEntries(topicEntity: topicEntity, color: TopicColors().convertStringToColor(color: topicEntity.color ?? ""), totalMinsFocused: CGFloat(minsFocused), percent: 0, topicName: topicEntity.topic ?? ""))
//                    }
//                }
//            }
//            i += 1
//            day += 1
//        }
//    }
