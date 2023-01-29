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
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.regularBoldFont)
            .textCase(.uppercase)
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 5)
            .frame(width: 150, height: 50)
            .foregroundColor(Color.theme.mainText)
            .background(Color.theme.BG)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.theme.mainText.opacity(1), lineWidth: 1.5)
            )
        
    }
}

struct StopTimerButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.regularBoldFont)
            .textCase(.uppercase)
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 5)
            .frame(width: 150, height: 50)
            .foregroundColor(Color(#colorLiteral(red: 0.8901960784, green: 0.3764705882, blue: 0.3764705882, alpha: 1)))
            .background(Color.theme.BG)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color(#colorLiteral(red: 0.8901960784, green: 0.3764705882, blue: 0.3764705882, alpha: 1)).opacity(1), lineWidth: 1.5)
            )
        
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
