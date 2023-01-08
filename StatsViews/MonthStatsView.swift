//
//  StatsView.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-13.
//

import SwiftUI

struct MonthStatsView: View {
    
    @ObservedObject var statsViewModel = StatsViewModel.instance
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    @Namespace private var animation
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            // Lazy VStack with Pinned Header
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                
                Section {
                
                    VStack {
                        OverviewView(totalFocusedTime: coreDataViewModel.getTotalMinutesMonth(), totalFocusSessions: coreDataViewModel.getNumberOfSessionsMonth(date: statsViewModel.selectedMonthStartDate), mostFocusedTopicName: coreDataViewModel.getTopSubject(data: coreDataViewModel.monthPieChartData).0, mostFocusedTopicColor: coreDataViewModel.getTopSubject(data: coreDataViewModel.monthPieChartData).1, title: "Monthly")
                            .padding(.horizontal, 30)
                            .padding(.vertical, 20)
                            .padding(.top, 5)
                        
                        if statsViewModel.isMonthSelected(date: Date()) {
                            VStack {
                                Text("Total Study Time Trends")
                                    .font(.boldHeader)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(Color.theme.mainText)
                                    .padding(.bottom, 15)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    VStack(spacing: 3) {
                                        Text("Difference between your study time this month up to now (the \(getMonthDayString(coreDataViewModel.monthFocusTrend[0].monthday))) and your study time in \(prevMonths().0) at the same time:")
                                            .font(.regularSemiBoldFont)
                                            .foregroundColor(Color.theme.mainText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(getFocusTrendTextLastMonth())")
                                            .fontWeight(.bold)
                                            .font(.regularSemiBoldFont)
                                            .foregroundColor(Color.theme.accent)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    VStack(spacing: 3) {
                                        Text("Difference between your study time this month up to now (the \(getMonthDayString(coreDataViewModel.monthFocusTrend[0].monthday))) and your study time in \(prevMonths().1) at the same time:")
                                            .font(.regularSemiBoldFont)
                                            .foregroundColor(Color.theme.mainText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(getFocusTrendTextMonthBeforeLast())")
                                            .fontWeight(.bold)
                                            .font(.regularSemiBoldFont)
                                            .foregroundColor(Color.theme.accent)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.bottom, 15)
                                
                                MonthFocusTrends()
                                    .onAppear {
                                        coreDataViewModel.fetchMonthFocusTrend(date: Date())
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
                            
                            if !coreDataViewModel.monthPieChartData.isEmpty {
                                TagsOverview(topicData: coreDataViewModel.monthPieChartData)
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
                            
                            MonthTimeDistributionBarChart()
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
                                        Text("You are typically most focused on \(getMaxAvgWeek()).")
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
                            
                            MonthAvgTimesBarChart()
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        
                        VStack {
                            Text("Topic Distribution")
                                .font(.boldHeader)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.theme.mainText)
                                .padding(.vertical, 15)
                            
                            VStack {
                                if !coreDataViewModel.monthPieChartData.isEmpty {
                                    PieChart(entries: coreDataViewModel.monthPieChartData)
                                        .padding()
                                        .frame(width: 200, height: 200)
                                    PieChartLegendView(data: coreDataViewModel.monthPieChartData)
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
                    statsViewModel.selectedMonthStartDate = statsViewModel.getPreviousMonthStartDate(date: statsViewModel.selectedMonthStartDate)
                }
                .foregroundColor(Color.theme.mainText)
                .frame(alignment: .leading)
            
            Text(statsViewModel.formatDate(date: statsViewModel.selectedMonthStartDate, format: "MMMM yyyy"))
                .foregroundColor(Color.theme.mainText)
                .font(.mediumSemiBoldFont)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Image(systemName: "chevron.forward")
                .foregroundColor((statsViewModel.formatDate(date: statsViewModel.selectedMonthStartDate, format: "MMMM")) == (statsViewModel.formatDate(date: Date(), format: "MMMM")) ? Color.theme.mainText.opacity(0.4) : Color.theme.mainText)
                .contentShape(Rectangle())
                .onTapGesture {
                    let selectedMonthStartDateFormatted = statsViewModel.formatDate(date: statsViewModel.selectedMonthStartDate, format: "MMMM")
                    let currentDateFormatted = statsViewModel.formatDate(date: Date(), format: "MMMM")
                    // update selected week
                    if selectedMonthStartDateFormatted != currentDateFormatted {
                        // update selected week
                        statsViewModel.selectedMonthStartDate = statsViewModel.getNextMonthStartDate(date: statsViewModel.selectedMonthStartDate)
                    }
                }
                .frame(alignment: .trailing)
        }
    }
    
    func getMaxAvgWeek() -> String {
        return coreDataViewModel.monthAvgTimes.max { $0.averageTime < $1.averageTime }!.weekString
    }
    
    func isAvgDataEmpty() -> Bool {
        let max = coreDataViewModel.monthAvgTimes.max { first, scnd in
            return scnd.averageTime > first.averageTime
        }?.averageTime ?? 0
        
        if max == 0 {
            return true
        }
        return false
    }
    
    func getAvgFocusEmoji() -> (String, String) {
        let weekday = getMaxAvgWeek()
        if weekday == "Mon" {
            return ("Early Beginnings", "🌅")
        }
                    
        else if weekday == "Tue" || weekday == "Wed" || weekday == "Thu" {
            return ("Motivated Mid-Week", "💻")
        }
        
        else {
            return ("Save it for the Weekend", "🎉")
        }
    }
    
    func getFocusTrendTextLastMonth() -> String {
        var timeDiffString = ""
        if (coreDataViewModel.monthFocusTrend[0].minsUpToNow > coreDataViewModel.monthFocusTrend[1].minsUpToNow) {
            let timeDiff = coreDataViewModel.monthFocusTrend[0].minsUpToNow - coreDataViewModel.monthFocusTrend[1].minsUpToNow
            timeDiffString = "\(MinutesToHoursMinutes(mins: timeDiff)) longer this month 📈"
            return timeDiffString
        }
        else if (coreDataViewModel.monthFocusTrend[0].minsUpToNow < coreDataViewModel.monthFocusTrend[1].minsUpToNow) {
            let timeDiff = coreDataViewModel.monthFocusTrend[1].minsUpToNow - coreDataViewModel.monthFocusTrend[0].minsUpToNow
            timeDiffString = "\(MinutesToHoursMinutes(mins: timeDiff)) shorter this month 📉"
            return timeDiffString
        }
        else {
            return "same amount of time studied"
        }
    }
    
    func getFocusTrendTextMonthBeforeLast() -> String {
        var timeDiffString = ""
        if (coreDataViewModel.monthFocusTrend[0].minsUpToNow > coreDataViewModel.monthFocusTrend[2].minsUpToNow) {
            let timeDiff = coreDataViewModel.monthFocusTrend[0].minsUpToNow - coreDataViewModel.monthFocusTrend[2].minsUpToNow
            timeDiffString = "\(MinutesToHoursMinutes(mins: timeDiff)) longer this month 📈"
            return timeDiffString
        }
        else if (coreDataViewModel.monthFocusTrend[0].minsUpToNow < coreDataViewModel.monthFocusTrend[2].minsUpToNow) {
            let timeDiff = coreDataViewModel.monthFocusTrend[2].minsUpToNow - coreDataViewModel.monthFocusTrend[0].minsUpToNow
            timeDiffString = "\(MinutesToHoursMinutes(mins: timeDiff)) shorter this month 📉"
            return timeDiffString
        }
        else {
            return "same amount of time studied"
        }
    }
    
    func getMonthDayString(_ day: Int) -> String {
        if day == 1 || day == 21 || day == 31 {
            return "\(day)st"
        }
        else if day == 2 || day == 22 {
            return "\(day)nd"
        }
        else if day == 3 || day == 23 {
            return "\(day)rd"
        }
        else {
            return "\(day)th"
        }
    }
    
    func prevMonths() -> (String, String) {
        let calendar = Calendar.current
        let startOfCurrentMonth = getStartOfMonth(date: Date())
        let startOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth) ?? Date()
        let startOfPrevPrevMonth = calendar.date(byAdding: .month, value: -1, to: startOfPreviousMonth) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let lastMonth = formatter.string(from: startOfPreviousMonth)
        let monthBeforeLastMonth = formatter.string(from: startOfPrevPrevMonth)
        return (lastMonth, monthBeforeLastMonth)
    }
}

struct MonthStatsView_Previews: PreviewProvider {
    static var previews: some View {
        WeekStatsView()
    }
}
