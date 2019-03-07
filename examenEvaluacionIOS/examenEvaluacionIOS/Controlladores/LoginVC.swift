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
    
    
    @IBOutlet weak var correoTxt: DetectarTextoTextField!
    @IBOutlet weak var contraTxt: DetectarTextoTextField!
    
    
    var imagen:UIImage!
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

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error{
            print("Fallo logeo con google: ",err)
            return
        }
        
        guard let idToken = user.authentication.idToken else {return}
        guard let accessToken = user.authentication.accessToken else {return}
        guard let imagenGoogle = user.profile.imageURL(withDimension: 400) else {return}
        let url = imagenGoogle
        
        if let dataa = try? Data(contentsOf: url)
        {
            imagen = UIImage(data: dataa)!
        }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credentials) { (user, error) in
            if let erro = error{
                print("error",erro)
                return
            }
            guard let uid = user?.user.uid else {return}
            
            Servicios.instancia.REF_USUARIOS.child((user?.user.uid)!).observeSingleEvent(of: .value, with: { (snaps) in
                let snaps = snaps.value as? NSDictionary
                if(snaps == nil)
                {
                    // let imagenString  = String(describing:self.image)
                    let storage = Storage.storage().reference()
                    let nombreImagen = UUID()
                    let directorio = storage.child("imagenesUsuarios/\(nombreImagen)")
                    let metaDatos = StorageMetadata()
                    metaDatos.contentType = "image/png"
                    directorio.putData(self.imagen.pngData()!, metadata: metaDatos, completion: { (data, error) in
                        if error == nil
                        {
                            Servicios.instancia.REF_USUARIOS.child((user?.user.uid)!).child("nombre").setValue(user?.user.displayName)
                            Servicios.instancia.REF_USUARIOS.child((user?.user.uid)!).child("email").setValue(user?.user.email)
                            Servicios.instancia.REF_USUARIOS.child((user?.user.uid)!).child("foto").setValue(String(describing: self.imagen))
                            
                            let datosUsuario = ["nombre": user?.user.displayName,
                                            "email": user?.user.email,
                                            "id": user?.user.uid,
                                            "foto":String(describing:directorio)]
                            
                            
                            Servicios.instancia.crearUsuarioDB(uid: user!.user.uid, datosUsuario: datosUsuario as Any as! Dictionary<String, Any>)
                            
                        }
                        if let error = error?.localizedDescription {
                            print("error de firebase",error)
                        }
                        else {
                            print("error de codigo")
                        }
                    })
                }
                let inicioVC = self.storyboard?.instantiateViewController(withIdentifier: "InicioVC")
                self.present(inicioVC!, animated: true, completion: nil)
            })
            print("Logeado con exito en firebase con google",uid)
        }
        print("Logeado con exito en firebase con google",user)
    }
    
}

