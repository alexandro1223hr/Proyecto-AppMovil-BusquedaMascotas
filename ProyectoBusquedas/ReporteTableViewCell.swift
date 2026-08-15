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
    
    @IBOutlet weak var comunicarseTelfefonosStackView: UIStackView!
    @IBOutlet weak var actualizacionStackView: UIStackView!
    
    @IBOutlet weak var botonIzquierdoAccion: UIButton!
    @IBOutlet weak var botonDerechoAccion: UIButton!
    
    // Guarda el reporte actual de la fila, para que InicioVC o
    // ReportesPublicadosVC lo lean cuando el usuario toca un botón
    var reporteActual: PublicacionEntity?
 
    // Closures que cada VC asigna para decidir qué pasa al tocar cada botón.
    // Así la celda no necesita saber si está en Inicio o en Mis Publicaciones,
    // solo avisa "tocaron el botón izquierdo/derecho de esta fila".
    var accionBotonIzquierdo: (() -> Void)?
    var accionBotonDerecho: (() -> Void)?
 
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
 
    // esMisPublicaciones = true  → "Finalizar" / "Ver respuestas"
    // esMisPublicaciones = false → "Guardar" / "Responder"
    // yaGuardado solo importa cuando esMisPublicaciones es false: decide si el
    // ícono de guardar se muestra lleno (ya guardado) o vacío (no guardado).
    func configurarModoBotones(esMisPublicaciones: Bool, yaGuardado: Bool = false) {
        if esMisPublicaciones {
            botonIzquierdoAccion.setTitle("Finalizar", for: .normal)
            botonIzquierdoAccion.setImage(UIImage(systemName: "checkmark.seal"), for: .normal)
 
            botonDerechoAccion.setTitle("Ver respuestas", for: .normal)
            botonDerechoAccion.setImage(UIImage(systemName: "envelope.open"), for: .normal)
        } else {
            actualizarIconoGuardado(yaGuardado: yaGuardado)
 
            botonDerechoAccion.setTitle("Responder", for: .normal)
            botonDerechoAccion.setImage(UIImage(systemName: "envelope"), for: .normal)
        }
    }
 
    // Cambia el ícono y texto del botón izquierdo entre "Guardar" (bookmark
    // vacío) y "Guardado" (bookmark.fill)
    func actualizarIconoGuardado(yaGuardado: Bool) {
        if yaGuardado {
            botonIzquierdoAccion.setTitle("Guardado", for: .normal)
            botonIzquierdoAccion.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        } else {
            botonIzquierdoAccion.setTitle("Guardar", for: .normal)
            botonIzquierdoAccion.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
    }
 
    @IBAction func tocoBotonIzquierdo(_ sender: UIButton) {
        accionBotonIzquierdo?()
    }
 
    @IBAction func tocoBotonDerecho(_ sender: UIButton) {
        accionBotonDerecho?()
    }
}
// SCRUM-4
