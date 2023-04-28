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
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let selectedIndexPath = exerciseSetTableView.indexPathForSelectedRow {
            exerciseSetTableView.deselectRow(at: selectedIndexPath, animated: true)
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
        let newExerciseSet = ExerciseSet(context: context)
        newExerciseSet.weight = 10
        newExerciseSet.reps = 10
        newExerciseSet.type = exerciseType
        exerciseType?.mutableSetValue(forKey: "exerciseSets").add(newExerciseSet)
    
        do {
            try context.save()
            exerciseSets.insert(newExerciseSet, at: 0)
            exerciseSetTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            exerciseTypeDelegate?.didUpdateExerciseType(exerciseType!)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

protocol ExerciseTypeDetailsDelegate: AnyObject {
    func didUpdateExerciseType(_ exerciseType: ExerciseType)
}


