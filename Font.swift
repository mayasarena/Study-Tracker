//
//  Font.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-11-24.
//

import Foundation
import SwiftUI

extension Font {
    static let boldHeader = Font.custom("OpenSans-Bold", size: 18)
    static let reallyBigFont = Font.custom("OpenSans-Bold", size: 20)
    static let graphAxisFont = Font.custom("OpenSans-Regular", size: 10)
    
    static let regularFont = Font.custom("OpenSans-Regular", size: 12)
    
    static let smallBoldFont = Font.custom("OpenSans-Bold", size: 10)
    static let regularBoldFont = Font.custom("OpenSans-Bold", size: 12)
    static let mediumBoldFont = Font.custom("OpenSans-Bold", size: 14)
    
    static let regularSemiBoldFont = Font.custom("OpenSans-SemiBold", size: 12)
    static let smallSemiBoldFont = Font.custom("OpenSans-SemiBold", size: 10)
    static let mediumSemiBoldFont = Font.custom("OpenSans-SemiBold", size: 14)
    static let stopwatchFont = Font.custom("OpenSans-SemiBold", size: 60)
    
    static let smallExtraBoldFont = Font.custom("OpenSans-ExtraBold", size: 10)
}

extension Font.TextStyle {
    var size: CGFloat {
        switch self {
        case .largeTitle: return 60
        case .title: return 48
        case .title2: return 34
        case .title3: return 24
        case .headline, .body: return 18
        case .subheadline, .callout: return 16
        case .footnote: return 14
        case .caption: return 12
        case .caption2: return 10
        @unknown default:
            return 8
        }
    }
}
