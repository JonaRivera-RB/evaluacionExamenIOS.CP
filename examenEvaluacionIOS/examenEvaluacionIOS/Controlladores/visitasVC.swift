//
//  visitasVC.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/6/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import  GoogleSignIn

class visitasVC: UIViewController  {


    @IBOutlet weak var tablaUbicaciones:UITableView!
    
    
    var listaUbicaciones = [Ubicaciones]()
    
    var userID:Any?
    var bandera:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = Auth.auth().currentUser?.uid
        
        tablaUbicaciones.delegate = self
        tablaUbicaciones.dataSource = self
        
       // traerUbicaciones()
    }
    override func viewDidAppear(_ animated: Bool) {
        bandera = false
        traerUbicaciones()
    }
    func traerUbicaciones()
    {
        Servicios.instancia.REF_UBICACIONES.observe(DataEventType.value) { (snapshot) in
            self.listaUbicaciones.removeAll()
            for item in snapshot.children.allObjects as! [DataSnapshot]
            {
                if let valores = item.value as? [String:AnyObject]
                {
                    let nombre = valores["nombre"] as! String
                    let direccion = valores["direccion"] as! String
                    let descripcion = valores["descripcion"] as! String
                    let latitud = valores["latitud"] as! Double
                    let longitud = valores["longitud"] as! Double
                    let idUsuario = valores["idUsuario"] as! String
                    let id = valores["id"] as! String
                    
                    
                    // let valoracion = valores["valoracion"] as! String
                    if self.userID != nil {
                        if idUsuario == self.userID as! String {
                            let ubicaciones = Ubicaciones(nombre: nombre, direccion: direccion, descripcion: descripcion, latitud: latitud, longitud: longitud, id: id)
                            self.listaUbicaciones.append(ubicaciones)
                        }
                    }
                   
            }
                print(self.listaUbicaciones.count)
        }
            self.tablaUbicaciones.reloadData()
            
            if(self.listaUbicaciones.isEmpty){
                self.bandera = true
                if self.userID != nil {
                    self.performSegue(withIdentifier: "addvisita", sender: self)
                }
            }
        }
    }
    func mostrarAlerta(paraTitulo titulo: String,paraString string:String) {
        let alerta = UIAlertController(title: titulo, message: string, preferredStyle: .alert)
        let accion = UIAlertAction(title: "ok", style: .default, handler: nil)
        alerta.addAction(accion)
        present(alerta, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let agregarVisitasVC = segue.destination as? AgregarUbicacionVC {
            agregarVisitasVC.initUsuario(id: userID as! String, bandera: bandera)
        }
        else if let informacionVC = segue.destination as? InformacionUbicacion {
                assert(sender as? Ubicaciones != nil)
                informacionVC.initCordenads(ubicacion: sender as! Ubicaciones)
            }
        else if let editarVC = segue.destination as? EditarUbicacionVC {
            assert(sender as? Ubicaciones != nil)
            editarVC.initDatos(ubicacion: sender as! Ubicaciones)
        }
    }
    
    @IBAction func agregarUbicacionBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "addvisita", sender: self)
    }
    
    
}

extension visitasVC :  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaUbicaciones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tablaUbicaciones.dequeueReusableCell(withIdentifier: "cellUbicaciones") as? MisUbicacionesCell
        let ubicacion = listaUbicaciones[indexPath.row]
        cell?.actualizarVista(datosUbicaciones: ubicacion)
        return cell!
}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let lugar = listaUbicaciones[indexPath.row]
        performSegue(withIdentifier: "informacionVC", sender: lugar)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let actualizar = UITableViewRowAction(style: .normal, title: "Actualizar") { (rowAction, indexPath) in
            let ubicacion = self.listaUbicaciones[indexPath.row]
            self.performSegue(withIdentifier: "editarVC", sender: ubicacion)
        }
        actualizar.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        
        let borrar = UITableViewRowAction(style: .destructive, title: "Eliminar") { (rowAction, indexPath) in
            print("vamos actualizar los datos")
            
            let index = indexPath.row
            print(self.listaUbicaciones.count)
            if self.listaUbicaciones.count == 1 {
                self.mostrarAlerta(paraTitulo: "Error", paraString: "No puedes eliminar el ultimo registro!")
            }else {
                let alerta = UIAlertController(title: "Estas seguro?", message: "Quieres eliminar esta ubicación?", preferredStyle: .alert)
                let acccionCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                let accion = UIAlertAction(title: "Si", style: .default) { (UIAlertAction) in
                    
                    let ubcacion = self.listaUbicaciones[index]
                    
                    Servicios.instancia.REF_UBICACIONES.child(ubcacion.id).removeValue { (error, ref) in
                        if error != nil {
                            print("fallo la eliminacion",error!)
                            return
                        }
                        // self.listaUbicaciones.remove(at: index)
                    }
                }
                
                alerta.addAction(acccionCancelar)
                alerta.addAction(accion)
                self.present(alerta, animated: true, completion: nil)
            }
        }
        
        borrar.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        
        return[actualizar,borrar]
    }
    
}


