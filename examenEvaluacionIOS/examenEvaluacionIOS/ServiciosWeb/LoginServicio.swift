//
//  LoginServicio.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/5/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth


class LoginServicio {
    static let instancia = LoginServicio()
    /*
    func registrarUsuario(paraCorreo correo:String, paraContra contra:String,imagen:UIImage, creacionUsuarioCompleta: @escaping
        (_ status:Bool, _ error:Error?) ->() ) {
        
        Auth.auth().createUser(withEmail: correo, password: contra) { (usuario, error) in
            guard let usuario = usuario else {
                creacionUsuarioCompleta(false, error)
                return
            }
            let storage = Storage.storage().reference()
            let nombreImagen = UUID()
            let directorio = storage.child("imagenesUsuarios/\(nombreImagen)")
            let metaDatos = StorageMetadata()
            metaDatos.contentType = "image/png"
            directorio.putData(imagen.pngData()!, metadata: metaDatos, completion: { (data, error) in
                if error == nil
                {
                    print("cargo la imagen")
                    self.iniciarSesion(paraCorreo: correo, paraContra: contra, creacionUsuarioCompleta: { (success, nil) in
                        let inicioVC = UIStoryboard?.instantiateViewController(withIdentifier: "inicioVC")
                        //inicioVC
                        self.present(inicioVC!, animated: true, completion: nil)
                        print("registrado exitosamente")
                    })
                }
                else
                {
                    if let error = error?.localizedDescription {
                        print("error de firebase",error)
                    }
                    else {
                        print("error de codigo")
                    }
                }
            })
            
            let datosUsuario = ["provider": usuario.user.providerID, "email": usuario.user.email]
            Servicios.instancia.crearUsuarioDB(uid: usuario.user.uid, datosUsuario: datosUsuario)
            
            creacionUsuarioCompleta(true,nil)
        }
        
    }
    */
    
    func iniciarSesion(paraCorreo correo:String, paraContra contra:String, creacionUsuarioCompleta: @escaping
        (_ status:Bool, _ error:Error?) ->() ){
        
        Auth.auth().signIn(withEmail: correo, password: contra) { (usuario, error) in
            if error != nil {
                creacionUsuarioCompleta(false,error)
                return
            }
            creacionUsuarioCompleta(true,nil)
        }
    }
}
