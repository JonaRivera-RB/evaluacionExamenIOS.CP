//
//  LugaresCerca.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/7/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import Foundation

struct LugaresCerca {
    private(set) public var nombre: String
    private(set) public var direccion: String
    private(set) public var valoracion: Float
    
    init(nombre: String, direccion: String,valoracion:Float) {
        self.nombre = nombre
        self.direccion = direccion
        self.valoracion = valoracion
    }
}
