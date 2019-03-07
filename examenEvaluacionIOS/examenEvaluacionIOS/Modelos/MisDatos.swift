//
//  MisDatos.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/6/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import Foundation
struct MisDatos {
    private (set) var nombre:String
    private(set) var foto:String
    
    init(nombre:String,foto:String) {
        self.nombre = nombre
        self.foto = foto
    }
}
