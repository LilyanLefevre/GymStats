//
//  Session+CoreDataProperties.swift
//  GymStats
//
//  Created by Lilyan Lefevre on 28/04/2023.
//
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var date: Date?
    @NSManaged public var exerciseTypes: NSSet?

}

// MARK: Generated accessors for exerciseTypes
extension Session {

    @objc(addExerciseTypesObject:)
    @NSManaged public func addToExerciseTypes(_ value: ExerciseType)

    @objc(removeExerciseTypesObject:)
    @NSManaged public func removeFromExerciseTypes(_ value: ExerciseType)

    @objc(addExerciseTypes:)
    @NSManaged public func addToExerciseTypes(_ values: NSSet)

    @objc(removeExerciseTypes:)
    @NSManaged public func removeFromExerciseTypes(_ values: NSSet)

}

extension Session : Identifiable {

}
