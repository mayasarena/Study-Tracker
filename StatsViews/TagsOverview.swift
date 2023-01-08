//
//  TagsOverview.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-11-22.
//

import SwiftUI

struct TagsOverview: View {
    var topicData: [PieChartEntries]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                let graphWidth = geometry.size.width * 0.80
                
                ForEach(topicData.sorted{$0.totalMinsFocused > $1.totalMinsFocused}) { item in
                    VStack(alignment: .center, spacing: 4) {
                        HStack() {
                            Text("\(item.topicName)")
                                .font(.mediumSemiBoldFont)
                                .foregroundColor(Color.theme.mainText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack {
                            let barWidth = getBarWidth(graphWidth: graphWidth, data: Int(item.totalMinsFocused))
                            
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(item.color))
                                .frame(width: barWidth, height: 12, alignment: .leading)

                            Text("\(MinutesToHoursMinutes(mins: Int(item.totalMinsFocused)))")
                                .font(.regularSemiBoldFont)
                                .foregroundColor(Color.theme.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(height: 40)
                    .padding(.bottom, 10)
                }
            }
        }
        .frame(height: topicData.count > 0 ? CGFloat(topicData.count) * 50 : 30)
    }
    
    func getBarWidth(graphWidth: Double, data: Int) -> Double {
        let width = Double(data) / getMaxTotalTime() * graphWidth
        return width.isNaN ? 0.0 : width
    }
    
    func getMaxTotalTime() -> Double {
        let max = topicData.max { first, scnd in
            return scnd.totalMinsFocused > first.totalMinsFocused
        }?.totalMinsFocused ?? 0

        return Double(max)
    }
}

//struct TagsOverview_Previews: PreviewProvider {
//    static var previews: some View {
//        TagsOverview()
//    }
//}
