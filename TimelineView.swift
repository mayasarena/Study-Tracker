//
//  TimelineView.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-03.
//
import SwiftUI

class TimelineViewModel: ObservableObject {

    static let instance = TimelineViewModel() // Singleton
    
    @Published var showEditEntryPopup: Bool = false
    @Published var showTopicSelectionPopup: Bool = false
    @Published var selectedTimeEntity: TimeEntity? = nil
    @Published var selectedStartTime: Date = Date()
    @Published var selectedEndTime: Date = Date()
    @Published var selectedTopic: TopicEntity? = nil
    
    func updateSelectedTimeEntity(entity: TimeEntity) {
        selectedTimeEntity = entity
    }
    
    func updateSelectedStartTime(entity: TimeEntity) {
        selectedStartTime = entity.startTime ?? Date()
    }
    
    func updateSelectedEndTime(entity: TimeEntity) {
        selectedEndTime = entity.endTime ?? Date()
    }
    
    func updateSelectedTopic(entity: TopicEntity?) {
        selectedTopic = entity ?? nil
    }
    
}

struct TimelineView: View {
    
    @State var showDeleteAlert = false
    @State var showSaveAlert = false
    @State var selectedStartTime: Date = Date()
    @State var selectedEndTime: Date = Date()
    @State private var showTopicSheet = false
    @State private var showAddEntryPopup: Bool = false
    //@State var showTopicSelectionPopup: Bool = false

    //let fakeItems: [fakeItem]
    @ObservedObject var timelineViewModel = TimelineViewModel.instance
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    @ObservedObject var topicEditorViewModel = TopicEditorViewModel.instance

