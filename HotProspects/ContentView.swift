//
//  ContentView.swift
//  HotProspects
//
//  Created by Bruce Gilmour on 2021-08-09.
//

import SwiftUI
import UserNotifications
import SamplePackage

struct ContentView: View {
    var body: some View {
        DependencyTestView()
    }
}

struct DependencyTestView: View {
    let possibleNumbers = Array(1 ... 60)

    var results: String {
        let selected = possibleNumbers.random(7).sorted()
        let strings = selected.map(String.init)
        return strings.joined(separator: ", ")
    }

    var body: some View {
        Text(results)
    }
}

struct NotificationTestView: View {
    var body: some View {
        VStack {
            Button("Request Permission") {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }

            Button("Schedule Notification") {
                let content = UNMutableNotificationContent()
                content.title = "Feed the cat"
                content.subtitle = "It looks hungry"
                content.sound = UNNotificationSound.default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}

struct ContextMenuTestView: View {
    @State private var backgroundColor = Color.red

    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
                .background(backgroundColor)

            Text("Change Color")
                .padding()
                .contextMenu {
                    Button(action: {
                        backgroundColor = .red
                    }) {
                        Text("Red")
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    Button(action: {
                        backgroundColor = .green
                    }) {
                        Text("Green")
                    }
                    Button(action: {
                        backgroundColor = .blue
                    }) {
                        Text("Blue")
                    }
                }
        }
    }
}

struct InterpolationTest2View: View {
    var body: some View {
        Image("example")
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(height: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
    }
}

struct InterpolationTest1View: View {
    var body: some View {
        Image("example")
            .resizable()
            .scaledToFit()
            .frame(height: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
    }
}

struct AsyncTest1View: View {
    @ObservedObject var updater = DelayedUpdater()

    var body: some View {
        Text("Value is: \(updater.value)")
    }
}

class DelayedUpdater: ObservableObject {
    var value = 0 {
        willSet {
            objectWillChange.send()
        }
    }

    init() {
        for i in 1 ... 10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                self.value += 1
            }
        }
    }
}

enum NetworkError: Error {
    case badURL, requestFailed, unknown
}

struct ResultTest2View: View {
    var body: some View {
        Text("Hello, world!")
            .onAppear {
                fetchData(from: "https://www.apple.com") { result in
                    switch result {
                    case .success(let str):
                        print(str)
                    case .failure(let error):
                        switch error {
                        case .badURL:
                            print("Bad URL")
                        case .requestFailed:
                            print("Network problems")
                        case .unknown:
                            print("Unknown error")
                        }
                    }
                }
            }
    }

    func fetchData(from urlString: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let url = URL(string: "https://www.apple.com") else {
            completion(.failure(.badURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    let stringData = String(decoding: data, as: UTF8.self)
                    completion(.success(stringData))
                } else if error != nil {
                    completion(.failure(.requestFailed))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }.resume()
    }

    func fetchData3(from urlString: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        DispatchQueue.main.async {
            completion(.failure(.badURL))
        }
    }

    func fetchData2(from urlString: String, completion: (Result<String, NetworkError>) -> Void) {
        completion(.failure(.badURL))
    }

    func fetchData1(from urlString: String) -> Result<String, NetworkError> {
        .failure(.badURL)
    }
}

struct ResultTest1View: View {
    var body: some View {
        Text("Hello, world!")
            .onAppear {
                let url = URL(string: "https://www.apple.com")!
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if data != nil {
                        print("We got data!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }.resume()
            }
    }
}

struct TabsTest1View: View {
    var body: some View {
        TabView {
            Text("Tab 1")
                .tabItem {
                    Image(systemName: "star")
                    Text("One")
                }
            Text("Tab 2")
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Two")
                }
        }
    }
}

struct TabsTest2View: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Tab 1")
                .onTapGesture {
                    selectedTab = 1
                }
                .tabItem {
                    Image(systemName: "star")
                    Text("One")
                }
                .tag(0)

            Text("Tab 2")
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Two")
                }
                .tag(1)
        }
    }
}

class User: ObservableObject {
    @Published var name = "Taylor Swift"
}

struct EditView: View {
    @EnvironmentObject var user: User

    var body: some View {
        TextField("Name", text: $user.name)
    }
}

struct DisplayView: View {
    @EnvironmentObject var user: User

    var body: some View {
        Text(user.name)
    }
}

struct EnvObjectTest1View: View {
    var user = User()

    var body: some View {
        VStack {
            EditView().environmentObject(user)
            DisplayView().environmentObject(user)
        }
    }
}

struct EnvObjectTest2View: View {
    var user = User()

    var body: some View {
        VStack {
            EditView()
            DisplayView()
        }
        .environmentObject(user)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
