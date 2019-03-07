//
//  MisUbicacionesCell.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/7/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit

class MisUbicacionesCell: UITableViewCell {

    @IBOutlet weak var nombreLugar:UILabel!
    //@IBOutlet weak var descripcionLugar:UILabel!
    @IBOutlet weak var domicilioLugar:UILabel!
    
    func actualizarVista(datosUbicaciones:Ubicaciones){
        nombreLugar.text = datosUbicaciones.nombre
     //   descripcionLugar.text = datosUbicaciones.descripcion
        domicilioLugar.text = datosUbicaciones.direccion
    }

}
