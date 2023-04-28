//
//  SessionDetailsController.swift
//  GymStats
//
//  Created by Lilyan Lefevre on 28/04/2023.
//

import UIKit
import CoreData

class SessionDetailsController: UIViewController, UITableViewDataSource, UITableViewDelegate, ExerciseTypeDetailsDelegate {
    weak var sessionDelegate: SessionDetailsDelegate?

    @IBOutlet weak var exerciseTypeTableView: UITableView!
    
    var session: Session?
    var exerciseTypes: [ExerciseType] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchExerciseTypes()
        exerciseTypeTableView.delegate = self
        exerciseTypeTableView.dataSource = self
        exerciseTypeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExerciseTypeItem")
    }

    func fetchExerciseTypes() {
        if let exerciseTypesSet = session?.exerciseTypes {
            exerciseTypes = Array(exerciseTypesSet) as? [ExerciseType] ?? []
        }
    }

    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseTypeItem", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let exerciseType = exerciseTypes[indexPath.row]
        content.text = exerciseType.category?.name ?? "Sans nom"
        content.secondaryText = (exerciseType.exerciseSets?.count.formatted() ?? "0") + " série(s)"
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ExerciseTypeDetailsSegue", sender: exerciseTypes[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExerciseTypeDetailsSegue" {
            if let exerciseType = sender as? ExerciseType,
               let destinationVC = segue.destination as? ExerciseTypeDetailsController {
                destinationVC.exerciseType = exerciseType
                destinationVC.exerciseTypeDelegate = self
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let selectedIndexPath = exerciseTypeTableView.indexPathForSelectedRow {
            exerciseTypeTableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the object from Core Data
            let objectToDelete = exerciseTypes[indexPath.row]
            context.delete(objectToDelete)
            
            // Save the changes
            do {
                try context.save()
                exerciseTypes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                sessionDelegate?.didUpdateSession(session!)
            } catch {
                print("Error deleting object: \(error)")
            }
        }
    }

    func didUpdateExerciseType(_ exerciseType: ExerciseType) {
        // find the index of the updated session in the sessions array
        if let index = exerciseTypes.firstIndex(of: exerciseType) {
            // update the exercise type in the array
            exerciseTypes[index] = exerciseType
            // reload the table view data to reflect the changes
            exerciseTypeTableView.reloadData()
        }
    }

    
    // MARK: - Actions
    
    @IBAction func createExerciseType(_ sender: Any) {
        let newCategory = ExerciseCategory(context: context)
        newCategory.name = "Generic Category"
        let newExerciseType = ExerciseType(context: context)
        newExerciseType.category = newCategory
        let newExerciseSet = ExerciseSet(context: context)
        newExerciseSet.weight = 10
        newExerciseSet.reps = 10
        newExerciseSet.type = newExerciseType
        session?.mutableSetValue(forKey: "exerciseTypes").add(newExerciseType)
        newExerciseType.mutableSetValue(forKey: "exerciseSets").add(newExerciseSet)
    
        do {
            try context.save()
            exerciseTypes.insert(newExerciseType, at: 0)
            exerciseTypeTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            sessionDelegate?.didUpdateSession(session!)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

protocol SessionDetailsDelegate: AnyObject {
    func didUpdateSession(_ session: Session)
}


