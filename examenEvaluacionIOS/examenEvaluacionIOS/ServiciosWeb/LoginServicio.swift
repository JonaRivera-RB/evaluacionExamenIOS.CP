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
    
    func iniciarSesion(paraCorreo correo:String, paraContra contra:String, loginCompleta: @escaping
        (_ status:Bool, _ error:Error?) ->() ){
        
        Auth.auth().signIn(withEmail: correo, password: contra) { (usuario, error) in
            if error != nil {
                loginCompleta(false,error)
                return
            }
            loginCompleta(true,nil)
        }
    }
}
