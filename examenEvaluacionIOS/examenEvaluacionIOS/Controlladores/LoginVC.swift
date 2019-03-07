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
        let toque = UITapGestureRecognizer(target: self, action: #selector(LoginVC.tecladoOculto))
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
    
    
    @objc func tecladoOculto() {
        self.view.endEditing(true)
    }
    @IBAction func iniciarSesionBtnAccion(_ sender: Any) {
        if correoTxt.text != nil &&  contraTxt.text != nil {
            let alertaCargando = UIAlertController(title: nil, message: "Validando datos...", preferredStyle: .alert)
            
            let cargandoIndicador = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            cargandoIndicador.hidesWhenStopped = true
            cargandoIndicador.style = UIActivityIndicatorView.Style.gray
            cargandoIndicador.startAnimating();
            
            alertaCargando.view.addSubview(cargandoIndicador)
            present(alertaCargando, animated: true, completion: nil)
            
            LoginServicio.instancia.iniciarSesion(paraCorreo:  correoTxt.text!, paraContra: contraTxt.text!) { (exito, loginError) in
                if exito {
                    alertaCargando.dismiss(animated: true, completion: nil)
                    let inicioVC = self.storyboard?.instantiateViewController(withIdentifier: "InicioVC")
                    self.present(inicioVC!, animated: true, completion: nil)
                } else {
                    alertaCargando.dismiss(animated: true, completion: nil)
                    self.mostrarAlerta(paraTitulo: "Error", paraString: (loginError?.localizedDescription)!)
                    print(String(describing: loginError?.localizedDescription))
                    self.correoTxt.text = ""
                    self.contraTxt.text = ""
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

