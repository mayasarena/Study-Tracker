//
//  MonthTimeDistributionBarChart.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-10-17.
//

import SwiftUI

struct MonthTimeDistributionBarChart: View {
    
    @ObservedObject var statsViewModel = StatsViewModel.instance
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    @GestureState var isDragging: Bool = false
    @State var currentDataID: Int = 100
    @State var offset: CGFloat = 0
    
    var body: some View {
        MonthBarChartView()
    }
    
    func MonthBarChartView() -> some View {
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
                    ForEach(coreDataViewModel.monthTimeDistributionData) { data in
                        VStack() {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.theme.lightBG)
                                    .frame(height: getBarHeight(point: getMax(), size: geometry.size))
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
                                .foregroundColor(Color.theme.secondaryText)
                                .frame(width: 50, alignment: .center)
                                .font(.graphAxisFont)
                                .offset(y: 20)
                            ,
                            alignment: .bottom)
                    }
                }
                .overlay(
                    VStack {
                        if dataIsEmpty() {
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
                        let eachBlock = draggingSpace / CGFloat(coreDataViewModel.monthTimeDistributionData.count)
                        let temp = Int(offset/eachBlock)
                        let index = max(min(temp, coreDataViewModel.monthTimeDistributionData.count - 1), 0)
                        currentDataID = coreDataViewModel.monthTimeDistributionData[index].hourOrDay
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
            .onChange(of: statsViewModel.selectedMonthStartDate) { newValue in
                coreDataViewModel.fetchMonthData(date: statsViewModel.selectedMonthStartDate)
            }
        }
        .frame(height: 190)
    }
    
    func getBarHeight(point: CGFloat, size: CGSize) -> CGFloat {
        let max = getMax()
        // 25 text height
        // 5 spacing ...
        let height = (point/max) * (size.height - 37) + 7
        return height
    }

    // Getting Sample Graph Lines based on max val
    func getGraphLines() -> [CGFloat] {
        let max = getMax()
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
        let max = coreDataViewModel.monthTimeDistributionData.max { first, scnd in
            return scnd.minutesFocused > first.minutesFocused
        }?.minutesFocused ?? 0
        
        if max == 0 {
            return 100
        }
    
        var value = Double(max)
        value = value / 1000
        var result = ceil(value * 10) / 10.0
        result = result * 1000
        return CGFloat(result)
    }
    
    // 
    func dataIsEmpty() -> Bool {
        let max = coreDataViewModel.monthTimeDistributionData.max { first, scnd in
            return scnd.minutesFocused > first.minutesFocused
        }?.minutesFocused ?? 0
        
        if max == 0 {
            return true
        }
        
        return false
    }
}

struct MonthTimeDistributionBarChart_Previews: PreviewProvider {
    static var previews: some View {
        MonthTimeDistributionBarChart()
    }
}
