//
//  ExerciseType+CoreDataProperties.swift
//  GymStats
//
//  Created by Lilyan Lefevre on 28/04/2023.
//
//

import Foundation
import CoreData


extension ExerciseType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseType> {
        return NSFetchRequest<ExerciseType>(entityName: "ExerciseType")
    }

    @NSManaged public var name: String?
    @NSManaged public var exerciseSets: NSSet?
    @NSManaged public var session: Session?

}

// MARK: Generated accessors for exerciseSets
extension ExerciseType {

    @objc(addExerciseSetsObject:)
    @NSManaged public func addToExerciseSets(_ value: Exercise)

    @objc(removeExerciseSetsObject:)
    @NSManaged public func removeFromExerciseSets(_ value: Exercise)

    @objc(addExerciseSets:)
    @NSManaged public func addToExerciseSets(_ values: NSSet)

    @objc(removeExerciseSets:)
    @NSManaged public func removeFromExerciseSets(_ values: NSSet)

}

extension ExerciseType : Identifiable {

}
