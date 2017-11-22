//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Anatoliy Chernyuk on 10/14/17.
//  Copyright © 2017 Anatoliy Chernyuk. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    //print("dateFormatter created")
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    //MARK: - Outlets
    @IBOutlet weak var describtionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    //MARK: - Variables
    var categoryName = "No Category"
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var date = Date()
    var descriptionText = ""
    var image: UIImage? {
        didSet {
            if let theImage = image {
                show(image: theImage)
            }
        }
    }
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var managedObjectContext: NSManagedObjectContext!
    var observer: Any!
    var placemark: CLPlacemark?
    
    //MARK: - View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    image = theImage
                    show(image: theImage) 
                }
            }
        }
        describtionTextView.text = descriptionText
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = format(date: date)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        listenForBackgroundNotification()
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 88
        case (1, _):
            return imageView.isHidden ? 44 : calculateRowHeight()
        case (2, 2):
            addressLabel.frame.size = CGSize(width: view.bounds.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.bounds.size.width - 15
            return addressLabel.bounds.size.height + 20
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            describtionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    //MARK: - Methods
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare { //House number
            text += s + " "
        }
        if let s = placemark.thoroughfare { //Street name
            text += s + ", "
        }
        if let s = placemark.locality { //City name
            text += s + ", "
        }
        if let s = placemark.administrativeArea { //Region name
            text += s + " "
        }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
    }
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        describtionTextView.resignFirstResponder()
    }
    
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.isHidden = true
    }
    
    func calculateRowHeight() -> CGFloat {
        let aspectRatio = image!.size.width / image!.size.height
        let height = 260 / aspectRatio
        imageView.frame.size.height = height
        return height + 20
    }
    
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) {
            [weak self] _ in
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismiss(animated: true, completion: nil)
                }
                strongSelf.describtionTextView.resignFirstResponder()
            }
        }
    }
    deinit {
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer)
    }
    
    //MARK: - Actions
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        let location: Location
        if let temp = locationToEdit {
            location = temp
            hudView.text = "Updated"
        } else {
            location = Location(context: managedObjectContext)
            hudView.text = "Taggged"
            location.photoID = nil
        }
        
        location.locationDescription = describtionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        do {
            try managedObjectContext.save()
            afterDelay(0.6) {
                self.dismiss(animated: true, completion: nil)
            }
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
}































