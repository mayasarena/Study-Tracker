//
//  Color.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-11.
//

import Foundation
import SwiftUI

extension Color {
    
    static let theme = ColorTheme()

}
    
struct ColorTheme {
    
        var accent = Color(UserDefaults.standard.string(forKey: "accentColor") ?? "PurpleAccent")
        let secondary = Color("Secondary")
        let tertiary = Color("Tertiary")
        let mainText = Color("MainText")
        let secondaryText = Color("SecondaryText")
        let lightBG = Color("LightBG")
        let BG = Color("BackgroundColor")
    
        // TOPIC COLORS
        let pink = Color("Pink")
        let red = Color("Red")
        let orange = Color("Orange")
        let yellow = Color("Yellow")
        let green = Color("Green")
    
        let purple = Color("Purple")
        let lightBlue = Color("LightBlue")
        let mediumBlue = Color("MediumBlue")
        let darkBlue = Color("DarkBlue")
        let turquoise = Color("Turquoise")
    
        let defaultTopicColor = Color("Default")
}



