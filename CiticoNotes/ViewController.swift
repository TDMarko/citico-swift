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
    @IBOutlet weak var cellText: UILabel! //TODO: not linked, fix me or delete
    
    struct Note {
        var date: Date
        var note: String
        var isPrivate: Bool
    }
    
    var notes = [Int: Note]()
    
    override func viewWillAppear(_ animated: Bool) {
        self.getNotes()
        
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

        tableView.delegate = self
        tableView.dataSource = self
        
        self.getNotes()
    }

    func getNotes() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        
        print("we are here")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            var i = 0
            print(result)
           // if (result.isEmpty) {
                notes.removeAll()
           // }
            
            for data in result as! [NSManagedObject] {
                notes[i] = Note(date: data.value(forKey: "date") as! Date, note:  data.value(forKey: "note") as! String, isPrivate:  (data.value(forKey: "isPrivate") as! Bool))
                
                i = i + 1 //TODO: fix me
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
        let dateString = dateFormatter.string(from: notes[indexPath.row]?.date as! Date)
        
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
        addNoteController.note = notes[indexPath.row]?.note
        addNoteController.noteIndex = indexPath.row
        
        if (notes[indexPath.row]?.isPrivate)! {
            self.authenticateUser()
        } else {
            self.present(addNoteController, animated: true, completion: nil)
        }
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addNoteController = mainStoryboard.instantiateViewController(withIdentifier: "addNoteViewController")
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "This note ir private!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self.present(addNoteController, animated: true, completion: nil)
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "Sorry!", preferredStyle: .alert)
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

