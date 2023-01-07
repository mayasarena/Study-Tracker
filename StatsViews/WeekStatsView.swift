//
//  StatsView.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-13.
//

import SwiftUI

struct WeekStatsView: View {
    
    @StateObject var statsViewModel = StatsViewModel.instance
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    @Namespace private var animation
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            // Lazy VStack with Pinned Header
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                
                Section {
                
                    VStack {
                        
                        OverviewView(totalFocusedTime: coreDataViewModel.getTotalMinutesWeek(), totalFocusSessions: coreDataViewModel.getNumberOfSessionsWeek(date: statsViewModel.selectedWeekStartDate), mostFocusedTopicName: coreDataViewModel.getTopSubject(data: coreDataViewModel.weekPieChartData).0, mostFocusedTopicColor: coreDataViewModel.getTopSubject(data: coreDataViewModel.weekPieChartData).1, title: "Weekly")
                            .padding(.horizontal, 30)
                            .padding(.vertical, 20)
                            .padding(.top, 5)
                        
                        
                        if (statsViewModel.isWeekSelected(date: Date())) {
                            VStack {
                                Text("Total Study Time Trends")
                                    .font(.boldHeader)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(Color.theme.mainText)
                                    .padding(.bottom, 15)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    VStack(spacing: 3) {
                                        Text("Difference between your study time this week up to now (\(coreDataViewModel.weekFocusTrend[0].weekday)) and your study time last week at the same time:")
                                            .font(.regularFont)
                                            .foregroundColor(Color.theme.mainText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(getFocusTrendTextLastWeek())")
                                            .font(.regularBoldFont)
                                            .foregroundColor(Color.theme.accent)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    VStack(spacing: 3) {
                                        Text("Difference between your study time this week up to now (\(coreDataViewModel.weekFocusTrend[0].weekday)) and your study time the week of \(getWeekBeforeLast()) at the same time:")
                                            .font(.regularFont)
                                            .foregroundColor(Color.theme.mainText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(getFocusTrendTextWeekBeforeLast())")
                                            .font(.regularBoldFont)
                                            .foregroundColor(Color.theme.accent)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.bottom, 15)
                                
                                    WeekFocusTrends()
                                        .onAppear {
                                            coreDataViewModel.fetchWeekFocusTrend(date: Date())
                                        }
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                        }
                        
                        VStack() {
                            Text("Tag Overview")
                                .font(.boldHeader)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.theme.mainText)
                                .padding(.vertical, 15)
                            
                            if !coreDataViewModel.weekPieChartData.isEmpty {
                                TagsOverview(topicData: coreDataViewModel.weekPieChartData)
                            }
                            else {
                                Text("No data")
                                    .font(.mediumSemiBoldFont)
                                    .foregroundColor(Color.theme.secondaryText)
                                    .padding(.vertical)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        
                        VStack() {
                            Text("Time Distribution")
                                .font(.boldHeader)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.theme.mainText)
                                .padding(.vertical, 15)
                            
                            WeekTimeDistributionBarChart()
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        
                        VStack() {
                            Text("Average Focus")
                                .font(.boldHeader)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.theme.mainText)
                                .padding(.vertical, 15)
                            
                            if !isAvgDataEmpty() {
                                HStack(spacing: 10){
                                    ZStack {
                                        Circle()
                                            .stroke(lineWidth: 1)
                                            .foregroundColor(Color.theme.mainText)
                                            .background(Circle().fill(Color.theme.BG).shadow(color: Color.theme.accent.opacity(0.5), radius: 2, x: 2, y: 2))
                                            .frame(width: 40, height: 40)
                                        
                                        Text("\(getAvgFocusEmoji().1)")
                                            .padding(10)
                                            .foregroundColor(Color.theme.mainText)
                                            .frame(alignment: .trailing)
                                            .onTapGesture {
                                                withAnimation {
                                                    statsViewModel.calendarPickerOpened.toggle()
                                                }
                                            }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("\(getAvgFocusEmoji().0)")
                                            .font(.mediumSemiBoldFont)
                                            .foregroundColor(Color.theme.mainText)
                                        Text("You are typically most focused at around \(getMaxAvgHour()).")
                                            .font(.regularFont)
                                            .foregroundColor(Color.theme.secondaryText)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .strokeBorder(Color.theme.secondaryText.opacity(0.15), lineWidth: 1.5)
                                )
                            }
                            
                            WeekAvgTimesBarChart()
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        
                        VStack {
                            Text("Tag Distribution")
                                .font(.boldHeader)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.theme.mainText)
                                .padding(.vertical, 15)

                            VStack {
                                if !coreDataViewModel.weekPieChartData.isEmpty {
                                    PieChart(entries: coreDataViewModel.weekPieChartData)
                                        .padding()
                                        .frame(width: 200, height: 200)
                                    PieChartLegendView(data: coreDataViewModel.weekPieChartData)
                                }
                                else {
                                    Text("No data")
                                        .font(.mediumSemiBoldFont)
                                        .foregroundColor(Color.theme.secondaryText)
                                        .padding(.vertical)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                    }
                } header: {
                    HeaderView()
                        .padding()
                        .background(Color.theme.BG)
                }
            }
        }
        .background(Color.theme.BG)
    }
    
    // MARK: Header
    func HeaderView() -> some View {
        
        HStack {
            Image(systemName: "chevron.backward")
                .contentShape(Rectangle())
                .onTapGesture {
                    // update selected week
                    statsViewModel.selectedWeekStartDate = statsViewModel.getPreviousWeekStartAndEndDays(date: statsViewModel.selectedWeekStartDate).0
                    statsViewModel.selectedWeekEndDate = statsViewModel.getPreviousWeekStartAndEndDays(date: statsViewModel.selectedWeekEndDate).1
                }
                .foregroundColor(Color.theme.mainText)
                .frame(alignment: .leading)
            
            Text("\(statsViewModel.formatDate(date: statsViewModel.selectedWeekStartDate, format: "MMM dd")) - \(statsViewModel.formatDate(date: statsViewModel.selectedWeekEndDate, format: "MMM dd"))")
                .font(.mediumSemiBoldFont)
                .foregroundColor(Color.theme.mainText)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Image(systemName: "chevron.forward")
                .foregroundColor((statsViewModel.formatDate(date: statsViewModel.selectedWeekEndDate, format: "MMMM dd")) == (statsViewModel.formatDate(date: statsViewModel.getWeekStartAndEndDays(date: Date()).1, format: "MMMM dd")) ? Color.theme.mainText.opacity(0.4) : Color.theme.mainText)
                .contentShape(Rectangle())
                .onTapGesture {
                    let selectedWeekEndDateFormatted = statsViewModel.formatDate(date: statsViewModel.selectedWeekEndDate, format: "MMMM dd")
                    let currentDateFormatted = statsViewModel.formatDate(date: statsViewModel.getWeekStartAndEndDays(date: Date()).1, format: "MMMM dd")
                    // update selected week
                    if selectedWeekEndDateFormatted != currentDateFormatted {
                        statsViewModel.selectedWeekStartDate = statsViewModel.getNextWeekStartAndEndDays(date: statsViewModel.selectedWeekStartDate).0
                        statsViewModel.selectedWeekEndDate = statsViewModel.getNextWeekStartAndEndDays(date: statsViewModel.selectedWeekEndDate).1
                    }
                }
                .frame(alignment: .trailing)
        }
    }

    func getMaxAvgHour() -> String {
        return coreDataViewModel.weekAvgTimesData.max { $0.averageTime < $1.averageTime }!.stringHour
    }
    
    func isAvgDataEmpty() -> Bool {
        let max = coreDataViewModel.weekAvgTimesData.max { first, scnd in
            return scnd.averageTime > first.averageTime
        }?.averageTime ?? 0
        
        if max == 0 {
            return true
        }
        return false
    }
    
    func getAvgFocusEmoji() -> (String, String) {
        let hour = getMaxAvgHour()
        if hour == "06:00" || hour == "07:00" || hour == "08:00" || hour == "09:00" || hour == "10:00" || hour == "11:00" {
            return ("Early Bird", "🪱")
        }
        else if hour == "12:00" || hour == "13:00" || hour == "14:00" || hour == "15:00" || hour == "16:00" || hour == "17:00" {
            return ("Afternoon Person", "☀️")
        }
        
        else{
            return ("Night Owl", "🦉")
        }
    }
    
    func getFocusTrendTextLastWeek() -> String {
        var timeDiffString = ""
        if (coreDataViewModel.weekFocusTrend[0].minsUpToNow > coreDataViewModel.weekFocusTrend[1].minsUpToNow) {
            let timeDiff = coreDataViewModel.weekFocusTrend[0].minsUpToNow - coreDataViewModel.weekFocusTrend[1].minsUpToNow
            timeDiffString = "\(MinutesToHoursMinutes(mins: timeDiff)) longer this week 📈"
            return timeDiffString
        }
        else if (coreDataViewModel.weekFocusTrend[0].minsUpToNow < coreDataViewModel.weekFocusTrend[1].minsUpToNow) {
            let timeDiff = coreDataViewModel.weekFocusTrend[1].minsUpToNow - coreDataViewModel.weekFocusTrend[0].minsUpToNow
            timeDiffString = "\(MinutesToHoursMinutes(mins: timeDiff)) shorter this week 📉"
            return timeDiffString
        }
        else {
            return "same amount of time studied"
        }
    }
    
    func getFocusTrendTextWeekBeforeLast() -> String {
        var timeDiffString = ""
        if (coreDataViewModel.weekFocusTrend[0].minsUpToNow > coreDataViewModel.weekFocusTrend[2].minsUpToNow) {
            let timeDiff = coreDataViewModel.weekFocusTrend[0].minsUpToNow - coreDataViewModel.weekFocusTrend[2].minsUpToNow
            timeDiffString = "\(MinutesToHoursMinutes(mins: timeDiff)) longer this week 📈"
            return timeDiffString
        }
        else if (coreDataViewModel.weekFocusTrend[0].minsUpToNow < coreDataViewModel.weekFocusTrend[2].minsUpToNow) {
            let timeDiff = coreDataViewModel.weekFocusTrend[2].minsUpToNow - coreDataViewModel.weekFocusTrend[0].minsUpToNow
            timeDiffString = "\(MinutesToHoursMinutes(mins: timeDiff)) shorter this week 📉"
            return timeDiffString
        }
        else {
            return "same amount of time studied"
        }
    }
    
    func getWeekBeforeLast() -> String {
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: Date())
        let firstDayOfWeek = week?.start ?? Date()
        let firstDayOfWeekBeforeLast = calendar.date(byAdding: .day, value: -14, to: firstDayOfWeek) ?? Date()
        let lastDayOfWeekBeforeLast = calendar.date(byAdding: .day, value: 6, to: firstDayOfWeekBeforeLast) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        let firstDay = formatter.string(from: firstDayOfWeekBeforeLast)
        let lastDay = formatter.string(from: lastDayOfWeekBeforeLast)
        return "\(firstDay) - \(lastDay)"
    }
}

struct WeekStatsView_Previews: PreviewProvider {
    static var previews: some View {
        WeekStatsView()
    }
}
