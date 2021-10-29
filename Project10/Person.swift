//
//  Person.swift
//  Project10
//
//  Created by Juan Felipe Zorrilla Ocampo on 21/10/21.
//

import UIKit
import MobileCoreServices

final class Person: NSObject, NSItemProviderWriting, NSItemProviderReading, Codable {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData as String)]
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData as String)]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 100)
        do {
            let data = try JSONEncoder().encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        return progress
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Person {
        do {
            let subject = try JSONDecoder().decode(Person.self, from: data)
            return subject
        } catch {
            fatalError("\(error.localizedDescription)")
        }
    }
    
}
