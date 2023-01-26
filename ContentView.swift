//
//  ContentView.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-03.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var settingsManager = SettingsManager()
    
    var body: some View {
        
        CustomTabBar()
            .environmentObject(settingsManager)
            .onAppear {
                let defaults = UserDefaults.standard
                
                if defaults.bool(forKey: "isAppLaunchedOnce") {
                    print("Not first launch")
                }
                else {
                    defaults.set(true, forKey: "isAppLaunchedOnce")
                    print("First launch")
                    NotificationManager.instance.requestAuthorization()
                }
                settingsManager.applyColorMode()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
