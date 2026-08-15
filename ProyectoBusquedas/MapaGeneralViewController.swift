//
//  MapaGeneralViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 14/08/26.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class MapaGeneralViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var buscarDireccionTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    // Se usa para centrar el mapa en la ubicación real del usuario al abrir
    let locationManager = CLLocationManager()
 
    // Lima, Perú — centro de respaldo si no hay permiso de ubicación o falla el GPS
    let coordenadaPorDefecto = CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428)
 
    override func viewDidLoad() {
        super.viewDidLoad()
 
        mapView.delegate = self
 
        configurarMapa()
        configurarBuscador()
        configurarUbicacionActual()
        cargarPublicacionesEnMapa()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        // Por si se publicó o finalizó un reporte mientras el usuario no estaba
        // en esta pantalla, se recargan los pines cada vez que vuelve a aparecer
        cargarPublicacionesEnMapa()
    }
 
    // MARK: - Configuración inicial
 
    func configurarMapa() {
        mapView.showsUserLocation = true
 
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
            break
        @unknown default:
            break
        }
    }
 
    // MARK: - Carga de publicaciones como pines
 
    func cargarPublicacionesEnMapa() {
        // Se quitan los pines anteriores para no duplicarlos al recargar
        // (annotations que no sean la ubicación del propio usuario)
        let pinesAnteriores = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(pinesAnteriores)
 
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
 
        let request: NSFetchRequest<PublicacionEntity> = PublicacionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "estadoBusqueda == %@", "Se busca")
 
        do {
            let publicaciones = try context.fetch(request)
 
            for publicacion in publicaciones {
                // Se descartan coordenadas en (0,0): publicaciones creadas sin
                // seleccionar ubicación real en el mapa (ver PublicarReporteVC)
                if publicacion.latitud == 0.0 && publicacion.longitud == 0.0 {
                    continue
                }
 
                let pin = MKPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(
                    latitude: publicacion.latitud,
                    longitude: publicacion.longitud
                )
                pin.title = publicacion.nombreMascota
                pin.subtitle = publicacion.estadoBusqueda
 
                mapView.addAnnotation(pin)
            }
        } catch let error as NSError {
            print("No fue posible cargar las publicaciones en el mapa \(error), \(error.userInfo)")
        }
    }
 
    // MARK: - MKMapViewDelegate (callout al tocar un pin)
 
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // No personalizar el pin azul de "mi ubicación"
        if annotation is MKUserLocation {
            return nil
        }
 
        let identifier = "pinPublicacion"
        var vistaPin = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
 
        if vistaPin == nil {
            vistaPin = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            vistaPin?.canShowCallout = true
        } else {
            vistaPin?.annotation = annotation
        }
 
        vistaPin?.markerTintColor = .systemRed
 
        return vistaPin
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
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        buscarDireccion(textField.text ?? "")
        return true
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
        print("No se pudo obtener la ubicación actual: \(error.localizedDescription)")
    }
 
    // MARK: - Utilidades
 
    func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }
}
