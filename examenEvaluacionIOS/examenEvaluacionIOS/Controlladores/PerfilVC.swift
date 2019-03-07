//
//  PerfilVC.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/6/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import  GoogleSignIn

class PerfilVC: UIViewController {

    @IBOutlet weak var miFoto: UIImageView!
    @IBOutlet weak var miCorreoLbl: UILabel!
    var handle:DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miFoto.layer.cornerRadius = self.miFoto.frame.size.width / 2
        miFoto.clipsToBounds = true
        let userID = Auth.auth().currentUser?.uid
        print("susurio ID"+userID!)
        Servicios.instancia.REF_BASE.child("usuarios").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let nombre = value?["nombre"] as? String
            let urlFoto = value?["foto"] as? String
            let user = MisDatos(nombre: nombre!, foto: urlFoto!)
            self.miCorreoLbl.text = user.nombre
            // self.meCorreoLbl.text = username
            if urlFoto?.isEmpty == false {
                Storage.storage().reference(forURL: urlFoto!).getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                    if let error = error?.localizedDescription {
                        print("error al traer imagen", error)
                        self.miFoto.image  = #imageLiteral(resourceName: "defaultProfileImage")
                    }
                    else { self.miFoto.image = UIImage(data: data!) }
                })
            }
            else {
                self.miFoto.image  = #imageLiteral(resourceName: "defaultProfileImage")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    @IBAction func cerrarSesionBtnAccion(_ sender: Any) {
        
        let alerta = UIAlertController(title: "Estas seguro?", message: "estas apunto de cerrar sesion", preferredStyle: .alert)
        let aceptarAccion = UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default) { (alerta) in
            try! Auth.auth().signOut()
            GIDSignIn.sharedInstance().signOut()
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVista")
            self.present(loginVC!, animated: true, completion: nil)
        }
        let cancelarAccion = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alerta.addAction(aceptarAccion)
        alerta.addAction(cancelarAccion)
        present(alerta, animated: true)
    }
    
}
