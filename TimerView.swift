//
//  TimerView.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-09-21.
//

import SwiftUI
import Foundation

struct TimerView: View {
    
    @ObservedObject var stopWatchManager = StopWatchManager()
    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
    @ObservedObject var popupViewModel = PopupViewModel.instance
    @ObservedObject var topicEditorViewModel = TopicEditorViewModel.instance
    
    @State var startTime = Date()
    @State var endTime = Date()
    
    @State private var showWarningPopup = false
    @State private var showTopicSheet = false
    @State private var showCompletePopup = false
    @State private var focusedMinutesString = ""
    
    let userDefaults = UserDefaults.standard
    let START_TIME_KEY = "startTime"
    let IS_COUNTING_KEY = "isCounting"
    
    @AppStorage("timerSelectedTopicName") var selectedTopicName = ""
    
    @Environment(\.scenePhase) var scenePhase
    
    //@State var showPopup: Bool = false
    
    var dateFormatter = DateFormatter()
    
    var title: String {
        switch stopWatchManager.mode {
        case .stopped:
            return "Let's get focused!"
        case .running:
            return "Stay focused!"
        case .paused:
            return "Get back to studying."
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                VStack(spacing: UIScreen.main.bounds.height * 0.02) {
                    // MARK: Choose Tag
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(lineWidth: 1)
                            .foregroundColor(Color.theme.accent)
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.theme.BG).shadow(color: Color.theme.accent.opacity(0.5), radius: 2, x: 2, y: 2))
                            .frame(width: 130, height: 30)
                        
                        HStack(spacing: 5) {
                            if coreDataViewModel.timerViewSelectedTopicEntity != nil {
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(Color(TopicColors().convertStringToColor(color: coreDataViewModel.timerViewSelectedTopicEntity?.color ?? "")))
                            }
                            
                            //coreDataViewModel.timerViewSelectedTopicEntity
                            Text(coreDataViewModel.timerViewSelectedTopicEntity?.topic ?? "Choose a tag")
                                .foregroundColor(coreDataViewModel.timerViewSelectedTopicEntity == nil ? Color.theme.mainText.opacity(0.7) : Color.theme.mainText)
                                .font(.smallFont)
                                .frame(maxWidth: .infinity)
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(Color.theme.mainText.opacity(0.5))
                        }
                        .padding(.horizontal, 10)
                        .frame(width: 130, height: 30)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.7)){
                                popupViewModel.showTimerPopup.toggle()
                            }
                        }
                    }
                        .padding(.bottom, 20)
                    
                    Text("⏰")
                        .font(.system(size: 80))
                    // MARK: Time
                    Text(stopWatchManager.secondsToHoursMinutesSeconds(seconds: stopWatchManager.secondsElapsed))
                        .font(.stopwatchFont)
                        .foregroundColor(Color.theme.BG)
                        .padding(.bottom, 20)
                    
                    // MARK: Button
                    if stopWatchManager.mode == .stopped {
                        Button(action: {
                            SoundManager.instance.playSound(sound: .button_click_1)
                            NotificationManager.instance.scheduleTimerReminderNotification()
                            self.stopWatchManager.start()
                            startTime = Date()
                            
                            // User Defaults
                            userDefaults.set(startTime, forKey: START_TIME_KEY)
                            print("Start Time")
                            print(userDefaults.object(forKey: "startTime") ?? Date())
                            userDefaults.set(true, forKey: IS_COUNTING_KEY)
                            print(userDefaults.bool(forKey: "isCounting"))
                            
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            print("start date: " + dateFormatter.string(from: startTime))
                        }) {
                            Text("Start timer")
                                .tracking(2)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    
                    if stopWatchManager.mode == .running {
                        Button(action: {
                            if stopWatchManager.secondsElapsed < 300 { // if less than 5 mins
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.7)){
                                    SoundManager.instance.playSound(sound: .under_5_min)
                                    showWarningPopup.toggle()
                                }
                            }
                            else {
                                SoundManager.instance.playSound(sound: .study_done)
                                self.stopWatchManager.stop()
                                endTime = Date()
                                selectedTopicName = ""
                                userDefaults.set(false, forKey: IS_COUNTING_KEY)
                                print(userDefaults.bool(forKey: "isCounting"))
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                print("START TIME: ")
                                print(userDefaults.object(forKey: "startTime") ?? Date())
                                let startTimeUD = userDefaults.object(forKey: START_TIME_KEY) as? Date
                                let calendar = Calendar.current
                                
                                // Check if studying past midnight
                                let startDay = calendar.component(.day, from: startTimeUD ?? Date())
                                let endDay = calendar.component(.day, from: endTime)
                                
                                if startDay != endDay {
                                    var components = DateComponents()
                                    components.day = 1
                                    components.second = -1
                                    let day1End = calendar.date(byAdding: components, to: calendar.startOfDay(for: startTimeUD ?? Date()))
                                    let day2Begin = calendar.startOfDay(for: endTime)
                                    
                                    let focusedMinutesDay1 = calculateFocusedMinutes(startTime: startTimeUD ?? Date(), endTime: day1End ?? Date())
                                    let focusedMinutesDay2 = calculateFocusedMinutes(startTime: day2Begin, endTime: endTime)
                                    let focusedMinutes = focusedMinutesDay1 + focusedMinutesDay2
                                    focusedMinutesString = MinutesToHoursMinutes(mins: focusedMinutes)
                                    
                                    // add first day data
                                    coreDataViewModel.addTimeData(startTime: startTimeUD ?? Date(), endTime: day1End ?? Date(), topicEntity: coreDataViewModel.timerViewSelectedTopicEntity)
                                    
                                    // add second day data
                                    coreDataViewModel.addTimeData(startTime: day2Begin, endTime: endTime, topicEntity: coreDataViewModel.timerViewSelectedTopicEntity)
                                    
                                }
                                
                                // Study time in same day
                                else {
                                    coreDataViewModel.addTimeData(startTime: startTimeUD ?? Date(), endTime: endTime, topicEntity: coreDataViewModel.timerViewSelectedTopicEntity)
                                    let focusedMinutes = calculateFocusedMinutes(startTime: startTimeUD ?? Date(), endTime: endTime)
                                    focusedMinutesString = MinutesToHoursMinutes(mins: focusedMinutes)
                                }
        
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.7)){
                                    showCompletePopup.toggle()
                                }
                            }
                        }) {
                            Text("Stop timer")
                                .tracking(2)
                        }
                        .buttonStyle(WarningButtonStyle())
                    }
                }
                .padding(.top, UIScreen.main.bounds.height * 0.09)
                //.padding(.bottom, UIScreen.main.bounds.height * 0.2)
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.62, alignment: .top)
                .background(
                    LinearGradient(colors: [Color.theme.accent, Color.theme.accent.opacity(0.7)], startPoint: .bottom, endPoint: .top)
                    .ignoresSafeArea()
                )

                SemiCircleShape()
                    .frame(height: 50)
                    .foregroundColor(Color.theme.accent)
                    .shadow(color: Color.theme.accent.opacity(0.5), radius: 2, x: 2, y: 2)
            }
            .background(Color.theme.BG)
            .frame(maxWidth: .infinity, alignment: .top)
            
            VStack(alignment: .leading, spacing: 15) {
                Text(greeting())
                    .padding(.top, UIScreen.main.bounds.height * 0.01)
                    .padding(.leading, 30)
                    .foregroundColor(Color.theme.mainText)
                    .font(.reallyBigFont)
                
                HStack(spacing: 0) {
                    Text("Today, you have studied for ")
                        .font(.mediumSemiBoldFont)
                        .foregroundColor(Color.theme.secondaryText)
                    Text("\(MinutesToHoursMinutes(mins: coreDataViewModel.getTotalMinutesDay())).")
                        .font(.mediumBoldFont)
                        .foregroundColor(Color.theme.secondaryText)
                }
                .padding(.leading, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.theme.BG)
            .padding(.bottom, 50)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                print("Active")
                if userDefaults.bool(forKey: IS_COUNTING_KEY) {
                    print(userDefaults.object(forKey: START_TIME_KEY) ?? Date())
                    print(Date())
                    print("timer running")
                    let startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
                    let difference = (startTime ?? Date()).timeIntervalSinceNow
                    stopWatchManager.setSecondsElapsed(time: Int(difference * -1))
                }
                else {
                    print("timer not running")
                }
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("Background")
            }
        }
        .onAppear(perform: {
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests(completionHandler: { requests in
                for request in requests {
                    print(request)
                }
            })
            
            coreDataViewModel.getTimes(forDay: Date())
            if (userDefaults.bool(forKey: IS_COUNTING_KEY) && selectedTopicName != ""){
                coreDataViewModel.getTopic(name: selectedTopicName)
                if coreDataViewModel.topicSearchedByName.count > 0 {
                    let topic = coreDataViewModel.topicSearchedByName[0]
                    coreDataViewModel.timerViewSelectedTopicEntity = topic
                }
            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    
        // POPUP
        .popup(horizontalPadding: 40, show: $popupViewModel.showTimerPopup) {
            // Popup content which will also perform navigation ?? whatever that means
            topicSelectionPopup
                .transition(.scale)
                .background(Color.theme.BG)
                .cornerRadius(25)
                .padding(.horizontal, 50)
        }
        
        // POPUP
        .popup(horizontalPadding: 40, show: $showWarningPopup) {
            // Popup content which will also perform navigation ?? whatever that means
            lessThan5WarningPopup
                .transition(.scale)
                .padding(.vertical, 10)
                .background(Color.theme.BG)
                .cornerRadius(25)
                .padding(.horizontal, 30)
        }
        
        // POPUP
        .popup(horizontalPadding: 40, show: $showCompletePopup) {
            // Popup content which will also perform navigation ?? whatever that means
            sessionCompletePopup
                .transition(.scale)
                .padding(.vertical, 10)
                .background(Color.theme.BG)
                .cornerRadius(25)
                .padding(.horizontal, 30)
        }
    }
    
    var sessionCompletePopup: some View {
        VStack(spacing: 0) {
            Text("🥳")
                .font(.system(size: 100))
                .padding(.bottom, 10)
            
            VStack(spacing: 10) {
                Text("Study Session Complete")
                    .foregroundColor(Color.theme.mainText)
                    .font(.mediumBoldFont)
                Text("You have successfully completed a \(focusedMinutesString) study session.")
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.theme.secondaryText)
                    .font(.regularSemiBoldFont)
            }
            
            Button {
                withAnimation {
                    selectedTopicName = ""
                    SoundManager.instance.playSound(sound: .button_click_ok)
                    showCompletePopup.toggle()
                }
            } label: {
                Text("Close")
                    .tracking(2)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 30)
            
        }
        .padding()
        
    }
    
    var lessThan5WarningPopup: some View {
        VStack(spacing: 0) {
            Text("😋")
                .font(.system(size: 100))
                .padding(.bottom, 10)
            
            VStack(spacing: 10) {
                Text("Session Too Short")
                    .foregroundColor(Color.theme.mainText)
                    .font(.mediumBoldFont)
                Text("Entries must be 5 minutes or longer. If you stop the timer now, your data won't be recorded!")
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.theme.secondaryText)
                    .font(.regularSemiBoldFont)
            }
            
            HStack (spacing: 30) {
                
                Button {
                    self.stopWatchManager.stop()
                    selectedTopicName = ""
                    SoundManager.instance.playSound(sound: .button_click_cancel)
                    userDefaults.set(false, forKey: IS_COUNTING_KEY)
                    print(userDefaults.bool(forKey: "isCounting"))
                    withAnimation() {
                        showWarningPopup.toggle()
                    }
                } label: {
                    Text("Stop timer")
                        .tracking(2)
                }
                .buttonStyle(WarningButtonStyle())
                
                Button {
                    withAnimation() {
                        SoundManager.instance.playSound(sound: .button_click_ok)
                        showWarningPopup.toggle()
                    }
                } label: {
                    Text("keep going")
                        .tracking(2)
                }
                .buttonStyle(PrimaryButtonStyle())

            }
            .padding(.top, 30)
            
        }
        .padding()
        
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
                                        coreDataViewModel.updateTimerViewSelectedTopic(entity: topic)
                                        selectedTopicName = topic.topic ?? ""
                                    }
                            
                                if coreDataViewModel.timerViewSelectedTopicEntity == topic {
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
                        popupViewModel.showTimerPopup.toggle()
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
    
    func greeting() -> String {
        let date = NSDate()
        let calendar = NSCalendar.current
        let currentHour = calendar.component(.hour, from: date as Date)
        let hourInt = Int(currentHour.description)!
        
        if hourInt >= 5 && hourInt < 12 {
            return "Good morning! "
        }
        
        else if hourInt >= 12 && hourInt < 17 {
            return "Good afternoon!"
        }
        
        else if hourInt >= 17 && hourInt < 21 {
            return "Good evening!"
        }
        
        else if (hourInt >= 21 && hourInt <= 24) || (hourInt >= 0 && hourInt < 5) {
            return "Good night!"
        }
        
        return "Hello!"
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
        TimerView().topicSelectionPopup
            .previewLayout(.fixed(width: 400, height: 500))
    }
}
