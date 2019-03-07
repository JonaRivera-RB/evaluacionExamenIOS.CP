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
import CommonCrypto


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
        //defaultProfileImage
        if nombreTxt.text != "" &&  correoTxt.text != "" && contraTxt.text != "" && imagenPerfil.image != UIImage(named:"defaultProfileImage") {
            if validadContra(in: contraTxt.text!) {
                if validarCorreo(string: correoTxt.text!) {
                    let alertaCargando = mostrarAlertCargando()
                    registrarUsuario(paraCorreo: self.correoTxt.text!, paraContra: self.contraTxt.text!, alerta: alertaCargando) { (exito, errorRegistro) in
                        if exito {
                            print("Registrado exitosamente 1")
                        } else {
                            print(String(describing: errorRegistro?.localizedDescription))
                        }
                    }
                }else {
                mostrarAlerta(paraTitulo: "Error", paraString: "El correo electronico no es valido.")
            }
        }
            else {
                mostrarAlerta(paraTitulo: "Error", paraString: "La contraseña no cuenta con los datos correctos: \n 1 mayuscula \n 1 minuscula \n 1 numero \n 1 caracter especial.")
            }
        }else {
            
            mostrarAlerta(paraTitulo: "Error", paraString: "Llene todos los campos requeridos, incluyendo una fotografia.")
        }
    }
    
    func registrarUsuario(paraCorreo correo:String, paraContra contra:String, alerta:UIAlertController,creacionUsuarioCompleta: @escaping
        (_ status:Bool, _ error:Error?) ->() ) {
        
        Auth.auth().createUser(withEmail: correo, password: self.md5(contra)) { (usuario, error) in
            guard let usuario = usuario else {
                creacionUsuarioCompleta(false, error)
                alerta.dismiss(animated: true, completion: {
                    self.mostrarAlerta(paraTitulo: "Error", paraString: ((error?.localizedDescription)!))
                })
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
                    LoginServicio.instancia.iniciarSesion(paraCorreo: correo, paraContra: self.md5(contra), loginCompleta: { (exito, nil) in
                        alerta.dismiss(animated: true, completion: {
                            let inicioVC = self.storyboard?.instantiateViewController(withIdentifier: "InicioVC")
                            self.present(inicioVC!, animated: true, completion: nil)
                            print("registrado exitosamente 2")
                        })
                    })
                }
                else
                {
                    
                    alerta.dismiss(animated: true, completion: {
                        if let error = error?.localizedDescription {
                            print("error de firebase",error)
                            self.mostrarAlerta(paraTitulo: "Error", paraString: (error))
                        }
                        else {
                            print("error de codigo")
                        }
                        self.mostrarAlerta(paraTitulo: "Error", paraString: "Error")
                    })
                }
            })
            let datosUsuario = ["nombre": self.nombreTxt.text!,
                                "email": usuario.user.email,
                            "contraseña": self.md5(self.contraTxt.text!),
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
     func validarCorreo(string: String) -> Bool {
        let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let correoTest = NSPredicate(format:"SELF MATCHES %@", email)
        return correoTest.evaluate(with: string)
    }
    
    func md5(_ string: String) -> String {
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
    func mostrarAlerta(paraTitulo titulo: String,paraString string:String) {
        let alerta = UIAlertController(title: titulo, message: string, preferredStyle: .alert)
        let accion = UIAlertAction(title: "ok", style: .default, handler: nil)
        alerta.addAction(accion)
        present(alerta, animated: true, completion: nil)
    }
    func mostrarAlertCargando () -> UIAlertController{
        
        let alertaCargando = UIAlertController(title: nil, message: "Creando cuenta...", preferredStyle: .alert)
        
        let cargandoIndicador = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        cargandoIndicador.hidesWhenStopped = true
        cargandoIndicador.style = UIActivityIndicatorView.Style.gray
        cargandoIndicador.startAnimating();
        
        alertaCargando.view.addSubview(cargandoIndicador)
        present(alertaCargando, animated: true, completion: nil)
        
        return alertaCargando
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
