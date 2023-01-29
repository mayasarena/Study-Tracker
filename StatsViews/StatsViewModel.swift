//
//  StatsViewModel.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-13.
//

import Foundation
import SwiftUI

class StatsViewModel: ObservableObject {
    
    // MARK: Getting current week
    // Getting current week as array of dates
    
    static let instance = StatsViewModel()
    @Published var currentWeek: [Date] = []
    @Published var selectedDate: Date = Date()
    @Published var selectedWeekStartDate: Date = Date()
    @Published var selectedWeekEndDate: Date = Date()
    @Published var selectedMonthStartDate: Date = Date()
    @Published var calendarPickerOpened: Bool = false
    @Published var currentExplanation: String = ""
    @Published var showExplanationPopup: Bool = false
    
    init() {
        getCurrentWeek()
        selectedWeekStartDate = getWeekStartAndEndDays(date: Date()).0
        selectedWeekEndDate = getWeekStartAndEndDays(date: Date()).1
        selectedMonthStartDate = getStartOfMonth(date: Date())
    }
    
    func moveDate(_ days: Int) -> Date {
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .day, value: days, to: selectedDate) ?? Date()
        return newDate
    }
    
    func getCurrentWeek() {
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: Date())
        
        guard let firstDayOfWeek = week?.start else {
            return
        }
        
        (0...6).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstDayOfWeek) {
                currentWeek.append(weekday)
            }
        }
    }
    
    // MARK: Week stuff
    
    func getWeekStartAndEndDays(date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: date)
        let firstDayOfWeek = week?.start ?? Date()
        let lastDayOfWeek = calendar.date(byAdding: .day, value: 6, to: firstDayOfWeek) ?? Date()
        
        return (firstDayOfWeek, lastDayOfWeek)
        
    }
    
    func getPreviousWeekStartAndEndDays(date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: date)
        let firstDayOfCurrentWeek = week?.start ?? Date()
        let firstDayOfPreviousWeek = calendar.date(byAdding: .day, value: -7, to: firstDayOfCurrentWeek) ?? Date()
        let lastDayOfPreviousWeek = calendar.date(byAdding: .day, value: -1, to: firstDayOfCurrentWeek) ?? Date()
        
        return (firstDayOfPreviousWeek, lastDayOfPreviousWeek)
        
    }
    
    func getNextWeekStartAndEndDays(date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: date)
        let lastDayOfCurrentWeek = week?.end ?? Date()
        let firstDayOfNextWeek = lastDayOfCurrentWeek
        let lastDayOfNextWeek = calendar.date(byAdding: .day, value: 6, to: firstDayOfNextWeek) ?? Date()
        
        return (firstDayOfNextWeek, lastDayOfNextWeek)
        
    }
    
    func getNextMonthStartDate(date: Date) -> (Date) {
        let calendar = Calendar.current
        let startOfCurrentMonth = getStartOfMonth(date: date)
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfCurrentMonth)!
        
        return startOfNextMonth
        
    }
    
    func getPreviousMonthStartDate(date: Date) -> (Date) {
        let calendar = Calendar.current
        let startOfCurrentMonth = getStartOfMonth(date: date)
        let startOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth)!
        
        return startOfPreviousMonth
        
    }
    
    // MARK: Format date
    func formatDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    // MARK: Getting selected date
    
    func isDaySelected(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(selectedDate, inSameDayAs: date)
    }
    
    // MARK: Getting selected date

    func isWeekSelected(date: Date) -> Bool {
        let weekStartDay = getWeekStartAndEndDays(date: date).0
        let calendar = Calendar.current
        return calendar.isDate(selectedWeekStartDate, inSameDayAs: weekStartDay)
    }
    
    // MARK: Getting selected date
    
    func isMonthSelected(date: Date) -> Bool {
        let monthStart = getStartOfMonth(date: date)
        let calendar = Calendar.current
        return calendar.isDate(selectedMonthStartDate, inSameDayAs: monthStart)
    }
}
