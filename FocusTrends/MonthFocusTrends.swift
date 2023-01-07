//
//  FocusTrends.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-11-14.
//

import SwiftUI

struct MonthFocusTrends: View {
    
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                
                VStack (spacing: 15){
                    let graphWidth = geometry.size.width * 1
                    
                    // Today data
                    let thisMonthBarWidth = getBarWidth(graphWidth: graphWidth, data: Int(coreDataViewModel.monthFocusTrend[0].minsUpToNow))
                    
                    VStack(spacing: 5) {
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(coreDataViewModel.monthFocusTrend[0].minsUpToNow) study mins")
                                .font(.mediumBoldFont)
                                .foregroundColor(Color.theme.mainText)

                            Text("this month up to the \(getMonthDayString(coreDataViewModel.monthFocusTrend[0].monthday))")
                                .font(.smallSemiBoldFont)
                                .foregroundColor(Color.theme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.theme.accent)
                            .frame(width: thisMonthBarWidth, height: 12, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Yesterday data
                    let lastMonthBarWidth = getBarWidth(graphWidth: graphWidth, data: Int(coreDataViewModel.monthFocusTrend[1].minsUpToNow))
                    
                    VStack(spacing: 5) {
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(coreDataViewModel.monthFocusTrend[1].minsUpToNow) study mins")
                                .font(.mediumBoldFont)
                                .foregroundColor(Color.theme.mainText)

                            Text("the month of \(prevMonths().0) up to the \(getMonthDayString(coreDataViewModel.monthFocusTrend[1].monthday))")
                                .font(.smallSemiBoldFont)
                                .foregroundColor(Color.theme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.theme.secondary)
                            .frame(width: lastMonthBarWidth, height: 12, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Day before yesterday data
                    let monthBeforeLastBarWidth = getBarWidth(graphWidth: graphWidth, data: Int(coreDataViewModel.monthFocusTrend[2].minsUpToNow))
                    
                    VStack(spacing: 5) {
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(coreDataViewModel.monthFocusTrend[2].minsUpToNow) study mins")
                                .font(.mediumBoldFont)
                                .foregroundColor(Color.theme.mainText)

                            Text("the month of \(prevMonths().1) up to the \(getMonthDayString(coreDataViewModel.monthFocusTrend[2].monthday))")
                                .font(.smallSemiBoldFont)
                                .foregroundColor(Color.theme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.theme.tertiary)
                            .frame(width: monthBeforeLastBarWidth, height: 12, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .frame(height: 140)
    }
    
    func getBarWidth(graphWidth: Double, data: Int) -> Double {
        var width = Double(data) / getMaxTotalTime() * graphWidth
        
        print(width)
        if width == 0 {
            width = 5.0
        }
        
        return width.isNaN ? 5.0 : width
    }
    
    func getMaxTotalTime() -> Double {
        let max = coreDataViewModel.monthFocusTrend.max { first, scnd in
            return scnd.minsUpToNow > first.minsUpToNow
        }?.minsUpToNow ?? 0

        return Double(max)
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

struct MonthFocusTrendsEntries: Identifiable {
    var id = UUID()
    var month: Int
    var minsUpToNow: Int
    var totalMins: Int
    var title: String
    var monthday: Int
}

var emptyMonthTrendData: [MonthFocusTrendsEntries] =
[
    MonthFocusTrendsEntries(month: 0, minsUpToNow: 0, totalMins: 0, title: "This Month", monthday: 0),
    MonthFocusTrendsEntries(month: 1, minsUpToNow: 0, totalMins: 0, title: "Last Month", monthday: 0),
    MonthFocusTrendsEntries(month: 2, minsUpToNow: 0, totalMins: 0, title: "Month Before Last Month", monthday: 0)
]
