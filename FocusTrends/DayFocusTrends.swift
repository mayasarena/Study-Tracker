//
//  FocusTrends.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-11-14.
//

import SwiftUI

struct DayFocusTrends: View {
    
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                VStack (spacing: 15){
                    let graphWidth = geometry.size.width * 1
                    
                    // Today data
                    let todayBarWidth = getBarWidth(graphWidth: graphWidth, data: Int(coreDataViewModel.dayFocusTrend[0].minsUpToNow))
                    
                    VStack(spacing: 5) {
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(coreDataViewModel.dayFocusTrend[0].minsUpToNow) study mins")
                                .font(.mediumBoldFont)
                                .foregroundColor(Color.theme.mainText)

                            Text("today at \(coreDataViewModel.dayFocusTrend[0].time)")
                                .font(.smallSemiBoldFont)
                                .foregroundColor(Color.theme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.theme.accent)
                            .frame(width: todayBarWidth, height: 12, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Yesterday data
                    let yesterdayBarWidth = getBarWidth(graphWidth: graphWidth, data: Int(coreDataViewModel.dayFocusTrend[1].minsUpToNow))
                    
                    VStack(spacing: 5) {
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(coreDataViewModel.dayFocusTrend[1].minsUpToNow) study mins")
                                .font(.mediumBoldFont)
                                .foregroundColor(Color.theme.mainText)

                            Text("yesterday at \(coreDataViewModel.dayFocusTrend[1].time)")
                                .font(.smallSemiBoldFont)
                                .foregroundColor(Color.theme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.theme.secondary)
                            .frame(width: yesterdayBarWidth, height: 12, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Day before yesterday data
                    let dayBeforeYesterdayBarWidth = getBarWidth(graphWidth: graphWidth, data: Int(coreDataViewModel.dayFocusTrend[2].minsUpToNow))
                    
                    VStack(spacing: 5) {
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(coreDataViewModel.dayFocusTrend[2].minsUpToNow) study mins")
                                .font(.mediumBoldFont)
                                .foregroundColor(Color.theme.mainText)

                            Text("the day before yesterday at \(coreDataViewModel.dayFocusTrend[2].time)")
                                .font(.smallSemiBoldFont)
                                .foregroundColor(Color.theme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.theme.tertiary)
                            .frame(width: dayBeforeYesterdayBarWidth, height: 12, alignment: .leading)
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
        let max = coreDataViewModel.dayFocusTrend.max { first, scnd in
            return scnd.minsUpToNow > first.minsUpToNow
        }?.minsUpToNow ?? 0

        return Double(max)
    }
}

struct FocusTrends_Previews: PreviewProvider {
    static var previews: some View {
        DayFocusTrends()
    }
}

struct FocusTrendsEntries: Identifiable {
    var id = UUID()
    var day: Int
    var minsUpToNow: Int
    var totalMins: Int
    var title: String
    var time: String
}

var emptyTrendData: [FocusTrendsEntries] =
[
    FocusTrendsEntries(day: 0, minsUpToNow: 0, totalMins: 0, title: "How long you have focused so far today: ", time: ""),
    FocusTrendsEntries(day: 1, minsUpToNow: 0, totalMins: 0, title: "Yesterday:", time: ""),
    FocusTrendsEntries(day: 2, minsUpToNow: 0, totalMins: 0, title: "The day before yesterday:", time: "")
]
