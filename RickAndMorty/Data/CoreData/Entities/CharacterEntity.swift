//
//  CharacterEntity.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import CoreData

@objc(CharacterEntity)
public class CharacterEntity: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var status: String?
    @NSManaged public var species: String?
    @NSManaged public var type: String?
    @NSManaged public var gender: String?
    @NSManaged public var originName: String?
    @NSManaged public var originURL: String?
    @NSManaged public var locationName: String?
    @NSManaged public var locationURL: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var episodeURLsData: NSArray?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastUpdated: Date?

    var episodeURLs: [String]? {
        get { episodeURLsData as? [String] }
        set { episodeURLsData = newValue as NSArray? }
    }
}
