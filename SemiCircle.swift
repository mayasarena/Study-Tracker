//
//  SpeechBubble.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-11-15.
//

import SwiftUI

struct SemiCircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            // bottom left - start
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            
            // left curve
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY),
                control: CGPoint(x: rect.midX, y: rect.minY+60))
        }
    }
}

struct SemiCircle: View {
    
    var body: some View {
        SemiCircle()
            .background(.green.opacity(0.3))
            .foregroundColor(.red)
            .shadow(radius: 3)
            .frame(maxWidth: .infinity)
            .frame(height: 300)
    }
    
}

struct SemiCircle_Previews: PreviewProvider {
    static var previews: some View {
        SemiCircleShape()
    }
}
