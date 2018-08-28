//
//  AddNoteViewController.swift
//  CiticoNotes
//
//  Created by Marks Timofejevs on 24/08/2018.
//  Copyright © 2018 Marks Timofejevs. All rights reserved.
//

import UIKit
import CoreData

class AddNoteViewController: UIViewController, UITextViewDelegate {
    
    var isSwitchNotePrivate = false
    
    var note: String? = ""
    var noteId: Int? = 0
    var isViewMode: Bool = false

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewPrivateNote: UIView!
    @IBOutlet weak var viewButton: UIView!
    @IBOutlet weak var buttonCloseAddNote: UIButton!
    @IBOutlet weak var buttonAddNote: UIButton!
    @IBOutlet weak var inputNoteContent: UITextView!
    @IBOutlet weak var switchIsPrivate: UISwitch!
    @IBOutlet weak var buttonDeleteNote: UIButton!
    
    @IBAction func actionCloseAddNote(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAddNote(_ sender: Any) {
        // Show alert if user haven't entered a note
        if (inputNoteContent.text.count == 0) {
            self.presentAlert()
            
            return
        }
        
        // Detect if it's new note or existing one
        if (isViewMode) {
            self.updateNote()
        } else {
            self.saveNote()
        }
    }
    
    @IBAction func actionSwitchIsPrivate(_ sender: Any) {
        isSwitchNotePrivate = switchIsPrivate.isOn
    }
    
    @IBAction func actionDeleteNote(_ sender: Any) {
        self.deleteNote()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handling tap outside keyboard and text view to hide keyboard
        self.hideKeyboardWhenTappedAround()
        
        inputNoteContent.delegate = self
        
        // Updating and deleting existing note
        if !(self.note!).isEmpty {
            self.inputNoteContent.text = note
            
            viewButton.backgroundColor = UIColor.lightGray
            viewPrivateNote.isHidden = true
            buttonDeleteNote.isHidden = false
            isViewMode = true
            labelTitle.text = "Your note"
            buttonAddNote.setTitle("UPDATE NOTE", for: .normal)
        }
    }
    
    func saveNote() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //TODO: reusable
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Notes", in: context)
        let newNote = NSManagedObject(entity: entity!, insertInto: context)
        
        // Added new func to make auto increament noteId field
        // TODO: standart Core Data objectId can be used here
        newNote.setValue(AddNoteViewController.nextAvailble("noteId", forEntityName: "Notes", inContext: context), forKey: "noteId")
        newNote.setValue(Date(), forKey: "date")
        newNote.setValue(inputNoteContent?.text, forKey: "note")
        newNote.setValue(isSwitchNotePrivate, forKey: "isPrivate")
        
        do {
            try context.save()
            
            self.dismiss(animated: true, completion: nil)

            print("Note saved")
        } catch {
            print("Failed saving note")
        }
    }
    
    func updateNote() {
        print("update")
    }
    
    func deleteNote() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //TODO: reusable
        let context = appDelegate.persistentContainer.viewContext
        let requestDel = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        requestDel.returnsObjectsAsFaults = false
        
        // Deleting note by it's noteId
        // TODO: standart Core Data objectId can be used here
        let predicateDel = NSPredicate(format: "noteId = %d", noteId!)
        requestDel.predicate = predicateDel
        
        do {
            let arrUsrObj = try context.fetch(requestDel)
            for usrObj in arrUsrObj as! [NSManagedObject] {
                context.delete(usrObj)
            }
            print("\(String(describing: note)) is deleted")
        } catch {
            print("Failed")
        }
        
        do {
            try context.save()
            
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("Failed saving note")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewButton.backgroundColor = UIColor(rgb: 0x8ECC32)
    }

    func presentAlert() {
        let alert = UIAlertController(title: "Alert", message: "Please enter note text!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Func to make auto increament noteId field
    static func nextAvailble(_ idKey: String, forEntityName entityName: String, inContext context: NSManagedObjectContext) -> Int {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.propertiesToFetch = [idKey]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: idKey, ascending: true)]
        
        do {
            let results = try context.fetch(fetchRequest)
            let lastObject = (results as! [NSManagedObject]).last
            
            guard lastObject != nil else {
                return 1
            }
            
            return lastObject?.value(forKey: idKey) as! Int + 1
            
        } catch _ as NSError {
            print("Auto increament error with \(idKey)")
        }
        
        return 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

