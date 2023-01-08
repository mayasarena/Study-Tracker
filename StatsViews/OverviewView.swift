//
//  OverviewView.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-10-17.
//

import SwiftUI

struct OverviewView: View {
    
    let totalFocusedTime: Int
    let totalFocusSessions: Int
    let mostFocusedTopicName: String
    let mostFocusedTopicColor: UIColor
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    @ObservedObject var statsViewModel = StatsViewModel.instance
    
    let title: String
    
    var body: some View {
        VStack {
            Text("\(title) Overview")
                .font(.boldHeader)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.theme.mainText)
                .padding(.bottom, 15)
            
            HStack {
                VStack(spacing: -5) {
                    Text("\(MinutesToHoursMinutes(mins: totalFocusedTime))")
                        .font(.reallyBigFont)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.theme.mainText)
                    Spacer()
                    Text("Study time")
                        .font(.smallBoldFont)
                        .foregroundColor(Color.theme.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                .frame(height: 45)
                .frame(maxWidth: .infinity)
                
                VStack(spacing: -5) {
                    Text("\(totalFocusSessions)")
                        .font(.reallyBigFont)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.theme.mainText)
                    Spacer()
                    Text("Sessions")
                        .font(.smallBoldFont)
                        .foregroundColor(Color.theme.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                .frame(height: 45)
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 0) {
                    Text("\(mostFocusedTopicName)")
                        .font(.smallBoldFont)
                        .tracking(2)
                        .textCase(.uppercase)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 10)
                        .padding([.top, .bottom], 5)
                        .background(Color(mostFocusedTopicColor))
                        .cornerRadius(20)
                        .foregroundColor(Color.theme.BG)
                        //.offset(y: 3)
                    Spacer()
                    Text("Most Used Tag")
                        .font(.smallBoldFont)
                        .foregroundColor(Color.theme.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                .frame(height: 45)
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 25)
            .padding(.horizontal, 15)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .strokeBorder(Color.theme.secondaryText.opacity(0.15), lineWidth: 1.5)
            )
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(totalFocusedTime: 345, totalFocusSessions: 5, mostFocusedTopicName: "Computer Science", mostFocusedTopicColor: .green, title: "Daily")
    }
}

func MinutesToHoursMinutes(mins: Int) -> String {
    let totalMins = Double(mins)
    var hours = totalMins / 60.0
    let decimal = hours.truncatingRemainder(dividingBy: 1.0)
    hours = hours - decimal
    let minutes = (decimal * 60).rounded()
    if hours == 0 {
        return "\(Int(minutes))m"
    }
    return "\(Int(hours))h \(Int(minutes))m"
}
