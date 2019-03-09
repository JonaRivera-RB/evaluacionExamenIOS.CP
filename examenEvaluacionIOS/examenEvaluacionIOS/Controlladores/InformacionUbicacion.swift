//
//  InformacionUbicacion.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/7/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit
import MapKit


class InformacionUbicacion: UIViewController {

    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var tablaLuagres: UITableView!
    @IBOutlet weak var nombreUbicaicon: UILabel!
    
    var latitud:Double!
    var longitud:Double!
    var nombreUbicacion:String!
    
    
    
    var lugares = [LugaresCerca]()
    
    var direcciones = [String]()
    var nombres = [String]()
    var valoraciones = [Float]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaLuagres.delegate = self
        tablaLuagres.dataSource = self
        
        mapa.delegate = self
        mapa.showsScale = true
        mapa.showsPointsOfInterest = true
        mapa.showsUserLocation = true
        nombreUbicaicon.text = nombreUbicacion
        
        centrarUbicacionUsuarioMapa(position: CLLocationCoordinate2D(latitude: self.latitud, longitude: self.longitud))
        obtenerLugaresCerca()
    }
    
    func initCordenads(ubicacion:Ubicaciones){
        self.latitud = ubicacion.latitud
        self.longitud = ubicacion.longitud
        self.nombreUbicacion = ubicacion.nombre
        
    }
    
    func obtenerLugaresCerca() {
        
        let urlObjeto = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitud!),\(longitud!)&rankby=distance&type=%20estaurant&key=AIzaSyD4aBuZnkQ5E3hjA1gZFjz4sBWXBnvX-e4")
        let homework = URLSession.shared.dataTask(with: urlObjeto!)
        {
            datos,respuesta,error in
            if error != nil {
                print(error!)
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: datos!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                    let getResultados = json["results"] as? [Any]
                    
                    for int in getResultados! {
                        let firstObject = int as? [String:Any]
                        
                        if let obtDireccion = firstObject!["vicinity"] as? String {
                            self.direcciones.append(obtDireccion)
                        }
                        else {
                            if let obtDireccion = firstObject!["formatted_address"] as? String {
                                self.direcciones.append(obtDireccion)
                            }
                        }
                        let guardarNombre = [firstObject!["name"] as! String]
                        if let obtValoracion = firstObject!["rating"] as? Double {
                            self.valoraciones.append(Float(obtValoracion))
                        }
                        else {
                            self.valoraciones.append(0)
                        }
                        
                        self.nombres.append(contentsOf: guardarNombre)
                    }
                    
                    DispatchQueue.main.sync(execute: {
                        var numero = 0
                        for _ in self.nombres {
                            self.lugares.append(LugaresCerca(nombre: self.nombres[numero], direccion: self.direcciones[numero], valoracion: self.valoraciones[numero]))
                            numero += 1
                        }
                        print(self.lugares[1].nombre)
                        self.tablaLuagres.reloadData()
                    })
                }catch{ print("el procesamiento salio mal")
                    
                }
            }
        }
        homework.resume()
    }
    @IBAction func salirBtnAccion(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
extension InformacionUbicacion: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  lugares.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tablaLuagres!.dequeueReusableCell(withIdentifier: "cellInformacion", for: indexPath)
            let nombre = lugares[indexPath.row].nombre
            let direccion = lugares[indexPath.row].direccion
        cell.textLabel?.text = nombre
        cell.detailTextLabel!.text = direccion
            return cell
        
    }
    
    
}

extension InformacionUbicacion: MKMapViewDelegate {
    
    func centrarUbicacionUsuarioMapa(position:CLLocationCoordinate2D){
        let radiosRegion: Double = 2000
        let coordianteRegion = MKCoordinateRegion(center: position, latitudinalMeters: radiosRegion * 2.0, longitudinalMeters: radiosRegion * 2.0)
        mapa.setRegion(coordianteRegion, animated: true)
        
        let annotation = SoltarPin(coordinate: position, identifier: "drppablePin")
        mapa.addAnnotation(annotation)
    }
    
}
