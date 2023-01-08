//
//  SettingsView.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2023-01-05.
//

import SwiftUI
import UIKit

enum ColorMode: Int {
    case unspecified, light, dark
}

class SettingsManager: ObservableObject {
    
    @AppStorage("colorMode") var colorMode: ColorMode = .unspecified {
        didSet {
            applyColorMode()
        }
    }
    
    func applyColorMode() {
        keyWindow?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: colorMode.rawValue)!
    }
    
    var keyWindow: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window
        else {
            return nil
        }
        return window
    }
}

class AppColorManager: ObservableObject {
    
    @AppStorage("accentColor") private var accentColor = "PurpleAccent"
    @AppStorage("colorMode") var colorMode: ColorMode = .unspecified
    
    static let instance = AppColorManager()
    @Published var selectedAccentColor: String = ""
    @Published var selectedColorMode: ColorMode = .unspecified
    
    init() {
        selectedAccentColor = accentColor
        selectedColorMode = colorMode
    }
}

struct SettingsView: View {
    
    @ObservedObject var appColorManager = AppColorManager.instance
    @EnvironmentObject var settingsManager: SettingsManager
    @AppStorage("colorMode") private var colorMode: ColorMode = .unspecified
    @AppStorage("accentColor") private var accentColor = "PurpleAccent"
    @State var showColorChangeAlert: Bool = false
    
    let userDefaults = UserDefaults.standard
    let ACCENT_COLOR_KEY = "accentColor"
    
    let accentTitleStrings = ["Purple (Default)", "Blue", "Green", "Orange", "Pink"]
    let accentNameStrings = ["PurpleAccent", "BlueAccent", "GreenAccent", "OrangeAccent", "PinkAccent"]
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {

                    Text("App Accent Colour")
                        .font(.regularSemiBoldFont)
                        .foregroundColor(Color.theme.secondaryText)
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(0...4, id: \.self) { index in
                        
                        VStack {
                            HStack {
                                HStack (spacing: 15) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color(accentNameStrings[index]))
                                        .frame(width: 20)
                                        .frame(height: 20)
                                    
                                    Text(accentTitleStrings[index])
                                        .font(.mediumSemiBoldFont)
                                        .foregroundColor(Color.theme.mainText)
                                        .padding(.vertical, 5)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.theme.BG)
                                .onTapGesture {
                                    accentColor = accentNameStrings[index]
                                    appColorManager.selectedAccentColor = accentColor
                                    print("clicked \(accentTitleStrings[index])")
                                    showColorChangeAlert = true
                                }
                                .alert(isPresented: $showColorChangeAlert) {
                                    Alert(
                                        title: Text("New accent color will be applied once the app is restarted."),
                                        message: Text("To fully close the app, swipe from the bottom of the phone screen to the middle of the screen, which will open the multitasking view. Scroll to find this app then swipe up on it to close it. Once you re-open the app, your new accent color will be applied!"))}
                                Spacer()
                                Circle()
                                    .strokeBorder(lineWidth: 1)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(Color.theme.mainText)
                                    .overlay(
                                            Circle()
                                                .frame(width: 9, height: 9)
                                                .foregroundColor(appColorManager.selectedAccentColor == accentNameStrings[index] ? Color.theme.accent : Color.theme.BG)
                                        , alignment: .center)
                            }
                            
                            Rectangle()
                                .frame(maxHeight: 1)
                                .foregroundColor(Color.theme.secondaryText.opacity(0.15))
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    
                    Text("App Colour Mode")
                        .font(.regularSemiBoldFont)
                        .foregroundColor(Color.theme.secondaryText)
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack {
                        HStack {
                            Text("Light Mode")
                                .font(.mediumSemiBoldFont)
                                .foregroundColor(Color.theme.mainText)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.theme.BG)
                                .onTapGesture {
                                    settingsManager.colorMode = ColorMode.light
                                    appColorManager.selectedColorMode = ColorMode.light
                                }
                            Spacer()
                            Circle()
                                .strokeBorder(lineWidth: 1)
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.theme.mainText)
                                .overlay(
                                        Circle()
                                            .frame(width: 9, height: 9)
                                            .foregroundColor(appColorManager.selectedColorMode == ColorMode.light ? Color.theme.accent : Color.theme.BG)
                                    , alignment: .center)
                        }
                        
                        Rectangle()
                            .frame(maxHeight: 1)
                            .foregroundColor(Color.theme.secondaryText.opacity(0.15))
                    }
                    .padding(.horizontal, 20)
                    
                    VStack {
                        HStack {
                            Text("Dark Mode")
                                .font(.mediumSemiBoldFont)
                                .foregroundColor(Color.theme.mainText)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.theme.BG)
                                .onTapGesture {
                                    settingsManager.colorMode = ColorMode.dark
                                    appColorManager.selectedColorMode = ColorMode.dark
                                }
                            Spacer()
                            Circle()
                                .strokeBorder(lineWidth: 1)
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.theme.mainText)
                                .overlay(
                                        Circle()
                                            .frame(width: 9, height: 9)
                                            .foregroundColor(appColorManager.selectedColorMode == ColorMode.dark ? Color.theme.accent : Color.theme.BG)
                                    , alignment: .center)
                        }
                        
                        Rectangle()
                            .frame(maxHeight: 1)
                            .foregroundColor(Color.theme.secondaryText.opacity(0.15))
                    }
                    .padding(.horizontal, 20)

                    VStack {
                        HStack {
                            Text("System Default")
                                .font(.mediumSemiBoldFont)
                                .foregroundColor(Color.theme.mainText)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.theme.BG)
                                .onTapGesture {
                                    settingsManager.colorMode = ColorMode.unspecified
                                    appColorManager.selectedColorMode = ColorMode.unspecified
                                }
                            Spacer()
                            Circle()
                                .strokeBorder(lineWidth: 1)
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.theme.mainText)
                                .overlay(
                                        Circle()
                                            .frame(width: 9, height: 9)
                                            .foregroundColor(appColorManager.selectedColorMode == ColorMode.unspecified ? Color.theme.accent : Color.theme.BG)
                                    , alignment: .center)
                        }
                        
                        Rectangle()
                            .frame(maxHeight: 1)
                            .foregroundColor(Color.theme.secondaryText.opacity(0.15))
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.theme.BG)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsManager())
    }
}
