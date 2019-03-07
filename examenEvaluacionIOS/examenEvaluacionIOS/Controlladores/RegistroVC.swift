//
//  RegistroVC.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/6/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage


class RegistroVC: UIViewController {
    
    @IBOutlet weak var nombreTxt: DetectarTextoTextField!
    @IBOutlet weak var correoTxt: DetectarTextoTextField!
    @IBOutlet weak var imagenPerfil: UIImageView!
    @IBOutlet weak var contraTxt: DetectarTextoTextField!
    
    var imagen = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nombreTxt.delegate = self
        imagenPerfil.layer.cornerRadius = self.imagenPerfil.frame.size.width / 2
        imagenPerfil.clipsToBounds = true
        let toque:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegistroVC.ocultarTeclado))
        
        view.addGestureRecognizer(toque)
    }
    @objc func ocultarTeclado() {
        view.endEditing(true)
    }
    
    @IBAction func crearCuentaBtnAccin(_ sender: Any) {
        //crear funciones para validar los datos
        if nombreTxt.text != nil &&  correoTxt.text != nil && contraTxt.text != nil {
            if validadContra(in: contraTxt.text!) {
                
                registrarUsuario(paraCorreo: self.correoTxt.text!, paraContra: self.contraTxt.text!) { (exito, errorRegistro) in
                    if exito {
                        print("Registrado exitosamente")
                    } else {
                        print(String(describing: errorRegistro?.localizedDescription))
                    }
                }
            }
            else {
                mostrarAlerta(paraTitulo: "Error", paraString: "La contraseña no cuenta con los datos correctos: \n 1 mayuscula \n 1 minuscula \n 1 numero \n 1 caracter especial.")
            }
        }
    }
    
    func registrarUsuario(paraCorreo correo:String, paraContra contra:String, creacionUsuarioCompleta: @escaping
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
            directorio.putData(self.imagen.pngData()!, metadata: metaDatos, completion: { (data, error) in
                if error == nil
                {
                    print("cargo la imagen")
                    LoginServicio.instancia.iniciarSesion(paraCorreo: correo, paraContra: contra, creacionUsuarioCompleta: { (exito, nil) in
                        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVista")
                        //inicioVC
                        self.present(loginVC!, animated: true, completion: nil)
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
            let datosUsuario = ["nombre": self.nombreTxt.text!,
                                "email": usuario.user.email,
                            "contraseña": self.contraTxt.text!,
                            "id": usuario.user.uid,
                            "foto":String(describing:directorio)]
            
            Servicios.instancia.crearUsuarioDB(uid: usuario.user.uid, datosUsuario: datosUsuario as Any as! Dictionary<String, Any>)
            
            creacionUsuarioCompleta(true,nil)
        }
    }
    
    func validadContra( in text: String) -> Bool {
        
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: text)
    }
    
    func mostrarAlerta(paraTitulo titulo: String,paraString string:String) {
        let alerta = UIAlertController(title: titulo, message: string, preferredStyle: .alert)
        let accion = UIAlertAction(title: "ok", style: .default, handler: nil)
        alerta.addAction(accion)
        present(alerta, animated: true, completion: nil)
    }
    
    @IBAction func cerrarVistaBtnAccion(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cambiarFotoBtnAction(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker,animated: true,completion: nil)
    }
}


extension RegistroVC : UITextFieldDelegate {
}

extension RegistroVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let imagenTomada = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        imagen = imagenTomada!
        imagenPerfil.image = imagenTomada
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
