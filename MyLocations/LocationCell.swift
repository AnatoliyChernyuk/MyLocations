//
//  LocationCell.swift
//  MyLocations
//
//  Created by Anatoliy Chernyuk on 11/9/17.
//  Copyright © 2017 Anatoliy Chernyuk. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    func configure(for location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        if let placemark = location.placemark {
            var text = ""
            text.add(text: placemark.subThoroughfare)
            text.add(text: placemark.thoroughfare, separatedBy: " ")
            text.add(text: placemark.locality, separatedBy: ", ")
            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
        photoImageView.image = thumbnail(for: location)
    }
    
    func thumbnail(for location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
            return image.resizedImage(withBounds: CGSize(width: 53, height: 52))
        }
        return UIImage()
    }
}


































