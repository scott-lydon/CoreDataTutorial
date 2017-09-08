//
//  ViewController.swift
//  HitList
//
//  Created by Scott Lydon on 9/7/17.
//  Copyright © 2017 Scott Lydon. All rights reserved.
//
import CoreData
import UIKit

class ViewController: UIViewController {

    var people: [NSManagedObject] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        //you need a managedObjectContext to fetch too! (as well as save)
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //NSFetchRequest is Responsible for fetching from core data, can fetch sets of objects meeting different criteria. NSEntityDescription is an important qualifier.
        //NSFetchRequest with entity name
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        //NSFetchRequest is a generic so it requires a type parameter, we are using NSManagedObject as that type parameter. 
        
        do {
            //Returns an array of managedObjects meeting the requirements set by the fetch request.
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addName(_ sender: UIBarButtonItem) {
     
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            
        guard let textField = alert.textFields?.first,
            let nameToSave = textField.text else {
                print("Text field failed")
                return
            }
            
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        //Before saving or retrieving you must get a managedContext Object, you can consider a managed object context as a place for putting your managed objects.
        
        //2 commit the changes to disk
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //1 insert a managed Object into a managed object context. 
        //Entity Description links the entity definition from your data model with an instance of nsmanaged object at runtime.
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        //set the name attribute using kvc
        person.setValue(name, forKeyPath: "name")
        
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}






//MARK UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text =
            person.value(forKeyPath: "name") as? String
        return UITableViewCell()
    }
}
