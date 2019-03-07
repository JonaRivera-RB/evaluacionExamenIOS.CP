//
//  VistaSombreView.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/7/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit
@IBDesignable

class VistaSombreView: UIView {

    class ShadowView: UIView {
        
        override func prepareForInterfaceBuilder() {
            vistaView()
        }
        override func awakeFromNib() {
            vistaView()
            super.awakeFromNib()
        }
        
        func vistaView()
        {
            self.layer.shadowOpacity = 0.75
            self.layer.shadowRadius = 5
            self.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.layer.cornerRadius = 0.5
        }
    }


}
