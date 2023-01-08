//
//  StatsView.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-13.
//

import SwiftUI

struct DayStatsView: View {
    
    @StateObject var statsViewModel = StatsViewModel.instance
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    @Namespace private var animation
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {

            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                
                Section {
                
                    VStack {
                        
                        OverviewView(totalFocusedTime: coreDataViewModel.getTotalMinutesDay(), totalFocusSessions: coreDataViewModel.getNumberOfSessionsDay(date: statsViewModel.selectedDate), mostFocusedTopicName: coreDataViewModel.getTopSubject(data: coreDataViewModel.dayPieChartData).0, mostFocusedTopicColor: coreDataViewModel.getTopSubject(data: coreDataViewModel.dayPieChartData).1, title: "Daily")
                            .padding(.horizontal, 30)
                            .padding(.vertical, 20)
                            .padding(.top, 5)
                        
                        
                        if statsViewModel.isDaySelected(date: Date()) {
                            VStack {
                                Text("Total Study Time Trends")
                                    .font(.boldHeader)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(Color.theme.mainText)
                                    .padding(.bottom, 15)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    VStack(spacing: 3) {
                                        Text("Difference between your study time today up to now (\(coreDataViewModel.dayFocusTrend[0].time)) and your study time yesterday at the same time:")
                                            .font(.regularSemiBoldFont)
                                            .foregroundColor(Color.theme.mainText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(getFocusTrendTextYesterday())")
                                            .fontWeight(.bold)
                                            .font(.regularSemiBoldFont)
                                            .foregroundColor(Color.theme.accent)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    VStack(spacing: 3) {
                                        Text("Difference between your study time today up to now (\(coreDataViewModel.dayFocusTrend[0].time)) and your study time the day before yesterday at the same time:")
                                            .font(.regularSemiBoldFont)
                                            .foregroundColor(Color.theme.mainText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(getFocusTrendTextDayBeforeYesterday())")
                                            .fontWeight(.bold)
                                            .font(.regularSemiBoldFont)
                                            .foregroundColor(Color.theme.accent)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.bottom, 15)
                                
                                    DayFocusTrends()
                                        .onAppear {
                                            coreDataViewModel.fetchDayFocusTrend(date: Date())
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
                            
                            if !coreDataViewModel.dayPieChartData.isEmpty {
                                TagsOverview(topicData: coreDataViewModel.dayPieChartData)
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
                            
                            DayTimeDistributionBarChart()
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
                                if !coreDataViewModel.dayPieChartData.isEmpty {
                                    PieChart(entries: coreDataViewModel.dayPieChartData)
                                        .padding()
                                        .frame(width: 200, height: 200)
                                    PieChartLegendView(data: coreDataViewModel.dayPieChartData)
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
                    // update selected date
                    statsViewModel.selectedDate = statsViewModel.moveDate(-1)
                }
                .foregroundColor(Color.theme.mainText)
                .frame(alignment: .leading)
            
            Text("\(statsViewModel.formatDate(date: statsViewModel.selectedDate, format: "MMMM dd"))")
                .font(.mediumSemiBoldFont)
                .foregroundColor(Color.theme.mainText)
            .frame(maxWidth: .infinity, alignment: .center)
            
            Image(systemName: "chevron.forward")
                .foregroundColor((statsViewModel.formatDate(date: statsViewModel.selectedDate, format: "MMMM dd")) == (statsViewModel.formatDate(date: Date(), format: "MMMM dd")) ? Color.theme.mainText.opacity(0.4) : Color.theme.mainText)
                .contentShape(Rectangle())
                .onTapGesture {
                    let selectedDateFormatted = statsViewModel.formatDate(date: statsViewModel.selectedDate, format: "MMMM dd")
                    let currentDateFormatted = statsViewModel.formatDate(date: Date(), format: "MMMM dd")
                    if selectedDateFormatted != currentDateFormatted {
                        // update selected date only if date is not today (moving forward)
                        statsViewModel.selectedDate = statsViewModel.moveDate(1)
                    }
                }
                .frame(alignment: .trailing)
        }
    }
    
    func getFocusTrendTextYesterday() -> String {
        var timeDiffString = ""
        
        if (coreDataViewModel.dayFocusTrend[0].minsUpToNow > coreDataViewModel.dayFocusTrend[1].minsUpToNow) {
            let timeDiff = coreDataViewModel.dayFocusTrend[0].minsUpToNow - coreDataViewModel.dayFocusTrend[1].minsUpToNow
            timeDiffString = " \(MinutesToHoursMinutes(mins: timeDiff)) longer today 📈"
            return timeDiffString
        }
        
        else if (coreDataViewModel.dayFocusTrend[0].minsUpToNow < coreDataViewModel.dayFocusTrend[1].minsUpToNow) {
            let timeDiff = coreDataViewModel.dayFocusTrend[1].minsUpToNow - coreDataViewModel.dayFocusTrend[0].minsUpToNow
            timeDiffString = "\(MinutesToHoursMinutes(mins: timeDiff)) shorter today 📉"
            return timeDiffString
        }
        
        else {
            return "same amount of time studied"
        }
    }
    
    func getFocusTrendTextDayBeforeYesterday() -> String {
        var timeDiffString = ""
        if (coreDataViewModel.dayFocusTrend[0].minsUpToNow > coreDataViewModel.dayFocusTrend[2].minsUpToNow) {
            let timeDiff = coreDataViewModel.dayFocusTrend[0].minsUpToNow - coreDataViewModel.dayFocusTrend[2].minsUpToNow
            timeDiffString = "\(MinutesToHoursMinutes(mins: timeDiff)) longer today 📈"
            return timeDiffString
        }
        else if (coreDataViewModel.dayFocusTrend[0].minsUpToNow < coreDataViewModel.dayFocusTrend[2].minsUpToNow) {
            let timeDiff = coreDataViewModel.dayFocusTrend[2].minsUpToNow - coreDataViewModel.dayFocusTrend[0].minsUpToNow
            timeDiffString = "\(MinutesToHoursMinutes(mins: timeDiff)) shorter today 📉"
            return timeDiffString
        }
        else {
            return "same amount of time studied"
        }
    }

}

struct DayStatsView_Previews: PreviewProvider {
    static var previews: some View {
        DayStatsView()
    }
}