    var body: some View {
        ScrollView {
            if (coreDataViewModel.groupedByDateTimes.isEmpty) {
                Text("No entries yet!")
                    .padding(.top, 100)
                    .foregroundColor(Color.theme.secondaryText)
                    .font(.mediumSemiBoldFont)
            }
            ForEach(coreDataViewModel.groupedByDateTimes.sorted(by: { ($0[0].startTime ?? Date()).compare($1[0].startTime ?? Date()) == .orderedDescending}), id: \.self) { timeSection in
                Section(header:
                            VStack(alignment: .leading) {
                    dateHeader(date: timeSection[0].startTime ?? Date())}){
                        // sort array of timeSections
                        ForEach(sortTimeSection(timeSectionArray: timeSection)) { entity in
                    TimelineCardView(startTime: entity.startTime ?? Date(), endTime: entity.endTime ?? Date(), topic: entity.topic?.topic ?? "Untagged", topicColor: entity.topic?.color ?? "", selectedTimeEntity: entity)
                                .padding(.leading, 30)
                                .padding(.trailing, 30)
                                .padding(.top, 5)
                                .padding(.bottom, 5)
                    }
                }
                .textCase(nil)
                .foregroundColor(Color.theme.accent)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
        .frame(maxWidth: .infinity)
        .background(Color.theme.BG)
        .padding(.bottom, 50)
        
        .popup(horizontalPadding: 40, show: $timelineViewModel.showEditEntryPopup) {
            editEntryPopup
                .transition(.scale)
                .padding(.vertical, 10)
                .background(Color.theme.BG)
                .cornerRadius(25)
                .padding(.horizontal, 30)
        }
        
        .popup(horizontalPadding: 40, show: $timelineViewModel.showTopicSelectionPopup) {
            topicSelectionPopup
                .transition(.scale)
                .background(Color.theme.BG)
                .cornerRadius(25)
                .padding(.horizontal, 50)

        }
    }
    
    var topicSelectionPopup: some View {
        VStack(spacing: 20) {

            Text("Your tags")
                .foregroundColor(Color.theme.mainText)
                .font(.mediumBoldFont)
            ScrollView {
                VStack {
                    ForEach(coreDataViewModel.topics) { topic in
                        VStack {
                            HStack() {
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(Color(TopicColors().convertStringToColor(color: topic.color ?? "")))
                                
                                Text("\(topic.topic ?? "")")
                                    .foregroundColor(Color.theme.mainText)
                                    .font(.regularFont)
                                    .padding(.vertical, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.theme.BG)
                                    .onTapGesture {
                                        timelineViewModel.updateSelectedTopic(entity: topic)
                                    }
                            
                                if timelineViewModel.selectedTopic == topic {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.theme.accent)
                                        .frame(width: 15, height: 15)
                                        .padding(.trailing, 5)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Rectangle()
                                .frame(maxHeight: 1)
                                .foregroundColor(Color.theme.secondaryText.opacity(0.15))
                        }
                    }
                }
            }
            .frame(height: 230)
            
            HStack(spacing: 30) {
                Button {
                    withAnimation{
                        timelineViewModel.showTopicSelectionPopup.toggle()
                    }
                } label: {
                    Text("Close")
                        .tracking(2)
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button {
                    showTopicSheet.toggle()
                } label: {
                    Text("Edit tags")
                        .tracking(2)
                }
                .buttonStyle(PrimaryButtonStyle())
                .sheet(isPresented: $showTopicSheet) {
                    VStack(spacing: 0) {
                        ZStack {
                            
                            HStack {
                                Image(systemName: "xmark")
                                    .font(.mediumBoldFont)
                                    .foregroundColor(Color.theme.mainText)
                                    .frame(width: 50, height: 50)
                                    .onTapGesture {
                                        showTopicSheet.toggle()
                                    }
                            }
                            .padding(.leading, 10)
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.theme.BG)
                            
                            if topicEditorViewModel.editTopicPopupOpened || topicEditorViewModel.addTopicPopupOpened {
                                Color.primary.opacity(0.15).ignoresSafeArea()
                            }
                        }
                        .frame(height: 60, alignment: .center)

                        TopicEditorView()
                    }
                    .interactiveDismissDisabled(topicEditorViewModel.editTopicPopupOpened || topicEditorViewModel.addTopicPopupOpened)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
    }
    
//    var topicSelectionPopup: some View {
//        VStack(spacing: 20) {
//
//            ForEach(coreDataViewModel.topics) { topic in
//                Text("\(topic.topic ?? "")")
//                    .foregroundColor(Color(TopicColors().convertStringToColor(color: topic.color ?? "")))
//                    .onTapGesture {
//                        timelineViewModel.updateSelectedTopic(entity: topic)
//                        timelineViewModel.showTopicSelectionPopup.toggle()
//                    }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//
//            Button {
//                withAnimation{
//                    timelineViewModel.showTopicSelectionPopup.toggle()
//                }
//            } label: {
//                Text("Close")
//            }
//        }
//        .padding(.vertical, 20)
//        .padding(.horizontal, 30)
//    }
    
    var editEntryPopup: some View {
        VStack(spacing: 30) {
            ZStack {
                HStack {
                    Button {
                        //selectedColor = ""
                        withAnimation{
                            timelineViewModel.showEditEntryPopup.toggle()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 15, height: 15, alignment: .leading)
                            .foregroundColor(Color.theme.mainText)
                    }
                    Spacer()
                }
                
                HStack {
                    Text("Edit Entry")
                        .font(.mediumBoldFont)
                }
            }
            
            VStack(spacing: 30) {
                HStack {
                    Text("Start Time")
                        .foregroundColor(Color.theme.mainText)
                        .font(.regularSemiBoldFont)
                    Spacer()
                    DatePicker("", selection: $timelineViewModel.selectedStartTime, in: getStartHourLimit(timeEntity: timelineViewModel.selectedTimeEntity)...timelineViewModel.selectedEndTime, displayedComponents: [.hourAndMinute])
                        .accentColor(Color.theme.accent)
                }
                HStack {
                    Text("End Time")
                        .foregroundColor(Color.theme.mainText)
                        .font(.regularSemiBoldFont)
                    Spacer()
                    DatePicker("", selection: $timelineViewModel.selectedEndTime, in: timelineViewModel.selectedStartTime...getEndHourLimit(timeEntity: timelineViewModel.selectedTimeEntity), displayedComponents: .hourAndMinute)
                        .accentColor(Color.theme.accent)
                }
            }
            
            HStack {
                Text("Tag")
                    .foregroundColor(Color.theme.mainText)
                    .font(.regularSemiBoldFont)
                Spacer()
                Button {
                    withAnimation{
                        timelineViewModel.showTopicSelectionPopup.toggle()
                    }
                } label: {
                    Text("\(timelineViewModel.selectedTopic?.topic ?? "Untagged")")
                        .tracking(2)
                }
                .font(.smallBoldFont)
                .textCase(.uppercase)
                .foregroundColor(Color.theme.BG)
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 5)
                .background(Color(TopicColors().convertStringToColor(color: timelineViewModel.selectedTopic?.color ?? "Other")))
                .cornerRadius(20)

            }
            
            HStack(spacing: 30){
                Button {
                    showDeleteAlert = true
                } label: {
                    Text("Delete")
                        .tracking(2)
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete this entry?"),
                        message: Text("The data will be deleted forever."),
                        primaryButton: .default(Text("Nevermind")),
                        secondaryButton: .destructive(
                            Text("Delete Forever"),
                            action: {
                                timelineViewModel.selectedStartTime = Date()
                                timelineViewModel.selectedEndTime = Date()
                                coreDataViewModel.deleteTimeData2(timeEntity: timelineViewModel.selectedTimeEntity)
                                withAnimation{
                                    timelineViewModel.showEditEntryPopup.toggle()
                                }
                            })

                    )
                }
                
                .buttonStyle(WarningButtonStyle())
                Button {
                    if isDifferenceLargerThan5Min(startTime: timelineViewModel.selectedStartTime, endTime: timelineViewModel.selectedEndTime) {
                        withAnimation{
                            coreDataViewModel.updateStartTime(entity: timelineViewModel.selectedTimeEntity, newStartTime: timelineViewModel.selectedStartTime)
                            coreDataViewModel.updateEndTime(entity: timelineViewModel.selectedTimeEntity, newEndTime: timelineViewModel.selectedEndTime)
                            coreDataViewModel.updateTimeEntityTopic(entity: timelineViewModel.selectedTimeEntity, topicEntity: timelineViewModel.selectedTopic)
                            timelineViewModel.showEditEntryPopup.toggle()
                        }
                    }
                    else {
                        showSaveAlert = true
                    }
                } label: {
                    Text("Save")
                        .tracking(2)
                }
                .alert(isPresented: $showSaveAlert) {
                    Alert(
                        title: Text("Oops! Entries should be at least 5 minutes long."),
                        message: Text("Please edit the start and end times.")
                    )
                }
                
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.top, 30)
            .padding(.bottom, 15)
        }
        .foregroundColor(Color.theme.mainText)
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
    }
    
    func sortTimeSection(timeSectionArray: [TimeEntity]) -> [TimeEntity] {
        return timeSectionArray.sorted(by: {$0.startTime ?? Date() > $1.startTime ?? Date()})
    }
    
    func getEndHourLimit(timeEntity: TimeEntity?) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let today = dateFormatter.string(from: Date())
        let timeEntityDate = dateFormatter.string(from: timeEntity?.endTime ?? Date())
        if timeEntity != nil {
            if let index = coreDataViewModel.sortedTimes.firstIndex(of: timeEntity!) {
                print("index: \(index)")
                if coreDataViewModel.sortedTimes.indices.contains(index + 1) {
                    let nextTimeEntity = coreDataViewModel.sortedTimes[index + 1]
                    print("next time entity: \(nextTimeEntity)")
                    let nextTimeEntityDate = dateFormatter.string(from: nextTimeEntity.startTime ?? Date())
                    print("next time entity date: \(nextTimeEntityDate)")
                    if (timeEntityDate == nextTimeEntityDate) {
                        let endTime = Calendar.current.date(byAdding: .minute, value: 0, to: nextTimeEntity.startTime ?? Date())
                        return endTime ?? Date()
                    }
                }
            }
        }
        print("returning date")
        if today == timeEntityDate {
            return Date()
        }
        return dateFormatter.date(from:timeEntityDate)?.endOfDay() ?? Date()
    }
    
    func getStartHourLimit(timeEntity: TimeEntity?) -> Date {
        print("sorted times: \(coreDataViewModel.sortedTimes)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let timeEntityDate = dateFormatter.string(from: timeEntity?.startTime ?? Date())
        if timeEntity != nil {
            if let index = coreDataViewModel.sortedTimes.firstIndex(of: timeEntity!) {
                if coreDataViewModel.sortedTimes.indices.contains(index - 1) {
                    let prevTimeEntity = coreDataViewModel.sortedTimes[index - 1]
                    let prevTimeEntityDate = dateFormatter.string(from: prevTimeEntity.endTime ?? Date())
                    print("prev time entity date: \(prevTimeEntityDate)")
                    if (timeEntityDate == prevTimeEntityDate) {
                        let startTime = Calendar.current.date(byAdding: .minute, value: 0, to: prevTimeEntity.endTime ?? Date())
                        return startTime ?? Date()
                    }
                }
            }
        }
        return dateFormatter.date(from:timeEntityDate)?.startOfDay() ?? Date()
    }
}

struct dateHeader: View {
    let date: Date
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    
    var body: some View {
        Text(dayText(date: date))
            .foregroundColor(Color.theme.mainText)
            .font(.boldHeader)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 40)
            .padding(.top)
    }
    
    func dayText(date: Date) -> String {
        dateFormatter.dateFormat = "MMMM dd"
        if calendar.isDateInToday(date) {
            return "Today"
        }
        else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }
        else {
            return dateFormatter.string(from: date)
        }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}

func isDifferenceLargerThan5Min(startTime: Date, endTime: Date) -> Bool {
    let calendar = Calendar.current
    let startComponents = calendar.dateComponents([.minute, .hour], from: startTime)
    let endComponents = calendar.dateComponents([.minute, .hour], from: endTime)
    if endComponents.hour != startComponents.hour {
        return true
    }
    else if (((endComponents.minute ?? 0) - (startComponents.minute ?? 0)) >= 5) {
        return true
    }
    return false
}

extension Date {
    func startOfDay() -> Date {
        let calendar = Calendar.current
        

        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)

        components.hour = 0
        components.minute = 0
        components.second = 0

        return calendar.date(from: components) ?? Date()
    }
    
    func endOfDay() -> Date {
        let calendar = Calendar.current
        

        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)

        components.hour = 23
        components.minute = 59
        components.second = 0

        return calendar.date(from: components) ?? Date()
    }
}
