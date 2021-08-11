//
//  Prospect.swift
//  HotProspects
//
//  Created by Bruce Gilmour on 2021-08-09.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    var timestamp = Date()
    fileprivate(set) var isContacted = false
}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]

    static let saveKey = "SavedData"

    init() {
        let filename = FileManager.default.getDocumentsDirectory().appendingPathComponent(Self.saveKey)

        do {
            let data = try Data(contentsOf: filename)
            people = try JSONDecoder().decode([Prospect].self, from: data)
        } catch {
            print("Unable to load saved data: \(error.localizedDescription)")
            people = []
        }
    }

    private func save() {
        let filename = FileManager.default.getDocumentsDirectory().appendingPathComponent(Self.saveKey)
        do {
            let data = try JSONEncoder().encode(people)
            try data.write(to: filename, options: [.atomicWrite])
        } catch {
            print("Unable to save data: \(error.localizedDescription)")
        }
    }

    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }

    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}
