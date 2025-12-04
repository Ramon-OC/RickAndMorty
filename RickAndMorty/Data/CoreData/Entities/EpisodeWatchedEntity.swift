//
//  EpisodeWatchedEntity.swift
//  RickAndMorty
//

import CoreData

@objc(EpisodeWatchedEntity)
public class EpisodeWatchedEntity: NSManagedObject {
    @NSManaged public var episodeId: Int64
    @NSManaged public var watchedDate: Date?
}
