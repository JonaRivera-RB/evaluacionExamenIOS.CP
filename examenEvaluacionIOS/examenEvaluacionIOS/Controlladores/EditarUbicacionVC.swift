//
//  EditarUbicacionVC.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/8/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit
import MapKit

class EditarUbicacionVC: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var nombreTxt: DetectarTextoTextField!
    @IBOutlet weak var direccionTxt: DetectarTextoTextField!
    @IBOutlet weak var comentarioTxt: DetectarTextoTextField!
    
    var nombre:String!
    var direccion:String!
    var descripcion:String!
    var latitud:Double!
    var longitud:Double!
    let radiosRegion: Double = 2000
    var idUbicacion:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nombreTxt.text = nombre
        direccionTxt.text = direccion
        comentarioTxt.text = descripcion
        centrarUbicacionUsuarioMapa(position: CLLocationCoordinate2D(latitude: latitud, longitude: longitud))
        
        dobleTap()
    }
    func dobleTap() {
        let dobleTap = UILongPressGestureRecognizer(target: self, action: #selector(soltarPin(sender:)))
        dobleTap.numberOfTouchesRequired = 1
        dobleTap.delegate = self
        mapa.addGestureRecognizer(dobleTap)
    }
    
    func initDatos(ubicacion:Ubicaciones){
        self.nombre = ubicacion.nombre
        self.direccion = ubicacion.direccion
        self.descripcion = ubicacion.descripcion
        self.latitud = ubicacion.latitud
        self.longitud = ubicacion.longitud
        self.idUbicacion = ubicacion.id
    }
    
    @IBAction func salirBtnAccion(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func actualizarBtnAccion(_ sender: Any) {
        
        let nuevaUBicacion = ["nombre":nombreTxt.text!,
                                "direccion":direccionTxt.text!,
                                "descripcion":comentarioTxt.text!,
                                "latitud":latitud!,
                                "longitud":longitud!] as [String : Any]
        
        Servicios.instancia.REF_UBICACIONES.child(idUbicacion).updateChildValues(nuevaUBicacion)
        dismiss(animated: true)
        
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
                    self.direccionTxt.text = direccionString
                    print(direccionString)
                }
        })
        
    }
    
}
extension EditarUbicacionVC: MKMapViewDelegate {
    
    func centrarUbicacionUsuarioMapa(position:CLLocationCoordinate2D){
        let radiosRegion: Double = 2000
        let coordianteRegion = MKCoordinateRegion(center: position, latitudinalMeters: radiosRegion * 2.0, longitudinalMeters: radiosRegion * 2.0)
        mapa.setRegion(coordianteRegion, animated: true)
        
        let annotation = SoltarPin(coordinate: position, identifier: "drppablePin")
        mapa.addAnnotation(annotation)
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
        
        latitud = coordinateRegion.center.latitude
        longitud = coordinateRegion.center.longitude
        
        print("latitud \(String(describing: latitud))")
        print("longitud \(String(describing: longitud))")
        
        self.obtenerDireccionConCordenadas(paraLatitud: latitud!, paraLongitud: longitud!)
        mapa.setRegion(coordinateRegion, animated: true)
    }
    func removePin() {
        for annotation in mapa.annotations {
            mapa.removeAnnotation(annotation)
        }
    }
    
}
