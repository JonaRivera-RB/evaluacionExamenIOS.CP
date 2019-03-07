//
//  Servicios.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/5/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference()

class Servicios {
    static let instancia = Servicios()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USUARIOS = DB_BASE.child("usuarios")
    private var _REF_UBICACIONES = DB_BASE.child("ubicaciones")
    
    var REF_BASE : DatabaseReference {
        return _REF_BASE
    }
    var REF_USUARIOS : DatabaseReference {
        return _REF_USUARIOS
    }
    var REF_UBICACIONES : DatabaseReference {
        return _REF_UBICACIONES
    }
    
    func crearUsuarioDB(uid:String, datosUsuario:Dictionary<String,Any>) {
        REF_USUARIOS.child(uid).updateChildValues(datosUsuario)
    }
    
}
