//
//  ReporteDetalleViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 15/08/26.
//

import UIKit
import MapKit

class ReporteDetalleViewController: UIViewController {

    @IBOutlet weak var descripcionFechaHoraTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var descripcion: String = ""
    var latitud: Double = 0.0
    var longitud: Double = 0.0
    var nombreMascotaPin: String = ""
 
    override func viewDidLoad() {
        super.viewDidLoad()
 
        configurarTextField()
        configurarMapa()
    }
 
    func configurarTextField() {
            // El textField es solo informativo no editable
            descripcionFechaHoraTextField.isEnabled = false
            descripcionFechaHoraTextField.text = ""

            let labelMultiLinea = UILabel(frame: descripcionFechaHoraTextField.bounds)
            labelMultiLinea.text = descripcion
            labelMultiLinea.numberOfLines = 0 // El '0' le permite usar 2 o más líneas si las necesita
            labelMultiLinea.font = descripcionFechaHoraTextField.font
            labelMultiLinea.textColor = descripcionFechaHoraTextField.textColor
            
            labelMultiLinea.frame = descripcionFechaHoraTextField.bounds.insetBy(dx: 8, dy: 0)

            descripcionFechaHoraTextField.addSubview(labelMultiLinea)
    }
    
    func configurarMapa() {
        let coordenada = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
 
        let region = MKCoordinateRegion(
            center: coordenada,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        mapView.setRegion(region, animated: false)
 
        let pin = MKPointAnnotation()
        pin.coordinate = coordenada
        pin.title = nombreMascotaPin
 
        mapView.addAnnotation(pin)
    }
}
