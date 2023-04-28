//
//  SessionDetailsController.swift
//  GymStats
//
//  Created by Lilyan Lefevre on 28/04/2023.
//

import UIKit
import CoreData

class ExerciseTypeDetailsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    weak var exerciseTypeDelegate: ExerciseTypeDetailsDelegate?

    @IBOutlet weak var exerciseSetTableView: UITableView!
    
    var exerciseType: ExerciseType?
    var exerciseSets: [ExerciseSet] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchExerciseSets()
        exerciseSetTableView.delegate = self
        exerciseSetTableView.dataSource = self
        exerciseSetTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExerciseSetItem")
    }

    func fetchExerciseSets() {
        if let exerciseSetsSet = exerciseType?.exerciseSets {
            exerciseSets = Array(exerciseSetsSet) as? [ExerciseSet] ?? []
        }
    }

    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseSets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseSetItem", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let exerciseSet = exerciseSets[indexPath.row]
        content.text = exerciseSet.reps.formatted() + " reps à " + exerciseSet.weight.formatted() + "kg"
        cell.contentConfiguration = content
        cell.selectionStyle = .none;
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let selectedIndexPath = exerciseSetTableView.indexPathForSelectedRow {
            exerciseSetTableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the object from Core Data
            let objectToDelete = exerciseSets[indexPath.row]
            context.delete(objectToDelete)
            
            // Save the changes
            do {
                try context.save()
                exerciseSets.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                exerciseTypeDelegate?.didUpdateExerciseType(exerciseType!)
            } catch {
                print("Error deleting object: \(error)")
            }
        }
    }

    func didUpdateExerciseType(_ exerciseSet: ExerciseSet) {
        // find the index of the updated session in the sessions array
        if let index = exerciseSets.firstIndex(of: exerciseSet) {
            // update the exercise type in the array
            exerciseSets[index] = exerciseSet
            // reload the table view data to reflect the changes
            exerciseSetTableView.reloadData()
        }
    }

    
    // MARK: - Actions
    
    @IBAction func createExerciseSet(_ sender: Any) {
        let alertController = UIAlertController(title: "New Exercise Set", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Reps"
            textField.keyboardType = .numberPad
        }

        alertController.addTextField { textField in
            textField.placeholder = "Weight"
            textField.keyboardType = .decimalPad
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            guard let repsText = alertController.textFields?.first?.text,
                  let weightText = alertController.textFields?.last?.text,
                  let reps = Int(repsText),
                  let weight = Double(weightText) else {
                // Handle error if values are not valid
                return
            }

            let exerciseSet = ExerciseSet(context: self.context)
            exerciseSet.reps = Int16(reps)
            exerciseSet.weight = weight
            exerciseSet.type = self.exerciseType
            self.exerciseType?.mutableSetValue(forKey: "exerciseSets").add(exerciseSet)

            do {
                try self.context.save()
                self.exerciseSets.insert(exerciseSet, at: 0)
                self.exerciseSetTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.exerciseTypeDelegate?.didUpdateExerciseType(self.exerciseType!)
            
            } catch {
                print("Error saving new ExerciseSet: \(error)")
            }
        }))

        present(alertController, animated: true, completion: nil)
    }

}

protocol ExerciseTypeDetailsDelegate: AnyObject {
    func didUpdateExerciseType(_ exerciseType: ExerciseType)
}


