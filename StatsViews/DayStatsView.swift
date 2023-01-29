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
                                HStack {
                                    Text("Total Study Time Trends")
                                        .font(.boldHeader)
                                        .foregroundColor(Color.theme.mainText)
                                    Spacer()
                                    Image(systemName: "questionmark.circle")
                                        .font(.mediumFont)
                                        .foregroundColor(Color.theme.secondaryText).opacity(0.6)
                                        .frame(width: 50, height: 30, alignment: .trailing)
                                        .background(Color.theme.BG)
                                        .onTapGesture {
                                            statsViewModel.currentExplanation = "trendsDay"
                                            statsViewModel.showExplanationPopup.toggle()
                                        }
                                }
                                .padding(.bottom, 15)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    VStack(spacing: 3) {
                                        Text("Difference between your study time today up to now (\(coreDataViewModel.dayFocusTrend[0].time)) and your study time yesterday at the same time:")
                                            .font(.regularFont)
                                            .foregroundColor(Color.theme.mainText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(getFocusTrendTextYesterday())")
                                            .font(.regularBoldFont)
                                            .foregroundColor(Color.theme.accent)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    VStack(spacing: 3) {
                                        Text("Difference between your study time today up to now (\(coreDataViewModel.dayFocusTrend[0].time)) and your study time the day before yesterday at the same time:")
                                            .font(.regularFont)
                                            .foregroundColor(Color.theme.mainText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(getFocusTrendTextDayBeforeYesterday())")
                                            .font(.regularBoldFont)
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
                            HStack {
                                Text("Tag Overview")
                                    .font(.boldHeader)
                                    .foregroundColor(Color.theme.mainText)
                                Spacer()
                                Image(systemName: "questionmark.circle")
                                    .font(.mediumFont)
                                    .foregroundColor(Color.theme.secondaryText).opacity(0.6)
                                    .frame(width: 50, height: 30, alignment: .trailing)
                                    .background(Color.theme.BG)
                                    .onTapGesture {
                                        statsViewModel.currentExplanation = "tagDay"
                                        statsViewModel.showExplanationPopup.toggle()
                                    }
                            }
                            .padding(.bottom, 15)
                            
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
                            HStack {
                                Text("Time Distribution")
                                    .font(.boldHeader)
                                    .foregroundColor(Color.theme.mainText)
                                Spacer()
                                Image(systemName: "questionmark.circle")
                                    .font(.mediumFont)
                                    .foregroundColor(Color.theme.secondaryText).opacity(0.6)
                                    .frame(width: 50, height: 30, alignment: .trailing)
                                    .background(Color.theme.BG)
                                    .onTapGesture {
                                        statsViewModel.currentExplanation = "timeDistDay"
                                        statsViewModel.showExplanationPopup.toggle()
                                    }
                            }
                            .padding(.bottom, 15)
                            
                            DayTimeDistributionBarChart()
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                    
                        VStack {
                            HStack {
                                Text("Tag Distribution")
                                    .font(.boldHeader)
                                    .foregroundColor(Color.theme.mainText)
                                Spacer()
                                Image(systemName: "questionmark.circle")
                                    .font(.mediumFont)
                                    .foregroundColor(Color.theme.secondaryText).opacity(0.6)
                                    .frame(width: 50, height: 30, alignment: .trailing)
                                    .background(Color.theme.BG)
                                    .onTapGesture {
                                        statsViewModel.currentExplanation = "tagDistDay"
                                        statsViewModel.showExplanationPopup.toggle()
                                    }
                            }
                            .padding(.bottom, 15)

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
            .onAppear{
                statsViewModel.selectedDate = Date()
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
