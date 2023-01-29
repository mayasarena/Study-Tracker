//
//  StatsView.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-10-17.
//

import SwiftUI

struct StatsView: View {
    
    @State var currentTab: String = "Daily"
    @Namespace var animation
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    @ObservedObject var statsViewModel = StatsViewModel.instance
    var tabs: [String] = ["Daily", "Weekly", "Monthly"]
    @State var localSelection: String = "Daily"
    
    @State var selectedDate: Date = Date()
    
    let startDate = Calendar.current.date(from: DateComponents(year: 2010)) ?? Date()
    let endDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 1)
                            .foregroundColor(Color.theme.accent)
                            .background(Circle().fill(Color.theme.BG).shadow(color: Color.theme.accent.opacity(0.5), radius: 2, x: 2, y: 2))
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "calendar")
                            .padding(10)
                            .foregroundColor(Color.theme.accent)
                            .frame(alignment: .trailing)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .onTapGesture {
                                withAnimation {
                                    statsViewModel.calendarPickerOpened.toggle()
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                HStack {
                    ForEach(tabs, id: \.self) { tab in
                        Text("\(tab)")
                            .font(.regularSemiBoldFont)
                            .padding(.vertical, 7)
                            .frame(width: 70)
                            .background(
                                ZStack {
                                    if localSelection == tab {
                                        Color.theme.accent
                                            .cornerRadius(10)
                                            .matchedGeometryEffect(id: "TAB", in: animation)
                                    }
                                }
                            )
                            .padding(.vertical, 3)
                            .padding(.horizontal, 3)
                            .foregroundColor(localSelection == tab ? Color.theme.BG : Color.theme.mainText)
                            .onTapGesture {
                                currentTab = tab
                            }
                    }
                    // Animate picker locally
                    .onChange(of: currentTab, perform: { value in
                        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.6)) {
                            localSelection = value
                        }
                    })
                    .onChange(of: currentTab) { tab in
                        if tab == "Daily" {
                            coreDataViewModel.getTimes(forDay: Date())
                            statsViewModel.selectedDate = Date()
                        }
                        if tab == "Weekly" {
                            coreDataViewModel.fetchWeekData(date: Date())
                            statsViewModel.selectedWeekStartDate = statsViewModel.getWeekStartAndEndDays(date: Date()).0
                            statsViewModel.selectedWeekEndDate = statsViewModel.getWeekStartAndEndDays(date: Date()).1
                        }
                        if tab == "Monthly" {
                            coreDataViewModel.fetchMonthData(date: Date())
                            statsViewModel.selectedMonthStartDate = getStartOfMonth(date: Date())
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(Color.theme.lightBG)
                )
            }
            .background(Color.theme.BG)
            
            if currentTab == "Daily" {
                DayStatsView()
                //coreDataViewModel.getTimes(forDay: Date())
            }
            if currentTab == "Weekly" {
                //coreDataViewModel.fetchWeekData(date: Date())
                WeekStatsView()
            }
            if currentTab == "Monthly" {
                //coreDataViewModel.fetchMonthData(date: Date())
                MonthStatsView()
            }
        }
            .padding(.bottom, 50)
        
        .popup(horizontalPadding: 40, show: $statsViewModel.calendarPickerOpened) {
            datePickerPopup
                .transition(.scale)
                .padding(.vertical, 10)
                .background(Color.theme.BG)
                .cornerRadius(25)
                .padding(.horizontal, 10)
        }
        
        .popup(horizontalPadding: 40, show: $statsViewModel.showExplanationPopup) {
            explanationPopup
                .transition(.scale)
                .padding(.vertical, 10)
                .background(Color.theme.BG)
                .cornerRadius(25)
                .padding(.horizontal, 10)
        }
    }
    
    var explanationPopup: some View {
        VStack (spacing: 30) {
            if statsViewModel.currentExplanation == "trendsDay" {
                VStack(spacing: 15) {
                    Text("Total Study Time Trends (Daily) shows you how much you have studied up to the current time compared to yesterday at the same time and the day before yesterday at the same time.")
                        .font(.regularFont)
                        .foregroundColor(Color.theme.mainText)
                    
                    Text("Using this feedback, you can see if you're trending up or down with the amount of time that you devote to studying.")
                        .font(.smallFont)
                        .foregroundColor(Color.theme.secondaryText)
                }
            }
            else if statsViewModel.currentExplanation == "trendsWeek" {
                VStack (spacing: 15){
                    Text("Total Study Time Trends (Weekly) shows you how much you have studied so far this week compared to last week on the same day and the week before last week on the same day.")
                        .font(.regularFont)
                        .foregroundColor(Color.theme.mainText)
                    
                    Text("Using this feedback, you can see if you're trending up or down with the amount of time that you devote to studying.")
                        .font(.smallFont)
                        .foregroundColor(Color.theme.secondaryText)
                }
            }
            else if statsViewModel.currentExplanation == "trendsMonth" {
                VStack (spacing: 15){
                    Text("Total Study Time Trends (Monthly) shows you how much you have studied so far this month compared to last month up to the same day and the month before last month up to the same day.")
                        .font(.regularFont)
                        .foregroundColor(Color.theme.mainText)
                    
                    Text("Using this feedback, you can see if you're trending up or down with the amount of time that you devote to studying.")
                        .font(.smallFont)
                        .foregroundColor(Color.theme.secondaryText)
                }
            }
            else if statsViewModel.currentExplanation == "tagDay" {
                Text("Tag Overview (Daily) shows you the total amount of time spent studying with each tag today.")
                    .font(.regularFont)
                    .foregroundColor(Color.theme.mainText)
            }
            else if statsViewModel.currentExplanation == "tagWeek" {
                Text("Tag Overview (Weekly) shows you the total amount of time spent studying with each tag this week.")
                    .font(.regularFont)
                    .foregroundColor(Color.theme.mainText)
            }
            else if statsViewModel.currentExplanation == "tagMonth" {
                Text("Tag Overview (Monthly) shows you the total amount of time spent studying with each tag this month.")
                    .font(.regularFont)
                    .foregroundColor(Color.theme.mainText)
            }
            else if statsViewModel.currentExplanation == "timeDistDay" {
                VStack(spacing: 15) {
                    Text("Time Distribution (Daily) shows you how much time per hour you have spent studying today.")
                        .font(.regularFont)
                        .foregroundColor(Color.theme.mainText)
                    
                    HStack (spacing: 20) {
                        Text("x axis = hour of day")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                            .frame(width: 120)
                        
                        Text("y axis = minutes spent studying")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                            .frame(width: 120)
                    }
                    
                    Text("Drag your finger across the graph to see the exact times for each hour.")
                        .font(.regularSemiBoldFont)
                        .foregroundColor(Color.theme.mainText)
                }
            }
            else if statsViewModel.currentExplanation == "timeDistWeek" {
                VStack(spacing: 15) {
                    Text("Time Distribution (Weekly) shows you how much time per weekday you have spent studying this week.")
                        .font(.regularFont)
                        .foregroundColor(Color.theme.mainText)
                    
                    HStack (spacing: 20) {
                        Text("x axis = day of week")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                            .frame(width: 120)
                        
                        Text("y axis = minutes spent studying")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                            .frame(width: 120)
                    }
                    
                    Text("Drag your finger across the graph to see the exact times for each weekday.")
                        .font(.regularSemiBoldFont)
                        .foregroundColor(Color.theme.mainText)
                }
            }
            else if statsViewModel.currentExplanation == "timeDistMonth" {
                VStack(spacing: 15) {
                    Text("Time Distribution (Monthly) shows you how much time per day you have spent studying this month.")
                        .font(.regularFont)
                        .foregroundColor(Color.theme.mainText)
                    
                    HStack (spacing: 20) {
                        Text("x axis = day of month")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                            .frame(width: 120)
                        
                        Text("y axis = minutes spent studying")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                            .frame(width: 120)
                    }
                    
                    Text("Drag your finger across the graph to see the exact times for each day.")
                        .font(.regularSemiBoldFont)
                        .foregroundColor(Color.theme.mainText)
                }
            }
            else if statsViewModel.currentExplanation == "avgFocusWeek" {
                VStack(spacing: 15) {
                    Text("Average Focus (Weekly) shows you the average amount of time that you have studied per hour this week.")
                        .font(.regularFont)
                        .foregroundColor(Color.theme.mainText)
                    
                    HStack (spacing: 20) {
                        Text("x axis = hour of day")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                            .frame(width: 100)
                        
                        Text("y axis = average minutes spent studying")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                            .frame(width: 150)
                    }
                    
                    VStack(spacing: 5) {
                        Text("Calculation: sum of minutes spent studying during that hour this week / current day of week (where Sunday = 1 and Saturday = 7)")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                        Text("Calculation if week has past: sum of minutes spent studying during that hour for the week / 7")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                    }
                    .padding(.horizontal, 15)
                    
                    Text("Drag your finger across the graph to see the exact times for each hour.")
                        .font(.regularSemiBoldFont)
                        .foregroundColor(Color.theme.mainText)
                }
            }
            else if statsViewModel.currentExplanation == "avgFocusMonth" {
                VStack(spacing: 15) {
                    Text("Average Focus (Monthly) shows you the average amount of time that you have studied per weekday this month.")
                        .font(.regularFont)
                        .foregroundColor(Color.theme.mainText)
                    
                    HStack (spacing: 20) {
                        Text("x axis = weekday")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                            .frame(width: 100)
                        
                        Text("y axis = average minutes spent studying")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                            .frame(width: 150)
                    }
                    
                    VStack(spacing: 5) {
                        Text("Calculation: sum of minutes spent studying during that weekday this month / number of times that weekday occurs in the month (usually either 4 or 5)")
                            .font(.smallSemiBoldFont)
                            .foregroundColor(Color.theme.secondaryText)
                    }
                    .padding(.horizontal, 15)
                    
                    Text("Drag your finger across the graph to see the exact times for each weekday.")
                        .font(.regularSemiBoldFont)
                        .foregroundColor(Color.theme.mainText)
                }
            }
            else if statsViewModel.currentExplanation == "tagDistDay" {
                Text("Tag Distribution (Daily) shows you the percent of time that you have spent on each tag today.")
                    .font(.regularFont)
                    .foregroundColor(Color.theme.mainText)
            }
            else if statsViewModel.currentExplanation == "tagDistWeek" {
                Text("Tag Distribution (Weekly) shows you the percent of time that you have spent on each tag this week.")
                    .font(.regularFont)
                    .foregroundColor(Color.theme.mainText)
            }
            else if statsViewModel.currentExplanation == "tagDistMonth" {
                Text("Tag Distribution (Monthly) shows you the percent of time that you have spent on each tag this month.")
                    .font(.regularFont)
                    .foregroundColor(Color.theme.mainText)
            }
            else {
                Text("Error. How did you get here?")
                    .font(.regularFont)
                    .foregroundColor(Color.theme.mainText)
            }
            Button("Okay") {
                statsViewModel.showExplanationPopup.toggle()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .padding()
    }
    
    var datePickerPopup: some View {
        VStack(spacing: 10) {
            DatePicker("Select a date", selection: $selectedDate, in: startDate...endDate, displayedComponents: .date)
                .accentColor(Color.theme.accent)
                .datePickerStyle(GraphicalDatePickerStyle())
            
            HStack(spacing: 30) {
                Button {
                    withAnimation {
                        statsViewModel.calendarPickerOpened.toggle()
                    }
                } label: {
                        Text("Cancel")
                            .tracking(2)
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button {
                    if currentTab == "Daily" {
                        statsViewModel.selectedDate = selectedDate
                    }
                    if currentTab == "Weekly" {
                        let weekStartDate = statsViewModel.getWeekStartAndEndDays(date: selectedDate).0
                        let weekEndDate = statsViewModel.getWeekStartAndEndDays(date: selectedDate).1
                        statsViewModel.selectedWeekStartDate = weekStartDate
                        statsViewModel.selectedWeekEndDate = weekEndDate
                    }
                    if currentTab == "Monthly" {
                        statsViewModel.selectedMonthStartDate = getStartOfMonth(date: selectedDate)
                    }
                    withAnimation {
                        statsViewModel.calendarPickerOpened.toggle()
                    }
                } label: {
                    Text("Confirm")
                        .tracking(2)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding()
        .padding(.horizontal, 10)
    }
}
    
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
