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
