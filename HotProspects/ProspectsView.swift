//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Bruce Gilmour on 2021-08-09.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }

    enum SortedBy {
        case name, timestamp
    }

    let filter: FilterType

    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSortOptions = false
    @State private var sortedBy = SortedBy.name

    static let examples = [
        "Billie Eilish\nbillie@eilish.com",
        "Taylor Swift\ntaylor@swift.com",
        "Dua Lipa\ndua@lipa.com",
        "Lady Gaga\ngaga@monsters.com"
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(prospect.name)
                            contactedMarker(prospect)
                        }
                        .font(.headline)

                        Text(prospect.emailAddress)
                            .foregroundColor(.secondary)
                    }
                    .contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted") {
                            prospects.toggle(prospect)
                        }
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                addNotification(for: prospect)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(title)
            .navigationBarItems(
                leading: Button(action: {
                    isShowingSortOptions = true
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                },
                trailing: Button(action: {
                    isShowingScanner = true
                }) {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                }
            )
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: Self.examples[Int.random(in: 0 ..< Self.examples.count)], completion: handleScan)
            }
            .actionSheet(isPresented: $isShowingSortOptions) {
                ActionSheet(title: Text("Sort By"), buttons: [
                    .default(Text("Contact Name")) { sortedBy = .name },
                    .default(Text("Most Recent")) { sortedBy = .timestamp },
                    .cancel()
                ])
            }
        }
    }

    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }

    var filteredProspects: [Prospect] {
        let comparator: (Prospect, Prospect) -> Bool =
            sortedBy == .name
                ? { $0.name < $1.name }
                : { $0.timestamp > $1.timestamp }

        switch filter {
        case .none:
            return prospects.people.sorted(by: comparator)
        case .contacted:
            return prospects.people.filter { $0.isContacted }.sorted(by: comparator)
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }.sorted(by: comparator)
        }
    }

    func contactedMarker(_ prospect: Prospect) -> Image? {
        if filter == .none && prospect.isContacted {
            return Image(systemName: "envelope")
        }
        return nil
    }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]

            prospects.add(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact: \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.hour = 9
            // let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh!")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
