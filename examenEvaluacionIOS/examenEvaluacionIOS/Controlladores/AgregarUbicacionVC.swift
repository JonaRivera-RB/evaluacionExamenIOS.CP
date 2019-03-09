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
import CoreLocation


class AgregarUbicacionVC: UIViewController,UIGestureRecognizerDelegate {

    
    
    @IBOutlet weak var mapa: MKMapView!
    
    @IBOutlet weak var nombreLbl: DetectarTextoTextField!
    @IBOutlet weak var domicilioLbl: DetectarTextoTextField!
    @IBOutlet weak var descripcionLbl: DetectarTextoTextField!
    
    var idUsuario = ""
    var bandera:Bool!
    
    
    var locationManager = CLLocationManager()
    var estadoAutorizacionUbicacion = CLLocationManager.authorizationStatus()
    let radiosRegion: Double = 2000
    var misCordenadas: CLLocationCoordinate2D?
    
    var cordenadaLongitud:Double?
    var cordenadaLatitud:Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapa.delegate = self
        mapa.showsScale = true
        mapa.showsPointsOfInterest = true
        mapa.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() {
            configuracionServiciosLocalizacion()
        }
        dobleTap()
    }
    func initUsuario(id:String, bandera:Bool)
    {
        idUsuario = id
        self.bandera = bandera
    }
    
    func dobleTap() {
        let dobleTap = UILongPressGestureRecognizer(target: self, action: #selector(soltarPin(sender:)))
        dobleTap.numberOfTouchesRequired = 1
        dobleTap.delegate = self
        mapa.addGestureRecognizer(dobleTap)
    }
    
    @IBAction func agregarDBBotonAccion(_ sender: Any) {
        if nombreLbl.text != "" && descripcionLbl.text != "" {
            if cordenadaLatitud != nil && cordenadaLongitud != nil {
                let id = DB_BASE.childByAutoId().key
                
                let ubicacionUsuario = ["nombre":nombreLbl.text!,
                                        "direccion":domicilioLbl.text!,
                                        "descripcion":self.descripcionLbl.text!,
                                        "latitud":cordenadaLatitud!,
                                        "longitud":cordenadaLongitud!,
                                        "id":id!,
                                        "idUsuario": idUsuario] as [String : Any]
                print("estoy dentro\(idUsuario)")
                
                Servicios.instancia.crearUbicacion(uid: id!, datosUbicacion: ubicacionUsuario)
                dismiss(animated: true)
            }
            else {
                mostrarAlerta(paraTitulo: "Error", paraString: "Selecciona una ubicacion en el mapa")
            }
        }else {
            mostrarAlerta(paraTitulo: "Error", paraString: "Ingrese nombre y descripcion.")
        }
      
        
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
    @IBAction func posicionarBtnAccion(_ sender: Any) {
        if estadoAutorizacionUbicacion == .authorizedAlways || estadoAutorizacionUbicacion == .authorizedWhenInUse {
            centrarUbicacionUsuarioMapa()
        } else {
            print("no tenemos permisos")
        }

    }
    
    func obtenerDireccionConCordenadas(paraLatitud latitud: Double, paraLongitud longitud : Double) {
        var centro : CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        var direccionString : String = ""
        
        let lat: Double = latitud
        let lon: Double = longitud
        
        let ceo: CLGeocoder = CLGeocoder()
        centro.latitude = lat
        centro.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:centro.latitude, longitude: centro.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("error: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                   
                    if pm.subLocality != nil {
                        direccionString = direccionString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        direccionString = direccionString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        direccionString = direccionString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        direccionString = direccionString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        direccionString = direccionString + pm.postalCode! + " "
                    }
                    self.domicilioLbl.text = direccionString
                    print(direccionString)
                }
        })
        
    }
    
}



extension AgregarUbicacionVC : CLLocationManagerDelegate {
    func configuracionServiciosLocalizacion() {
        if estadoAutorizacionUbicacion == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            } else if estadoAutorizacionUbicacion == .authorizedAlways || estadoAutorizacionUbicacion == .authorizedWhenInUse {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                self.misCordenadas = self.locationManager.location?.coordinate
        }
        else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centrarUbicacionUsuarioMapa()
    }
}



extension AgregarUbicacionVC : MKMapViewDelegate {
    
    func centrarUbicacionUsuarioMapa() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        
        let coordianteRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: radiosRegion * 2.0, longitudinalMeters: radiosRegion * 2.0)
        mapa.setRegion(coordianteRegion, animated: true)
        removePin()
        let annotation = SoltarPin(coordinate: coordinate, identifier: "drppablePin")
        mapa.addAnnotation(annotation)
        self.obtenerDireccionConCordenadas(paraLatitud: coordinate.latitude, paraLongitud: coordinate.longitude)
        
    }
    
    @objc func soltarPin(sender: UITapGestureRecognizer) {
        removePin()
        if sender.state == .ended {
       
        }
        
        let puntoTouch = sender.location(in: mapa)
        print("touch point\(puntoTouch)")
        let cordenadasToque = mapa.convert(puntoTouch, toCoordinateFrom: mapa)
        print("touch touchCoordinate\(cordenadasToque)")
        let annotation = SoltarPin(coordinate: cordenadasToque, identifier: "drppablePin")
        mapa.addAnnotation(annotation)
        
        
        let coordinateRegion = MKCoordinateRegion(center: cordenadasToque, latitudinalMeters: radiosRegion * 2.0, longitudinalMeters: radiosRegion * 2.0)
        
        cordenadaLatitud = coordinateRegion.center.latitude
        cordenadaLongitud = coordinateRegion.center.longitude
        self.obtenerDireccionConCordenadas(paraLatitud: cordenadaLatitud!, paraLongitud: cordenadaLongitud!)
        
        mapa.setRegion(coordinateRegion, animated: true)
}
    func removePin() {
        for annotation in mapa.annotations {
            mapa.removeAnnotation(annotation)
        }
    }
}
