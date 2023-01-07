//
//  TopicEditorView.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-10-06.
//

import SwiftUI

class TopicEditorViewModel: ObservableObject {
    static let instance = TopicEditorViewModel()
    @Published var addTopicPopupOpened: Bool = false
    @Published var editTopicPopupOpened: Bool = false
}

struct TopicEditorView: View {

    @ObservedObject var coreDataViewModel = CoreDataViewModel.instance
  //  @ObservedObject var popupViewModel = PopupViewModel.instance
    @ObservedObject var topicEditorViewModel = TopicEditorViewModel.instance
//    @State var showAddTopicPopup: Bool = false
//    @State var showEditTopicPopup: Bool = false
    @State var addTopicTextfield: String = ""
    @State var editTopicTextfield: String = ""
    @State var selectedColor: String = ""
    @State var showDeleteAlert: Bool = false
    @State var showChooseDiffNameAlert: Bool = false
    
    @State var searchText: String = ""
    
    @FocusState var isInputActive: Bool
    
    @State var showAddTopicPopup: Bool = false
    @State var showEditTopicPopup: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    // MARK: List of topics
                    VStack {
                        // Add a new topic
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .strokeBorder(lineWidth: 1)
                                .foregroundColor(Color.theme.accent)
                                .background(RoundedRectangle(cornerRadius: 25).fill(Color.theme.BG).shadow(color: Color.theme.accent.opacity(0.5), radius: 2, x: 2, y: 2))
                                .frame(width: 200, height: 50)
                            
                            HStack {
                                Image(systemName: "plus")
                                    .foregroundColor(Color.theme.mainText)
                                Text("Add a new tag")
                                    .font(.mediumSemiBoldFont)
                                    .foregroundColor(Color.theme.mainText)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.7)){
                                showAddTopicPopup.toggle()
                                topicEditorViewModel.addTopicPopupOpened.toggle()
                            }
                        }
                        if (coreDataViewModel.topics.isEmpty) {
                            Text("No tags yet!")
                                .foregroundColor(Color.theme.secondaryText)
                                .font(.mediumSemiBoldFont)
                                .padding(.top, 50)
                        }
                        // MARK: Building topic list
                        ForEach(coreDataViewModel.topics) { topic in
                            VStack {
                                HStack {
                                    HStack(spacing: 10) {
                                        Image(systemName: "tag.fill")
                                            .foregroundColor(Color(TopicColors().convertStringToColor(color: topic.color ?? "Pink")))
                                        Text("\(topic.topic ?? "")")
                                            .font(.regularBoldFont)
                                            .foregroundColor(Color.theme.mainText)
                                    }
                                    Spacer()
                                    // Topic list Edit Button
                                    Button {
                                        coreDataViewModel.updateTopicEditorSelectedTopic(entity: topic)
                                        selectedColor = coreDataViewModel.topicEditorSelectedTopic?.color ?? ""
                                        editTopicTextfield = coreDataViewModel.topicEditorSelectedTopic?.topic ?? ""
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.7)){
                                            showEditTopicPopup.toggle()
                                            topicEditorViewModel.editTopicPopupOpened.toggle()
                                        }
                                    } label: {
                                        Image(systemName: "pencil")
                                            .foregroundColor(Color.theme.secondaryText)
                                    }
                                }
                                .padding(.horizontal, 22)
                                .padding(.vertical, 15)
                                .background(Color.theme.lightBG)
                                .cornerRadius(15)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 4)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            
                            Button("Done") {
                                isInputActive = false
                            }
                        }
                    }
                }
                
                ZStack {
                    if showAddTopicPopup {
                        Color.primary.opacity(0.15).ignoresSafeArea()
                        addTopicPopupContent
                            .transition(.scale)
                            .background(Color.theme.BG)
                                .ignoresSafeArea()
                            .cornerRadius(25)
                            .padding(.horizontal, 30)
                    }
                }
                .zIndex(2.0)
                
                ZStack {
                    if showEditTopicPopup {
                        Color.primary.opacity(0.15).ignoresSafeArea()
                        editTopicPopupContent
                            .transition(.scale)
                            .background(Color.theme.BG)
                                .ignoresSafeArea()
                            .cornerRadius(25)
                            .padding(.horizontal, 30)
                    }
                }
                .zIndex(2.0)
                
            }
            .frame(maxWidth: .infinity)
            .background(Color.theme.BG)
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }

    }
    
    // MARK: Add Topic Popup
    var addTopicPopupContent: some View {
        VStack(spacing: 40) {
            Text("Add Tag")
                .font(.mediumBoldFont)
                .foregroundColor(Color.theme.mainText)
            
            HStack(spacing: 20) {
                Image(systemName: "tag")
                    .font(.regularBoldFont)
                    .foregroundColor(Color(TopicColors().convertStringToColor(color: selectedColor)))
                TextField("Topic name...", text: $addTopicTextfield)
                    .foregroundColor(Color.theme.mainText)
                    .focused($isInputActive)
                    .keyboardType(.alphabet)
                    .disableAutocorrection(true)
            }
            .font(.regularFont)
            .padding(.leading)
            .frame(height: 40)
            .background(Color.theme.lightBG)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.theme.secondaryText.opacity(0.15), lineWidth: 1.5)
            )
            .padding(.horizontal, 20)

            // Color list
            VStack(spacing: 25) {
                colorSelectionButtons(selectedColor: self.$selectedColor)
            }

            HStack(spacing: 30) {
                Button {
                    selectedColor = ""
                    addTopicTextfield = ""
                    withAnimation(){
                        showAddTopicPopup.toggle()
                        topicEditorViewModel.addTopicPopupOpened.toggle()
                    }
                } label: {
                    Text("Cancel")
                        .tracking(2)
                }
                .buttonStyle(WarningButtonStyle())

                Button {
                    guard !addTopicTextfield.isEmpty else { return }
                    coreDataViewModel.getTopic(name: addTopicTextfield)
                    if (coreDataViewModel.topicSearchedByName.count > 0) {
                        showChooseDiffNameAlert = true
                    }
                    else {
                        coreDataViewModel.addTopicData(topic: addTopicTextfield, color: selectedColor)
                        selectedColor = ""
                        addTopicTextfield = ""
                        withAnimation(){
                            showAddTopicPopup.toggle()
                            topicEditorViewModel.addTopicPopupOpened.toggle()
                        }
                    }
                } label: {
                    Text("Save")
                        .tracking(2)
                }
                .disabled(addTopicTextfield.isEmpty || selectedColor == "")
                .buttonStyle(PrimaryButtonStyle())
                .alert(isPresented: $showChooseDiffNameAlert) {
                    Alert(
                        title: Text("You already have a topic with this name."),
                        message: Text("Please choose a new name!")
                    )
                }
            }
        }
        .padding(.vertical, 10)
        .padding()
    }
    
    // MARK: Edit Topic Popup
    var editTopicPopupContent: some View {
        VStack(spacing: 40) {
            ZStack {
                HStack {
                    Button {
                        selectedColor = ""
                        withAnimation{
                            showEditTopicPopup.toggle()
                            topicEditorViewModel.editTopicPopupOpened.toggle()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 15, height: 15, alignment: .leading)
                            .foregroundColor(Color.theme.mainText)
                    }
                    .padding(.leading, 20)
                    Spacer()
                }
                
                HStack {
                    Text("Edit Tag")
                    .font(.mediumBoldFont)
                    .foregroundColor(Color.theme.mainText)
                }
            }
            HStack(spacing: 20) {
                Image(systemName: "tag")
                    .font(.regularBoldFont)
                    .foregroundColor(Color(TopicColors().convertStringToColor(color: selectedColor)))
                TextField("\(editTopicTextfield)", text: $editTopicTextfield)
                    .foregroundColor(Color.theme.mainText)
                    .focused($isInputActive)
                    .keyboardType(.alphabet)
                    .disableAutocorrection(true)
            }
            .font(.regularFont)
            .padding(.leading)
            .frame(height: 40)
            .background(Color.theme.lightBG)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.theme.secondaryText.opacity(0.15), lineWidth: 1.5)
            )
            .padding(.horizontal, 20)
        
            // Color list
            VStack(spacing: 25) {
                colorSelectionButtons(selectedColor: self.$selectedColor)
            }
            
            HStack(spacing: 30){
                Button {
                    showDeleteAlert = true
                } label: {
                    Text("Delete Tag")
                        .tracking(2)
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete this tag?"),
                        message: Text("The tag will be deleted forever. Entries currently using this tag will become untagged."),
                        primaryButton: .default(Text("Nevermind")),
                        secondaryButton: .destructive(
                            Text("Delete Forever"),
                            action: {
                                coreDataViewModel.deleteTopicData2(topicEntity: coreDataViewModel.topicEditorSelectedTopic!)
                                selectedColor = ""
                                withAnimation{
                                    showEditTopicPopup.toggle()
                                    topicEditorViewModel.editTopicPopupOpened.toggle()
                                }
                            })

                    )
                }
                
                .buttonStyle(WarningButtonStyle())
                Button {
                    guard !editTopicTextfield.isEmpty else { return }
                    coreDataViewModel.getTopic(name: editTopicTextfield)
                    if (editTopicTextfield != coreDataViewModel.topicEditorSelectedTopic?.topic && coreDataViewModel.topicSearchedByName.count > 0) {
                        showChooseDiffNameAlert = true
                    }
                    else {
                        coreDataViewModel.updateTopicName(entity: coreDataViewModel.topicEditorSelectedTopic!, newTopicName: editTopicTextfield)
                        coreDataViewModel.updateTopicColor(entity: coreDataViewModel.topicEditorSelectedTopic!, newTopicColor: selectedColor)
                        editTopicTextfield = ""
                        selectedColor = ""
                        withAnimation(){
                            showEditTopicPopup.toggle()
                            topicEditorViewModel.editTopicPopupOpened.toggle()
                        }
                    }
                } label: {
                    Text("Save")
                        .tracking(2)
                }
                .buttonStyle(PrimaryButtonStyle())
                .alert(isPresented: $showChooseDiffNameAlert) {
                    Alert(
                        title: Text("You already have a topic with this name."),
                        message: Text("Please choose a new name!")
                    )
                }
            }
        }
        .padding(.vertical, 10)
        .padding()
    }
}

