//
//  SeleccionarUbicacionViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 13/08/26.
//
import UIKit
import MapKit
import CoreLocation

class SeleccionarUbicacionViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    // Conectar estos outlets en el storyboard
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buscarDireccionTextField: UITextField!
    @IBOutlet weak var confirmarButton: UIButton!

    // Se usa para centrar el mapa en la ubicación real del usuario al abrir
    let locationManager = CLLocationManager()

    // Lima, Perú — centro de respaldo si no hay permiso de ubicación o falla el GPS
    let coordenadaPorDefecto = CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428)

    // Estas tres propiedades son públicas a propósito: cuando el usuario confirma
    // la ubicación, PublicarReporteViewController las lee directamente dentro de
    // regresarConUbicacionSeleccionada(_:), que se ejecuta por el unwind segue.
    var latitudConfirmada: Double?
    var longitudConfirmada: Double?
    var textoReferenciaConfirmado: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        configurarMapa()
        configurarBuscador()
        configurarUbicacionActual()
    }

    // MARK: - Configuración inicial

    func configurarMapa() {
        mapView.showsUserLocation = true

        // Centro inicial de respaldo; se sobreescribe si el GPS responde a tiempo
        let region = MKCoordinateRegion(
            center: coordenadaPorDefecto,
            latitudinalMeters: 3000,
            longitudinalMeters: 3000
        )
        mapView.setRegion(region, animated: false)
    }

    func configurarBuscador() {
        buscarDireccionTextField.placeholder = "Buscar dirección"
        buscarDireccionTextField.returnKeyType = .search
        buscarDireccionTextField.delegate = self
    }

    func configurarUbicacionActual() {
        locationManager.delegate = self

        let estado = locationManager.authorizationStatus
        switch estado {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            // Sin permiso: se queda con la coordenada por defecto (Lima)
            break
        @unknown default:
            break
        }
    }

    // MARK: - Búsqueda por dirección (geocoding)

    func buscarDireccion(_ texto: String) {
        guard !texto.isEmpty else { return }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(texto) { placemarks, error in
            if let error = error {
                self.mostrarError("No se pudo encontrar esa dirección: \(error.localizedDescription)")
                return
            }

            guard let coordenada = placemarks?.first?.location?.coordinate else {
                self.mostrarError("No se encontraron resultados para esa dirección")
                return
            }

            let region = MKCoordinateRegion(
                center: coordenada,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            self.mapView.setRegion(region, animated: true)
        }
    }

    // Delegate de UITextField (buscador de direcciones). La clase conforma
    // el protocolo directamente en su declaración, sin usar extension.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        buscarDireccion(textField.text ?? "")
        return true
    }

    // MARK: - Confirmar selección

    // Este botón dispara un unwind segue conectado en el storyboard hacia
    // regresarConUbicacionSeleccionada(_:) en PublicarReporteViewController.
    // Aquí solo se preparan los datos antes de que ocurra el unwind.
    @IBAction func confirmarUbicacion(_ sender: UIButton) {
        let coordenadaSeleccionada = mapView.centerCoordinate

        latitudConfirmada = coordenadaSeleccionada.latitude
        longitudConfirmada = coordenadaSeleccionada.longitude

        // Reverse geocoding: convierte la coordenada en una dirección legible.
        // Como es asíncrono, se guarda primero un texto genérico por si el
        // usuario confirma antes de que la respuesta llegue.
        textoReferenciaConfirmado = String(
            format: "Lat: %.5f, Long: %.5f",
            coordenadaSeleccionada.latitude,
            coordenadaSeleccionada.longitude
        )

        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordenadaSeleccionada.latitude, longitude: coordenadaSeleccionada.longitude)

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                self.textoReferenciaConfirmado = self.formatearDireccion(placemark)
            }
            // Se ejecuta el unwind segue después de intentar el reverse geocoding,
            // ya sea que haya funcionado o no (en ese caso se usa el texto genérico).
            self.performSegue(withIdentifier: "unwindAPublicarReporte", sender: self)
        }
    }

    func formatearDireccion(_ placemark: CLPlacemark) -> String {
        // Arma algo tipo "Av. Larco 123, Miraflores, Lima"
        var partes: [String] = []

        if let calle = placemark.thoroughfare {
            if let numero = placemark.subThoroughfare {
                partes.append("\(calle) \(numero)")
            } else {
                partes.append(calle)
            }
        }
        if let distrito = placemark.subLocality ?? placemark.locality {
            partes.append(distrito)
        }
        if let ciudad = placemark.administrativeArea, !partes.contains(ciudad) {
            partes.append(ciudad)
        }

        return partes.isEmpty ? "Ubicación seleccionada" : partes.joined(separator: ", ")
    }

    @IBAction func cancelarSeleccion(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let ubicacion = locations.first else { return }

        let region = MKCoordinateRegion(
            center: ubicacion.coordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )
        mapView.setRegion(region, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Si falla el GPS, el mapa se queda en la coordenada por defecto (Lima).
        // No se interrumpe al usuario con un alert por esto.
        print("No se pudo obtener la ubicación actual: \(error.localizedDescription)")
    }

    // MARK: - Utilidades

    func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }
    
}
// SCRUM-9
// SCRUM-11
