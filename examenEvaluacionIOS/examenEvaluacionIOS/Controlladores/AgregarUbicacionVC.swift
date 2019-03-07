//
//  AgregarUbicacionVC.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/7/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseStorage

class AgregarUbicacionVC: UIViewController {

    
    
    @IBOutlet weak var mapa: MKMapView!
    
    @IBOutlet weak var nombreLbl: DetectarTextoTextField!
    @IBOutlet weak var domicilioLbl: DetectarTextoTextField!
    @IBOutlet weak var descripcionLbl: DetectarTextoTextField!
    
    var idUsuario = ""
    var bandera:Bool!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    func initUsuario(id:String, bandera:Bool)
    {
        idUsuario = id
        self.bandera = bandera
    }
    @IBAction func agregarDBBotonAccion(_ sender: Any) {
        
        let id = DB_BASE.childByAutoId().key
        
        let ubicacionUsuario = ["nombre":nombreLbl.text!,
                          "direccion":domicilioLbl.text!,
                          "descripcion":self.descripcionLbl.text!,
                          "latitud":"123123.232",
                          "longitud":"12321.232",
                          "id":id as! String,
                          "idUsuario": idUsuario] as [String : Any]
        print("estoy dentro\(idUsuario)")
        
        Servicios.instancia.crearUbicacion(uid: id!, datosUbicacion: ubicacionUsuario)
        dismiss(animated: true)
    }
    
    @IBAction func cerrarVistaBtnAction(_ sender: Any) {
        if bandera {
            mostrarAlerta(paraTitulo: "Ups", paraString: "Debes agregar tu primera ubicacion")
        }else {
            dismiss(animated: true, completion: nil)
        }
    }
    func mostrarAlerta(paraTitulo titulo: String,paraString string:String) {
        let alerta = UIAlertController(title: titulo, message: string, preferredStyle: .alert)
        let accion = UIAlertAction(title: "ok", style: .default, handler: nil)
        alerta.addAction(accion)
        present(alerta, animated: true, completion: nil)
    }
    
}
