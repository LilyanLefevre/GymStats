//
//  Exercise+CoreDataProperties.swift
//  GymStats
//
//  Created by Lilyan Lefevre on 28/04/2023.
//
//

import Foundation
import CoreData


extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "ExerciseSet")
    }

    @NSManaged public var reps: Int16
    @NSManaged public var weight: Double
    @NSManaged public var type: ExerciseType?

}

extension Exercise : Identifiable {

}
