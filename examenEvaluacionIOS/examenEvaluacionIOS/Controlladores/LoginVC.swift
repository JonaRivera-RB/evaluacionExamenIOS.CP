//
//  ViewController.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/5/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class LoginVC: UIViewController, UIGestureRecognizerDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("hello")
    }
    
    
    @IBOutlet weak var correoTxt: DetectarTextoTextField!
    @IBOutlet weak var contraTxt: DetectarTextoTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        ocultarTeclado()
        
    }
    func ocultarTeclado() {
        self.view.isUserInteractionEnabled = true
        let toque = UITapGestureRecognizer(target: self, action: #selector(LoginVC.dismissKeyboard))
        toque.delegate = self
        toque.cancelsTouchesInView = false
        self.view.addGestureRecognizer(toque)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is GIDSignInButton {
            return false
        }
        return true
    }
    
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //accion para abrir la vista de crear cuenta
    @IBAction func crearCuentaBtnAccion(_ sender: Any) {
       // let createdAccountVC = storyboard?.instantiateViewController(withIdentifier: "createdAccountVC")
       // present(createdAccountVC!, animated: true, completion: nil)
    }
    
    //iniciar sesion con google
   /* func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error{
            print("Fallo el login con Google: ",err)
            return
        }
    }
*/
    
}

