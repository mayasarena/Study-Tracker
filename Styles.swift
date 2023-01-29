//
//  Styles.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-11.
//

import Foundation
import SwiftUI

// MARK: Buttons
struct StartTimerButtonStyle: ButtonStyle {
    
    @EnvironmentObject var settingsManager: SettingsManager
    
    func makeBody(configuration: Configuration) -> some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 150, height: 55)
                .foregroundColor(settingsManager.colorMode == ColorMode.dark ? Color.theme.BG : Color.theme.mainText.opacity(0.6))
                .offset(y: 2.5)
            
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 150, height: 50)
                .foregroundColor(settingsManager.colorMode == ColorMode.dark ? Color.theme.BG : Color.theme.BG)
            
            configuration.label
                .font(.regularBoldFont)
                .textCase(.uppercase)
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 5)
                .offset(y: 0)
                .frame(width: 150, height: 50)
                .foregroundColor(settingsManager.colorMode == ColorMode.dark ? Color.theme.mainText : Color.theme.mainText)
                .background(settingsManager.colorMode == ColorMode.dark ? Color.theme.accent.opacity(0.35) : Color.theme.accent.opacity(0.2))
                .cornerRadius(15)
        }
    }
}

struct StopTimerButtonStyle: ButtonStyle {
    
    @EnvironmentObject var settingsManager: SettingsManager
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 150, height: 55)
                .foregroundColor(settingsManager.colorMode == ColorMode.dark ? Color.theme.BG.opacity(0.5) : Color.theme.mainText.opacity(0.3))
                .offset(y: 2.5)
            
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 150, height: 50)
                .foregroundColor(settingsManager.colorMode == ColorMode.dark ? Color.theme.mainText : Color.theme.BG)
            
            configuration.label
                .font(.regularBoldFont)
                .textCase(.uppercase)
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 5)
                .offset(y: 0)
                .frame(width: 150, height: 50)
                .foregroundColor(settingsManager.colorMode == ColorMode.dark ? Color(#colorLiteral(red: 0.8901960784, green: 0.3764705882, blue: 0.3764705882, alpha: 1)) : Color(#colorLiteral(red: 0.8901960784, green: 0.3764705882, blue: 0.3764705882, alpha: 1)))
                .background(settingsManager.colorMode == ColorMode.dark ? Color.theme.accent.opacity(0.23) : Color.theme.accent.opacity(0.1))
                .cornerRadius(15)
        }
        
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.smallBoldFont)
            .textCase(.uppercase)
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 5)
        
            .frame(width: 120, height: 35)
            .foregroundColor(Color.theme.BG)
            .background(isEnabled ? Color.theme.accent : Color.theme.accent.opacity(0.5))
            .cornerRadius(15)
        
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.smallBoldFont)
            .textCase(.uppercase)
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 5)
        
            .frame(width: 120, height: 35)
            .foregroundColor(isEnabled ? Color.theme.mainText : Color.theme.mainText.opacity(0.5))
            .background(Color.theme.lightBG)
            .cornerRadius(15)
    }
}

struct WarningButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.smallBoldFont)
            .textCase(.uppercase)
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 5)
        
            .frame(width: 120, height: 35)
            .foregroundColor(Color(#colorLiteral(red: 0.8901960784, green: 0.3764705882, blue: 0.3764705882, alpha: 1)))
            .background(Color.theme.lightBG)
            .cornerRadius(15)
    }
}
