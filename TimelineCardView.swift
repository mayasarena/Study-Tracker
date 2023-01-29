//
//  TimelineEntryView.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-03.
//

import SwiftUI

struct TimelineCardView: View {
    
    let startTime: Date
    let endTime: Date
    let topic: String
    let topicColor: String
    let selectedTimeEntity: TimeEntity
    
    @ObservedObject var timelineViewModel = TimelineViewModel.instance
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack() {
                    Image(systemName: "pencil")
                        .frame(width: 50, height: 50, alignment: .topTrailing)
                        .background(Color.theme.BG)
                        .foregroundColor(Color.theme.secondaryText)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.7)){
                                timelineViewModel.updateSelectedTimeEntity(entity: selectedTimeEntity)
                                timelineViewModel.updateSelectedStartTime(entity: selectedTimeEntity)
                                timelineViewModel.updateSelectedEndTime(entity: selectedTimeEntity)
                                timelineViewModel.updateSelectedTopic(entity: selectedTimeEntity.topic)
                                timelineViewModel.showEditEntryPopup.toggle()
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                VStack(spacing: 7) {
                    Text("\(startTime, style: .time) - \(endTime, style: .time)")
                        .font(.smallBoldFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color.theme.secondaryText)
                    
                    Text("Completed a \(MinutesToHoursMinutes(mins: (calculateFocusedMinutes(startTime: startTime, endTime: endTime)))) study session.")
                        .font(.regularFont)
                        .foregroundColor(Color.theme.mainText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 3)
                    
                    Text(topic)
                        .font(.smallBoldFont)
                        .tracking(2)
                        .textCase(.uppercase)
                        .foregroundColor(Color.theme.BG)
                        .padding([.leading, .trailing], 10)
                        .padding([.top, .bottom], 5)
                        .background(Color(TopicColors().convertStringToColor(color: topicColor)))
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .background(Color.theme.BG)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .strokeBorder(Color.theme.secondaryText.opacity(0.15), lineWidth: 1.5)
        )
    }
}

//struct TimelineEntryView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimelineCardView(startTime: Date(), endTime: Date(), topic: "Topic here", topicColor: "Pink")
//            .previewLayout(.fixed(width: 400, height: 150))
//    }
//}
