//
//  ViewController.swift
//  GymStats
//
//  Created by Lilyan Lefevre on 28/04/2023.
//

import UIKit
import CoreData

class SessionOverviewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SessionDetailsDelegate {

    @IBOutlet weak var recordsButton: UIButton!
    @IBOutlet weak var trendingsButton: UIButton!
    @IBOutlet weak var sessionTableView: UITableView!
    @IBOutlet weak var newSessionButton: UIButton!
    
    var sessions: [Session] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSessions()
        sessionTableView.delegate = self
        sessionTableView.dataSource = self
        sessionTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SessionItem")
    }

    func fetchSessions() {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        do {
            sessions = try context.fetch(request)
            sessionTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionItem", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let session = sessions[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.string(from: session.date ?? Date())
        content.text = "Session du " + date
        content.secondaryText = (session.exerciseTypes?.count.formatted() ?? "0") + " exercice(s)"
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SessionDetailsSegue", sender: sessions[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SessionDetailsSegue" {
            if let session = sender as? Session,
               let destinationVC = segue.destination as? SessionDetailsController {
                destinationVC.session = session
                destinationVC.sessionDelegate = self
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let selectedIndexPath = sessionTableView.indexPathForSelectedRow {
            sessionTableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    func didUpdateSession(_ session: Session) {
        // find the index of the updated session in the sessions array
        if let index = sessions.firstIndex(of: session) {
            // update the session in the array
            sessions[index] = session
            // reload the table view data to reflect the changes
            sessionTableView.reloadData()
        }
    }

    
    // MARK: - Actions
    
    @IBAction func createSession(_ sender: Any) {
        let newSession = Session(context: context)
        newSession.date = Date()
        do {
            try context.save()
            sessions.insert(newSession, at: 0)
            sessionTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

