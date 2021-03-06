//
//  Place.swift
//  A1_A2_iOS_ Sabin_C0856358
//
//  Created by Sabin Regmi on 24/05/2022.
//


import Foundation
import MapKit

class Place: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
}

