//
//  TopicColors.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-07.
//

import Foundation
import UIKit

//enum TopicColors: Hashable {
//
//    case undefined, purple, pink
//
//    var colorName: String {
//        switch self {
//            case .undefined: return ""
//            case .purple: return "Purple"
//            case .pink: return "Pink"
//        }
//    }
//
//    var color: UIColor {
//        switch self {
//            case .purple: return UIColor(#colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1))
//            case .pink: return UIColor(#colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1))
//            case .undefined: return UIColor(#colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1))
//        }
//    }
//}

import SwiftUI

class TopicColors {
    
    static let colors: [String] = ["Pink", "Red", "Orange", "Yellow", "Green", "Purple", "Turquoise", "DarkBlue", "MediumBlue", "LightBlue"]

    func convertStringToColor(color: String) -> UIColor {

        switch color {
        case "Pink": return UIColor(Color.theme.pink)
        case "Red": return UIColor(Color.theme.red)
        case "Orange": return UIColor(Color.theme.orange)
        case "Yellow": return UIColor(Color.theme.yellow)
        case "Green": return UIColor(Color.theme.green)
        case "Purple": return UIColor(Color.theme.purple)
        case "Turquoise": return UIColor(Color.theme.turquoise)
        case "DarkBlue": return UIColor(Color.theme.darkBlue)
        case "MediumBlue": return UIColor(Color.theme.mediumBlue)
        case "LightBlue": return UIColor(Color.theme.lightBlue)

        default:
            return UIColor(Color.theme.defaultTopicColor)
        }
    }
}
