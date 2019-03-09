//
//  DetectarTextoTextField.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/5/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit

class DetectarTextoTextField: UITextField {
    
    private var padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    override func awakeFromNib() {
        let placeholder  = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.224609375, green: 0.6818547666, blue: 1, alpha: 1)])
        self.attributedPlaceholder = placeholder
        super.awakeFromNib()
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
    


