//
//  SoltarPin.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/7/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit
import MapKit

class SoltarPin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier:String)
    {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
    
}
