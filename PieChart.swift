//
//  PieChart.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-10-16.
//

import Charts
import SwiftUI

struct PieChart: UIViewRepresentable {
    
    var entries: [PieChartEntries]
    let pieChart = PieChartView()
    
    func makeUIView(context: Context) -> PieChartView {
        pieChart.delegate = context.coordinator
        return pieChart
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        let dataSet = PieChartDataSet(entriesForPieChart(entries))
        dataSet.drawValuesEnabled = false
        dataSet.sliceSpace = 2
        dataSet.colors = colorsForPieChart(entries)
        let pieChartData = PieChartData(dataSet: dataSet)
        uiView.data = pieChartData
        configureChart(uiView)
        formatCenter(uiView)
        formatDescription(uiView.chartDescription)
        formatLegend(uiView.legend)
        formatDataSet(dataSet)
        uiView.notifyDataSetChanged()
    }
    
    class Coordinator: NSObject, ChartViewDelegate {
        var parent: PieChart
        init(parent: PieChart) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func configureChart(_ pieChart: PieChartView) {
        pieChart.rotationEnabled = false
        //pieChart.animate(xAxisDuration: 0.5, easingOption: .easeInOutCirc)
        pieChart.drawEntryLabelsEnabled = false
        pieChart.highlightPerTapEnabled = false
        pieChart.usePercentValuesEnabled = true

        
    }
    
    func formatCenter(_ pieChart: PieChartView) {
        pieChart.holeRadiusPercent = 0.5
        pieChart.holeColor = UIColor(Color.theme.BG)
        pieChart.transparentCircleRadiusPercent = 0
    }
    
    func formatDescription(_ description: Description) {
        
    }
    
    func formatLegend(_ legend: Legend) {
        legend.enabled = false
    }
    
    func formatDataSet(_ dataSet: ChartDataSet) {
       // dataSet.drawValuesEnabled = true
    }
}

func PieChartLegendView(data: [PieChartEntries]) -> some View {
    HStack (spacing: 40){
        VStack (alignment: .leading, spacing: 10) {
            ForEach(data) { entry in
                HStack (spacing: 10) {
                    if entry.totalMinsFocused != 0 {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(Color(entry.color))
                        Text(entry.topicName)
                            .font(.regularSemiBoldFont)
                            .foregroundColor(Color.theme.mainText)
                    }
                }
            }
        }
        .frame(height: 15)
        .frame(maxWidth: .infinity)
        VStack (alignment: .leading, spacing: 10) {
            ForEach(data) { entry in
                if entry.totalMinsFocused != 0{
                    Text("\(Int(entry.percent))%")
                        .font(.regularSemiBoldFont)
                        .foregroundColor(Color.theme.mainText)
                }
            }
        }
        VStack (alignment: .leading, spacing: 10) {
            ForEach(data) { entry in
                if entry.totalMinsFocused != 0{
                    Text("\(Int(entry.totalMinsFocused))m")
                        .font(.regularSemiBoldFont)
                        .foregroundColor(Color.theme.mainText)
                }
            }
        }
        .frame(height: 15)
        .frame(maxWidth: .infinity)
    }
    .padding(.horizontal)
}

struct PieChartEntries: Identifiable {
    let id = UUID()
    let topicEntity: TopicEntity?
    let color: UIColor
    var totalMinsFocused: CGFloat
    var percent: CGFloat
    let topicName: String
}

func entriesForPieChart(_ entries: [PieChartEntries]) -> [PieChartDataEntry] {
    return entries.map { PieChartDataEntry(value: $0.totalMinsFocused, label: $0.topicName)}
}

func colorsForPieChart(_ entries: [PieChartEntries]) -> [UIColor] {
    return entries.map {($0.color)}
}