// MARK: Color Selection buttons
struct colorSelectionButtons: View {
    @Binding var selectedColor: String

    var body: some View {
        HStack(spacing: 5) {
            // Building list of colors
            ForEach(0...4, id: \.self) { index in
                ZStack {
                    Circle()
                        .fill(Color(TopicColors().convertStringToColor(color: TopicColors.colors[index])))
                        .frame(width: 25, height: 25)
                        .padding([.leading, .trailing], 10)
                        .onTapGesture {
                            selectedColor = TopicColors.colors[index]
                        }
                    
                    if TopicColors.colors[index] == selectedColor {
                        Image(systemName: "checkmark")
                            .font(.regularBoldFont)
                            .foregroundColor(.white)
                            .frame(width: 25, height: 25)
                    }
                }
            }
        }
        
        HStack(spacing: 5) {
            // Building list of colors
            ForEach(5...9, id: \.self) { index in
                ZStack {
                    Circle()
                        .fill(Color(TopicColors().convertStringToColor(color: TopicColors.colors[index])))
                        .frame(width: 25, height: 25)
                        .padding([.leading, .trailing], 10)
                        .onTapGesture {
                            selectedColor = TopicColors.colors[index]
                        }
                    
                    if TopicColors.colors[index] == selectedColor {
                        Image(systemName: "checkmark")
                            .font(.regularBoldFont)
                            .foregroundColor(.white)
                            .frame(width: 25, height: 25)
                    }
                }
            }
        }
    }
}

//struct searchBar: View {
//
//    @Binding var searchText: String
//
//    var body: some View {
//
//        HStack {
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(searchText.isEmpty ? Color.theme.accent : Color.theme.mediumPurple)
//
//            TextField("Search topics...", text: $searchText)
//                .disableAutocorrection(true)
//                .overlay(
//                    Image(systemName: "xmark.circle.fill")
//                        .padding()
//                        .offset(x: 10)
//                        .foregroundColor(Color.theme.accent)
//                        .foregroundColor(.red)
//                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
//                        .onTapGesture {
//                            UIApplication.shared.endEditing()
//                            searchText = ""
//                        }
//                    , alignment: .trailing
//                )
//        }
//        .font(.headline)
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 25)
//                .fill(Color.theme.secondary)
//            )
//        .padding()
//
//    }
//}

struct TopicEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TopicEditorView()
        TopicEditorView().addTopicPopupContent
            .previewLayout(.fixed(width: 400, height: 500))
        TopicEditorView().editTopicPopupContent
            .previewLayout(.fixed(width: 400, height: 500))
    }
}

extension UIApplication {
    
    // Dismiss keyboard when X is pressed
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
