//
//  PopupWindow.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2022-10-18.
//

import SwiftUI

// MARK: POPUP
extension View {
    
    // Building custom modifier for custom popup navigation view
    func popup<Content: View>(horizontalPadding: CGFloat = 40, show: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        
        return self
            .frame(maxWidth: .infinity, alignment: .center)
            .overlay {
                if show.wrappedValue {
                    // geometry reader for reading container frame
//                    GeometryReader { proxy in
                        
                        Color.primary
                            .opacity(0.15)
                            .ignoresSafeArea()
                        
//                        let size = proxy.size
                        
                            content()
//                        .frame(width: size.width - horizontalPadding, alignment: .center)
//                        .cornerRadius(15)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
    }
}

class PopupViewModel: ObservableObject {
    static let instance = PopupViewModel()
    @Published var showAddTopicPopup: Bool = false
    @Published var showEditTopicPopup: Bool = false
    @Published var showTimerPopup: Bool = false
}
