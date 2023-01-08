//
//  WeekAvgTimesBarChart.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-10-17.
//

import SwiftUI

struct MonthAvgTimesBarChart: View {
    
    @ObservedObject var statsViewModel = StatsViewModel.instance
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    @GestureState var isDragging: Bool = false
    @State var currentDataID: String = ""
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
                                .frame(height: 20)
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .offset(y: -24)
                    }
                }
            }

            VStack {
                HStack(spacing: 1) {
                    ForEach(coreDataViewModel.monthAvgTimes) { data in
                        VStack(spacing: 6) {
                            VStack(spacing: 5) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color.theme.lightBG)
                                        .frame(height: getBarHeight(point: getMax(), size: geometry.size))
                                        .frame(width: 20)
                                        .frame(maxHeight: .infinity, alignment: .bottom)
                                    
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(isDragging ? ((currentDataID == data.weekString && data.averageTime > 0) ? Color.theme.accent : Color.theme.accent.opacity(0.65)) : Color.theme.accent.opacity(0.65))
                                        .frame(width: 20)
                                        .frame(height: getBarHeight(point: CGFloat(data.averageTime), size: geometry.size))
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                }
                            }
                            .overlay(
                                VStack {
                                    if data.averageTime > 0 {
                                        Text("\(Int(data.averageTime))m")
                                            .font(.smallBoldFont)
                                            .padding(.horizontal, 7)
                                            .padding(.vertical, 3)
                                            .background(Color.theme.accent)
                                            .cornerRadius(10)
                                            .shadow(color: Color.theme.accent.opacity(0.5), radius: 2, x: 2, y: 2)
                                            .foregroundColor(Color.theme.BG)
                                            .frame(width: 50, alignment: .center)
                                            .offset(y: -26)
                                    }
                                }
                                .opacity(isDragging ? (currentDataID == data.weekString ? 1 : 0) : 0)
                                ,
                                alignment: .top
                            )
                            
                            Text(data.weekString)
                                .foregroundColor(Color.theme.secondaryText)
                                .font(.graphAxisFont)
                        }
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
                        let eachBlock = draggingSpace / CGFloat(coreDataViewModel.monthAvgTimes.count)
                        let temp = Int(offset/eachBlock)
                        let index = max(min(temp, coreDataViewModel.monthAvgTimes.count - 1), 0)
                        currentDataID = coreDataViewModel.monthAvgTimes[index].weekString
                    })
                    .onEnded({ value in
                        withAnimation {
                            offset = .zero
                            currentDataID = ""
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
    
    func getMax() -> CGFloat {
        let max = coreDataViewModel.monthAvgTimes.max { first, scnd in
            return scnd.averageTime > first.averageTime
        }?.averageTime ?? 0
        
        if max == 0 {
            return 30
        }

        var value = Double(max)
        value = value / 100
        var result = ceil(value * 10) / 10.0
        result = result * 100
        return CGFloat(result)
    }

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

    func getBarHeight(point: CGFloat, size: CGSize) -> CGFloat {
        let max = getMax()
        // 25 text height
        // 5 spacing ...
        let height = (point/max) * (size.height - 37) + 5
        return height
    }
    
    func dataIsEmpty() -> Bool {
        let max = coreDataViewModel.monthAvgTimes.max { first, scnd in
            return scnd.averageTime > first.averageTime
        }?.averageTime ?? 0
        
        if max == 0 {
            return true
        }
        
        return false
    }
}

struct MonthAvgTimesBarChart_Previews: PreviewProvider {
    static var previews: some View {
        MonthAvgTimesBarChart()
    }
}
