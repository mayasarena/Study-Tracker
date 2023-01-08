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
                settingsManager.applyColorMode()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
