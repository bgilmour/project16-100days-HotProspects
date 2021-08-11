//
//  FileManager-extension.swift
//  HotProspects
//
//  Created by Bruce Gilmour on 2021-08-11.
//

import Foundation

extension FileManager {
    func getDocumentsDirectory() -> URL {
        let paths = self.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
