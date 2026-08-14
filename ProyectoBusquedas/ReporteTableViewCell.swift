//
//  ReporteTableViewCell.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 10/08/26.
//

import UIKit

class ReporteTableViewCell: UITableViewCell {

    @IBOutlet weak var nombreUsuarioLabel: UILabel!
    @IBOutlet weak var fechaHoraPublicacionLabel: UILabel!
    @IBOutlet weak var ultimaActualizacionLabel: UILabel!
    @IBOutlet weak var fechaHoraActualizacionLabel: UILabel!
    @IBOutlet weak var estadoBusquedaLabel: UILabel!
    @IBOutlet weak var ciudadDistritoLabel: UILabel!
    @IBOutlet weak var descripcionFechaHoraPerdidoLabel: UILabel!
    @IBOutlet weak var ubicacionPerdidoLabel: UILabel!
    @IBOutlet weak var nombreMascotaLabel: UILabel!
    @IBOutlet weak var caracteristicaMascota1Label: UILabel!
    @IBOutlet weak var caracteristicaMascota2Label: UILabel!
    @IBOutlet weak var caracteristicaMascota3Label: UILabel!
    @IBOutlet weak var fotoMascotaImageView: UIImageView!
    @IBOutlet weak var telefonoUsuarioLabel: UILabel!
    @IBOutlet weak var telefonoOpcionalLabel: UILabel!
    @IBOutlet weak var montoRecompensaLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        fotoMascotaImageView.contentMode = .scaleAspectFill
        fotoMascotaImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
