//
//  ViewController.swift
//  ItemList
//
//  Created by Youssef Hilaly on 29/01/1401 AP.
//

import UIKit
import SQLite3

class ViewController: UITableViewController {
    var db:OpaquePointer?
    var dataSource = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAlertController))
        
        
        // Do any additional setup after loading the view.
         db = openDatabase()
        //showAlertController()
        //createTable(db: db)
        //insert(id: 1, name: "Ahmed", db: db)
        query(db: db!)
        //delete(db: db)
        //query(db: db!)
    }

    func openDatabase() -> OpaquePointer?{
        var db:OpaquePointer?
        
        let fileUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask,appropriateFor: nil,create: false).appendingPathComponent("Contact.sqlite")
        
        if(sqlite3_open(fileUrl?.path,&db) == SQLITE_OK){
            print("seccessfully opened connection to database")
            return db
        }else{
            print("unable to open database")
            return nil
        }
    }
    
    func createTable(db:OpaquePointer?){
        
        let createTableString = """
        CREATE TABLE Contact(Id INT PRIMARY KEY NOT NULL,
        Name CHAR(255))
"""
        var createTableStatment:OpaquePointer?
        
        if(sqlite3_prepare(db, createTableString, -1, &createTableStatment, nil) == SQLITE_OK){
            
            if(sqlite3_step(createTableStatment) == SQLITE_DONE){
                print("\nContact table not created")
            }else{
                print("\nContact table is not created")
            }
            
        }else{
            print("Create table statment in not prepared")
        }
        
        sqlite3_finalize(createTableStatment)
    }
    
    
    func insert(id:Int32,name:NSString,db:OpaquePointer?){
        let insertStatmentString = "INSERT INTO Contact (Id,Name) VALUES (?,?);"
        var insertStatment:OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatmentString, -1,&insertStatment, nil) == SQLITE_OK{
            sqlite3_bind_int(insertStatment, 1, id)
            sqlite3_bind_text(insertStatment, 2, name.utf8String, -1, nil)
            
            if sqlite3_step(insertStatment) == SQLITE_DONE{
                print("\nSuccessfully insert row")
            }else{
                showErrorMessage(message: "User with this ID already exists")
            }
        }else{
            print("insert statment in not prepared")
        }
        sqlite3_finalize(insertStatment)
    }
    
    func query(db: OpaquePointer?){
        let queryStatmentString = "SELECT * FROM Contact;"
        var queryStatment: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryStatmentString, -1, &queryStatment, nil) == SQLITE_OK{
            dataSource.removeAll()
            while sqlite3_step(queryStatment) == SQLITE_ROW{
                let id = sqlite3_column_int(queryStatment, 0)
                
                guard let queryResultClo1 = sqlite3_column_text(queryStatment, 1) else{
                    print("Query result in nil")
                    return
                }
                
                let name = String(cString: queryResultClo1)
                
                print("\nQuert Result")
                print("\(id) | \(name)")
                dataSource.append("\(id) | \(name)")
            }
            self.tableView.reloadData()
        }else{
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\nQuert is not prepared \(errorMessage)")
        }
        
        sqlite3_finalize(queryStatment)
    }
    
    func delete(db:OpaquePointer?) {
        let deleteStatementString = "DELETE FROM Contact WHERE Id = 1;"
        var deleteStatment : OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatment, nil) == SQLITE_OK{
            
            if sqlite3_step(deleteStatment) == SQLITE_DONE{
                print("\nSuccessfully deleted row")
            }else{
                print("\nCould not delet row")
            }
        }else{
            print("delete statment in not prepared")
        }
        sqlite3_finalize(deleteStatment)
        
    }
    
    @objc func showAlertController(){
        let ac = UIAlertController(title: "Enter content", message: nil, preferredStyle: .alert)
        ac.addTextField{ (tf) in
            tf.placeholder = "Enter id"
        }
        ac.addTextField{ (tf) in
            tf.placeholder = "Enter name"
        }

        let submitAction = UIAlertAction(title: "Submit", style: .default){ [weak self,weak ac] action in
            guard let id = ac?.textFields?[0].text else {return}
            guard let name = ac?.textFields?[1].text else {return}
            guard let idAsInt = Int32(id) else {return}
            
            self?.insert(id: idAsInt, name: name as NSString, db: self?.db)
            self?.query(db: self?.db)
            
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    func showErrorMessage(message: String){
        let ac = UIAlertController(title: "Erorr", message: message, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true,completion: nil)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell")
        cell?.textLabel?.text = dataSource[indexPath.row]
        return cell!
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

}

