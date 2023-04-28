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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.string(from: session?.date ?? Date())
        navigationItem.title = "Exercices du " + date

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
        let alertController = UIAlertController(title: "New session exercise", message: "Enter exercise name", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Exercise name"
        })
        let addAction = UIAlertAction(title: "Add", style: .default, handler: { [self] (_) in
            guard let category = alertController.textFields?[0].text, !category.isEmpty else {
                return
            }
            // Check if the category already exists
            let fetchRequest: NSFetchRequest<ExerciseCategory> = ExerciseCategory.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", category)
            do {
                let results = try context.fetch(fetchRequest)
                if let existingCategory = results.first {
                    // Create new ExerciseType with existing ExerciseCategory
                    let newExerciseType = ExerciseType(context: context)
                    newExerciseType.category = existingCategory
                    session?.mutableSetValue(forKey: "exerciseTypes").add(newExerciseType)
                    try context.save()
                    exerciseTypes.insert(newExerciseType, at: 0)
                    exerciseTypeTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    sessionDelegate?.didUpdateSession(session!)
                } else {
                    // Create new ExerciseCategory and ExerciseType
                    let newCategory = ExerciseCategory(context: context)
                    newCategory.name = category
                    let newExerciseType = ExerciseType(context: context)
                    newExerciseType.category = newCategory
                    session?.mutableSetValue(forKey: "exerciseTypes").add(newExerciseType)
                    try context.save()
                    exerciseTypes.insert(newExerciseType, at: 0)
                    exerciseTypeTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    sessionDelegate?.didUpdateSession(session!)
                }
            } catch {
                print("Error fetching category: \(error)")
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

protocol SessionDetailsDelegate: AnyObject {
    func didUpdateSession(_ session: Session)
}

