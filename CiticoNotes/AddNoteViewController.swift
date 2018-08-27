//
//  AddNoteViewController.swift
//  CiticoNotes
//
//  Created by Marks Timofejevs on 24/08/2018.
//  Copyright © 2018 Marks Timofejevs. All rights reserved.
//

import UIKit
import CoreData

class AddNoteViewController: UIViewController {
    
    var isSwitchNotePrivate = false
    
    var note: String? = ""
    var noteIndex: Int? = 0
    var isViewMode: Bool = false

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewPrivateNote: UIView!
    @IBOutlet weak var viewButton: UIView!
    @IBOutlet weak var buttonCloseAddNote: UIButton!
    @IBOutlet weak var buttonAddNote: UIButton!
    @IBOutlet weak var inputNoteContent: UITextView!
    @IBOutlet weak var switchIsPrivate: UISwitch!
    
    @IBAction func actionCloseAddNote(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAddNote(_ sender: Any) { //TODO: rename me
        if (isViewMode) {
            self.deleteNote()
        } else {
            self.saveNote()
        }
    }
    
    @IBAction func actionSwitchIsPrivate(_ sender: Any) {
        isSwitchNotePrivate = switchIsPrivate.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        if !(self.note!).isEmpty {
            self.inputNoteContent.text = note
            
            viewButton.backgroundColor = UIColor.red
            viewPrivateNote.isHidden = true
            isViewMode = true
            inputNoteContent.isEditable = false
            labelTitle.text = "Your note"
            buttonAddNote.setTitle("DELETE NOTE", for: .normal)
        }
    }
    
    func saveNote() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //TODO: reusable
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Notes", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        
        newUser.setValue(Date(), forKey: "date")
        newUser.setValue(inputNoteContent?.text, forKey: "note")
        newUser.setValue(isSwitchNotePrivate, forKey: "isPrivate")
        
        do {
            try context.save()
            
            self.dismiss(animated: true, completion: nil)

            print("Note saved")
        } catch {
            print("Failed saving note")
        }
    }
    
    func deleteNote() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //TODO: reusable
        let context = appDelegate.persistentContainer.viewContext
        let requestDel = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        requestDel.returnsObjectsAsFaults = false
        
        let predicateDel = NSPredicate(format: "note contains[c] %@", note!) //TODO: delete by ID, this is stupid
        requestDel.predicate = predicateDel
        
        do {
            let arrUsrObj = try context.fetch(requestDel)
            for usrObj in arrUsrObj as! [NSManagedObject] {
                context.delete(usrObj)
            }
            print("\(note) is deleted")
        } catch {
            print("Failed")
        }
        
        do {
            try context.save()
            
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("Failed saving note")
        }
        
        // DELETE ALL ITEMS IN CORE DATA, SAVED FOR LATER
        /*let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext //TODO: reusable
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            
            self.dismiss(animated: true, completion: nil)
            
            print("All notes deleted")
        } catch {
            print ("TFailed deleting note")
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
