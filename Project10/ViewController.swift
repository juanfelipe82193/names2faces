//
//  ViewController.swift
//  Project10
//
//  Created by Juan Felipe Zorrilla Ocampo on 19/10/21.
//

import UIKit
import MobileCoreServices

class ViewController:
        UICollectionViewController,
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate,
        UICollectionViewDragDelegate,
        UICollectionViewDropDelegate {
    
    var people = [Person]() // Empty property to append Person classes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // "add" button placed on the top bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
        
    }
    // Method triggered by the "add" button
    @objc func addNewPerson() {
        // Create an UIAlertController actionSheet to retrieve user action if wants to import from Camera or Library
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    // Standard method for onSuccess Pick Media
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return } // Safely store the image
        // Defining a unique file name and created as a String
        let imageName = UUID().uuidString
        // Getting Documents Directory with custom method and adds one string `imageName` to the path and includes the path separator
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        // Safely unwrap jpegData conversion to a Data object and then try to save it onto the Documents Directory
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        // When picking success create a Person class instance without a name and pass the selected image
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        } else {
            let alert = UIAlertController(title: "Warning", message: "Camera it's not enabled", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true)
        } else {
            let alert = UIAlertController(title: "Warning", message: "You don't have permission to access gallery", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Custom method to get Documents Directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    // How many items in the UICollectionView are we going to display
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    // What will be the content for each of the items in UICollectionView
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Try to dequeue a Cell but only as PersonCell class, If not we make the app crash
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            // we failed to get a PersonCell
            fatalError("Unable to dequeue PersonCell.")
        }
        // Display each item based on the people property array which contains Person classes
        let person = people[indexPath.item]
        cell.name.text = person.name // Give the Collection item the same name as the Person name
        // Concatenate the path of the Documents Directory with the name of the image file
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path) // Assign the Collection view item image property
        // Modify estetics of the Collection view items
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.layer.cornerRadius = 7
        
        return cell
    }
    // What should happen when any item is selected?
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        // Create an UIAlertController actionSheet to ask for User Action for Rename or Delete
        let ac = UIAlertController(title: "Choose an action", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Rename...", style: .default) { [weak self] action in
            let secondAC = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
            secondAC.addTextField()
            secondAC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            secondAC.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak secondAC] action in
                guard let newName = secondAC?.textFields?[0].text else { return }
                person.name = newName
            
                self?.collectionView.reloadData()
            })
            self?.present(secondAC, animated: true)
        })
        ac.addAction(UIAlertAction(title: "Delete...", style: .destructive) { [weak self] action in
            self?.people.remove(at: indexPath.row)
            collectionView.deleteItems(at: [IndexPath(row: indexPath.row, section: indexPath.section)])
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = people[indexPath.row]
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeData as String])
    }
        
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: Person.self) { items in
            guard let strings = items as? [String] else { return }
            var indexPaths = [IndexPath]()
            for (index, string) in strings.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                print(string)
                indexPaths.append(indexPath)
            }
            collectionView.insertItems(at: indexPaths)
        }
    }
    
}

