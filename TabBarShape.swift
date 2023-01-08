//
//  SpeechBubble.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-11-15.
//

import SwiftUI

struct TabBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            // bottom left - start
            path.move(to: CGPoint(x: rect.minX+3, y: rect.maxY))
            
            // left curve
            path.addQuadCurve(
                to: CGPoint(x: rect.midX-5, y: rect.maxY-10),
                control: CGPoint(x: rect.midX-13, y: rect.maxY))
            
            // middle curve
            path.addQuadCurve(
                to: CGPoint(x: rect.midX+5, y: rect.maxY-10),
                control: CGPoint(x: rect.midX, y: rect.maxY-15))
            
            // right curve
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX-3, y: rect.maxY),
                control: CGPoint(x: rect.midX+13, y: rect.maxY))

            

        }
    }
}

struct TabShape: View {
    
    var body: some View {
        TabBarShape()
            .background(.green.opacity(0.3))
            .foregroundColor(.red)
            .shadow(radius: 3)
            .frame(width: UIScreen.main.bounds.width/5-15, height: 20)
    }
    
}

struct TabShape_Previews: PreviewProvider {
    static var previews: some View {
        TabShape()
    }
}
