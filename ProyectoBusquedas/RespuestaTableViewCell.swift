//
//  RespuestaTableViewCell.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 16/08/26.
//

import UIKit
import MapKit

class RespuestaTableViewCell: UITableViewCell {

    @IBOutlet weak var nombreUsuarioLabel: UILabel!
    @IBOutlet weak var correoLabel: UILabel!
    @IBOutlet weak var telefonoLabel: UILabel!
    @IBOutlet weak var descripcionAvistamientoLabel: UITextView!
    @IBOutlet weak var ubicacionAvistadoLabel: UILabel!
    @IBOutlet weak var mapViewAvistado: MKMapView!
    @IBOutlet weak var fotoMascotaStackView: UIStackView!
    @IBOutlet weak var fotoMascotaAvistado: UIImageView!
    @IBOutlet weak var fechaHoraRespuestaLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descripcionAvistamientoLabel.isEditable = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
