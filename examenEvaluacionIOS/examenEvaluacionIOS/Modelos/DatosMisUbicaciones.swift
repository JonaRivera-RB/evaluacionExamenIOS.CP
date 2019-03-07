//
//  DatosMisUbicaciones.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/7/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//
//eliminar
import Foundation
struct DatosMisUbicaciones {
    private(set) public var nombreLugar:String
    private(set) public var descripcionLugar:String
    private(set) public var domicilioLugar:String
    
    init(nombreLugar:String,descripcionLugar:String,domicilioLugar:String)
    {
        self.nombreLugar = nombreLugar
        self.descripcionLugar = descripcionLugar
        self.domicilioLugar = domicilioLugar
    }
}
