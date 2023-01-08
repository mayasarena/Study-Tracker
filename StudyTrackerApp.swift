//
//  StudyTrackerApp.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-09-21.
//

import SwiftUI

@main
struct StudyTrackerApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext, CoreDataViewModel.instance.container.viewContext)
        }
    }
}
