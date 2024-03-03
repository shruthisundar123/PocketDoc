//
//  ContentView.swift
//  PocketDoc
//
//  Created by Shruthi Sundar on 2024-03-02.
//

import SwiftUI
import SwiftData
import Auth0
import Cohere

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isAuthenticated = false
    @State var userProfile = Profile.empty
    @State var symptoms = ""

    var body: some View {
        if isAuthenticated == false {
            VStack {
                Text("PocketDoc")
                    .modifier(TitleStyle())
                Button("Log in") {
                    login()
                }
                .buttonStyle(MyButtonStyle())
            }
        }
        else {
            VStack{
                HStack{
                    Text("Hi, \(userProfile.name)!")
                        .modifier(TitleStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    UserImage(urlString: "")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                    
                }

                TextField("What brings you in today, \(userProfile.name)?", text:$symptoms, axis: .vertical)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .lineLimit(3)
                Spacer()
                
                Button("Log out") {
                    logout()
                }
                .buttonStyle(MyButtonStyle())
            }
        }
    }
    
    struct UserImage: View {
        var urlString: String
        var body: some View {
            AsyncImage(url: URL(string: urlString)) {
                image in image
                    .frame(maxWidth: 50)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 50)
                    .foregroundColor(.blue)
                    .opacity(0.5)
            }
        }
    }
    struct TitleStyle: ViewModifier {
        let titleFontBold = Font.title.weight(.bold)
        let maroon = Color(red: 0.8078, green: 0.1490, blue: 0.1098)
        
        func body(content: Content) -> some View {
            content
                .font(titleFontBold)
                .foregroundColor(maroon)
                .padding()
        }
    }
    struct MyButtonStyle: ButtonStyle{
        let maroon = Color(red: 0.8078, green: 0.1490, blue: 0.1098)
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .background(maroon)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

extension ContentView {
    private func login(){
        
        Auth0
            .webAuth()
            .start { result in
                
                switch result{
                    case .failure(let error):
                        // user pressed cancel or unusual activity
                        print("Failed with: \(error)")
                    case .success(let credentials):
                        self.isAuthenticated = true
                    self.userProfile = Profile.from(credentials.idToken)
                        print("Credentials \(credentials)")
                        print("ID token: \(credentials.idToken)")
                }
            }
    }
    private func logout(){
        Auth0
            .webAuth()
            .clearSession { result in
                switch result {
                case .failure(let error):
                    print("Failed with: \(error)")
                case .success:
                    self.isAuthenticated = false
                    self.userProfile = Profile.empty
                }
            }
        isAuthenticated = false
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
