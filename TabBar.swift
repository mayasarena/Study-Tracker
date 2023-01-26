//
//  Menu.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-11-21.
//

import SwiftUI

class TabBarViewModel: ObservableObject {
    static let instance = TabBarViewModel()
    @Published var menuOpened: Bool = false
    @Published var selectedIndex: String = "Stopwatch"
    
    func updateSelectedIndex(index: String) {
        selectedIndex = index
    }
    
}

struct TabBar: View {
    
    @ObservedObject var tabBarVM = TabBarViewModel.instance
    
    var body: some View {
        ZStack {
            // Menu
            VStack() {
                Spacer()
                
                HStack(spacing: 1) {
                    MenuButtons(image: "tag.fill", title: "Tags")
                    MenuButtons(image: "clock.arrow.circlepath", title: "History")
                    MenuButtons(image: "stopwatch.fill", title: "Stopwatch")
                    MenuButtons(image: "chart.bar.fill", title: "Charts")
                    MenuButtons(image: "gear", title: "Settings")
                    //MenuButtons(image: "circle", title: "Notifs")
                    //MenuButtons(image: "gear", title: "Debug")
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity, alignment: .center)
                .ignoresSafeArea(edges: .all)
                .background(Color.theme.BG)
            }
        }
    }
}

struct CustomTabBar: View {
    
    @ObservedObject var tabBarVM = TabBarViewModel.instance
    @ObservedObject var topicEditorViewModel = TopicEditorViewModel.instance
    
    var body: some View {
        ZStack {
            TabBar()
                .zIndex(0)
            if tabBarVM.selectedIndex == "Tags" && (topicEditorViewModel.addTopicPopupOpened || topicEditorViewModel.editTopicPopupOpened) {
                Color.primary.opacity(0.15).ignoresSafeArea()
            }
            
            if tabBarVM.selectedIndex == "Stopwatch" {
                TimerView()
            }
            
            if tabBarVM.selectedIndex == "Charts" {
                StatsView()
            }
            
            if tabBarVM.selectedIndex == "History" {
                TimelineView()
            }
            
            if tabBarVM.selectedIndex == "Tags" {
                TopicEditorView()
                    .padding(.bottom, 50)
            }
            
            if tabBarVM.selectedIndex == "Settings" {
                SettingsView()
                    .padding(.bottom, 50)
            }
            
            if tabBarVM.selectedIndex == "Debug" {
                CoreDataBootcamp()
                    .padding(.bottom, 50)
            }
            
            if tabBarVM.selectedIndex == "Notifs" {
                NotificationManagerView()
            }
        
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar()
    }
}

struct MenuButtons: View {
    
    @ObservedObject var sideMenuVM = TabBarViewModel.instance
    var image: String
    var title: String
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: image)
                .frame(width: 30, height: 30)
                .font(.system(size: 20))
            Text(title)
                .font(.system(size: 10))
                .fontWeight(.semibold)
        }
        .foregroundColor(sideMenuVM.selectedIndex == title ? Color.theme.mainText : Color.theme.secondaryText)
        .frame(width: UIScreen.main.bounds.width/5-15, height: 50, alignment: .center)
        .padding(.horizontal, 3)
        .padding(.top)
        .padding(.bottom)
        .onTapGesture {
            sideMenuVM.updateSelectedIndex(index: title)
        }
    }
}
