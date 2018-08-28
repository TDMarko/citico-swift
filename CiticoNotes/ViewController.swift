//
//  ViewController.swift
//  CiticoNotes
//
//  Created by Marks Timofejevs on 23/08/2018.
//  Copyright © 2018 Marks Timofejevs. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    struct Note {
        var noteId: Int
        var date: Date
        var note: String
        var isPrivate: Bool
    }
    
    var notes = [Int: Note]()
    
    override func viewWillAppear(_ animated: Bool) {
        self.getNotes()
        
        // Show bottom layer view if there is no notes
        if (notes.count == 0) {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            tableView.tableFooterView = UIView()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate to UITableView for table actions
        tableView.delegate = self
        tableView.dataSource = self
        
        self.getNotes()
    }

    // Get all notes from CoreData entity
    func getNotes() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            var i = 0

            notes.removeAll()
            
            for data in result as! [NSManagedObject] {
                // TODO: add sorting
                notes[i] = Note(
                    noteId: data.value(forKey: "noteId") as! Int,
                    date: data.value(forKey: "date") as! Date,
                    note:  data.value(forKey: "note") as! String,
                    isPrivate:  (data.value(forKey: "isPrivate") as! Bool)
                )
                
                i += 1
            }
        } catch {
            print("Failed")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell")!
        var text = ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: notes[indexPath.row]!.date)
        
        // Hide private note message
        if (notes[indexPath.row]?.isPrivate)! {
            text = "Note is private! Tap to view!"
            cell.textLabel?.textColor = UIColor.lightGray
        } else {
            text = (notes[indexPath.row]?.note)!
        }
        
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = dateString
        cell.detailTextLabel?.textColor = UIColor.lightGray

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addNoteController = mainStoryboard.instantiateViewController(withIdentifier: "addNoteViewController") as! AddNoteViewController
        
        addNoteController.noteId = notes[indexPath.row]?.noteId
        addNoteController.note = notes[indexPath.row]?.note
        
        // Private note requires user to access with TouchId
        if (notes[indexPath.row]?.isPrivate)! {
            self.authenticateUser(indexPath: indexPath.row)
        } else {
            self.present(addNoteController, animated: true, completion: nil)
        }
    }
    
    func authenticateUser(indexPath: Int) {
        let context = LAContext()
        var error: NSError?
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addNoteController = mainStoryboard.instantiateViewController(withIdentifier: "addNoteViewController") as! AddNoteViewController
        
        addNoteController.noteId = notes[indexPath]?.noteId
        addNoteController.note = notes[indexPath]?.note
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "This note ir private!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self.present(addNoteController, animated: true, completion: nil)
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You shall not pass!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID. Probably I sould ask for phone code here..", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
