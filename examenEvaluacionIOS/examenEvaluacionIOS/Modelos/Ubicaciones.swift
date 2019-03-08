//
//  Ubicaciones.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/7/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import Foundation

struct Ubicaciones {
    private (set) var nombre:String
    private(set) var direccion:String
    private(set) var descripcion:String
    private(set) var latitud:Double
    private(set) var longitud:Double
    
    init(nombre:String,direccion:String,descripcion:String,latitud:Double,longitud:Double) {
        self.nombre = nombre
        self.direccion = direccion
        self.descripcion = descripcion
        self.latitud = latitud
        self.longitud = longitud
    }
}
