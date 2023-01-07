//
//  FocusTrends.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-11-14.
//

import SwiftUI

struct WeekFocusTrends: View {
    
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                
                VStack (spacing: 15){
                    let graphWidth = geometry.size.width * 1
                    
                    // Today data
                    let thisWeekBarWidth = getBarWidth(graphWidth: graphWidth, data: Int(coreDataViewModel.weekFocusTrend[0].minsUpToNow))
                    
                    VStack(spacing: 5) {
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(coreDataViewModel.weekFocusTrend[0].minsUpToNow) study mins")
                                .font(.mediumBoldFont)
                                .foregroundColor(Color.theme.mainText)

                            Text("this week up to \(coreDataViewModel.weekFocusTrend[0].weekday)")
                                .font(.smallSemiBoldFont)
                                .foregroundColor(Color.theme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.theme.accent)
                            .frame(width: thisWeekBarWidth, height: 12, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Yesterday data
                    let lastWeekBarWidth = getBarWidth(graphWidth: graphWidth, data: Int(coreDataViewModel.weekFocusTrend[1].minsUpToNow))
                    
                    VStack(spacing: 5) {
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(coreDataViewModel.weekFocusTrend[1].minsUpToNow) study mins")
                                .font(.mediumBoldFont)
                                .foregroundColor(Color.theme.mainText)

                            Text("last week up to \(coreDataViewModel.weekFocusTrend[1].weekday)")
                                .font(.smallSemiBoldFont)
                                .foregroundColor(Color.theme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.theme.secondary)
                            .frame(width: lastWeekBarWidth, height: 12, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Day before yesterday data
                    let weekBeforeLastBarWidth = getBarWidth(graphWidth: graphWidth, data: Int(coreDataViewModel.weekFocusTrend[2].minsUpToNow))
                    
                    VStack(spacing: 5) {
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(coreDataViewModel.weekFocusTrend[2].minsUpToNow) study mins")
                                .font(.mediumBoldFont)
                                .foregroundColor(Color.theme.mainText)

                            Text("week of \(getWeekBeforeLast()) up to \(coreDataViewModel.weekFocusTrend[2].weekday)")
                                .font(.smallSemiBoldFont)
                                .foregroundColor(Color.theme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.theme.tertiary)
                            .frame(width: weekBeforeLastBarWidth, height: 12, alignment: .leading)
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
        let max = coreDataViewModel.weekFocusTrend.max { first, scnd in
            return scnd.minsUpToNow > first.minsUpToNow
        }?.minsUpToNow ?? 0

        return Double(max)
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

struct WeekFocusTrends_Previews: PreviewProvider {
    static var previews: some View {
        WeekFocusTrends()
    }
}

struct WeekFocusTrendsEntries: Identifiable {
    var id = UUID()
    var week: Int
    var minsUpToNow: Int
    var totalMins: Int
    var title: String
    var weekday: String
}

var emptyWeekTrendData: [WeekFocusTrendsEntries] =
[
    WeekFocusTrendsEntries(week: 0, minsUpToNow: 0, totalMins: 0, title: "This week", weekday: ""),
    WeekFocusTrendsEntries(week: 1, minsUpToNow: 0, totalMins: 0, title: "Last week", weekday: ""),
    WeekFocusTrendsEntries(week: 2, minsUpToNow: 0, totalMins: 0, title: "Week of ", weekday: ""),
]
