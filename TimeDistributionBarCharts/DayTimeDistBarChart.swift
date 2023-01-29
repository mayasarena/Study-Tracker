//
//  BarChart.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-10-17.
//

import Foundation
import SwiftUI

struct DayTimeDistributionBarChart: View {
    
    @ObservedObject var statsViewModel = StatsViewModel.instance
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    @GestureState var isDragging: Bool = false
    @State var currentDataID: Int = 100
    @State var offset: CGFloat = 0
    
    var body: some View {
        DayBarChartView()
    }
    
    func DayBarChartView() -> some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    ForEach(getGraphLines(), id: \.self) { line in
                        HStack(spacing: 10) {
                            Text("\(Int(line))m")
                                .font(.graphAxisFont)
                                .foregroundColor(Color.theme.secondaryText)
                                .frame(width: 40, height: 20, alignment: .trailing)
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .offset(x: -10, y: -20)
                    }
                }
            }

            VStack {
                HStack(spacing: 1) {
                    ForEach(coreDataViewModel.dayTimeDistributionData) { data in
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.theme.lightBG)
                                    .frame(height: getBarHeight(point: CGFloat(60), size: geometry.size))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(isDragging ? ((currentDataID == data.hourOrDay && data.minutesFocused > 0) ? Color.theme.accent : Color.theme.accent.opacity(0.65)) : Color.theme.accent.opacity(0.65))
                                    .frame(height: getBarHeight(point: CGFloat(data.minutesFocused), size: geometry.size))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            }
                        }
                        .overlay(
                            VStack {
                                if data.minutesFocused > 0 {
                                    Text("\(MinutesToHoursMinutes(mins: data.minutesFocused))")
                                        .font(.smallBoldFont)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(Color.theme.accent)
                                        .cornerRadius(10)
                                        .shadow(color: Color.theme.accent.opacity(0.5), radius: 2, x: 2, y: 2)
                                        .foregroundColor(Color.theme.BG)
                                        .frame(width: 150, alignment: .center)
                                        .offset(y: -20)
                                }
                            }
                            .opacity(isDragging ? (currentDataID == data.hourOrDay ? 1 : 0) : 0)
                            ,
                            alignment: .top
                        )
                        .overlay(
                            Text("\(data.caption)")
                                .font(.graphAxisFont)
                                .foregroundColor(Color.theme.secondaryText)
                                .frame(width: 50, alignment: .center)
                                .offset(y: 20)
                            ,
                            alignment: .bottom
                        )
                    }
                }
                .overlay(
                    VStack {
                        if getMax() == 0 {
                            Text("No data")
                                .font(.mediumSemiBoldFont)
                                .foregroundColor(Color.theme.secondaryText)
                                .padding(.vertical)
                        }
                    }
                )
                .padding(.bottom, 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .animation(.easeOut, value: isDragging)
            .gesture(
                DragGesture()
                    .updating($isDragging, body: { _, out, _ in
                        out = true
                    })
                    .onChanged({ value in
                        offset = isDragging ? value.location.x : 0
                        let draggingSpace = UIScreen.main.bounds.width - 110
                        let eachBlock = draggingSpace / CGFloat(coreDataViewModel.dayTimeDistributionData.count)
                        let temp = Int(offset/eachBlock)
                        let index = max(min(temp, coreDataViewModel.dayTimeDistributionData.count - 1), 0)
                        currentDataID = coreDataViewModel.dayTimeDistributionData[index].hourOrDay
                    })
                    .onEnded({ value in
                        withAnimation {
                            offset = .zero
                            currentDataID = 100
                        }
                    })
            )
            .padding(.leading, 40)
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .onChange(of: statsViewModel.selectedDate) { newValue in
                coreDataViewModel.getTimes(forDay: statsViewModel.selectedDate)
            }
        }
        .frame(height: 190)
    }
    
    func getBarHeight(point: CGFloat, size: CGSize) -> CGFloat {
        let max = CGFloat(60)
        // 25 text height
        // 5 spacing ...
        let height = (point/max) * (size.height - 37) + 7
        return height
    }

    // Getting Sample Graph Lines based on max val
    func getGraphLines() -> [CGFloat] {
        let max = CGFloat(60)
        var lines: [CGFloat] = []
        lines.append(max)
        for index in 1...4 {
            // dividing max by 4 and iterating as index for graph lines ....
            let progress = max / 4
            lines.append(max - (progress * CGFloat(index)))
        }

        return lines
    }

    // Getting max
    func getMax() -> CGFloat {
        let max = coreDataViewModel.dayTimeDistributionData.max { first, scnd in
            return scnd.minutesFocused > first.minutesFocused
        }?.minutesFocused ?? 0

        return CGFloat(max)
    }
}

struct DayTimeDistBarChart_Previews: PreviewProvider {
    static var previews: some View {
        DayStatsView()
    }
}
