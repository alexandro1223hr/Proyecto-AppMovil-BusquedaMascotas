//
//  VerRespuestasViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 17/08/26.
//

import UIKit
import CoreData
import MapKit

class VerRespuestasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var verRespuestasTableView: UITableView!
    
    // Se asigna ANTES del segue, desde prepare(for:sender:) en
    // ReportesPublicadosViewController
    var idPublicacion: UUID?
 
    var respuestasList: [RespuestaEntity] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ID de publicación recibido: \(String(describing: idPublicacion))")
        
        verRespuestasTableView.dataSource = self
        verRespuestasTableView.delegate = self
 
        listarRespuestas()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listarRespuestas()
    }
 
    // MARK: - Listar Respuestas
    func listarRespuestas() {
        guard let idPublicacion = idPublicacion else {
            respuestasList = []
            verRespuestasTableView.reloadData()
            return
        }
 
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
 
        let request: NSFetchRequest<RespuestaEntity> = RespuestaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "idPublicacion == %@", idPublicacion as CVarArg)
 
        let orden = NSSortDescriptor(key: "fechaHoraRespuesta", ascending: false)
        request.sortDescriptors = [orden]
 
        do {
            respuestasList = try context.fetch(request)
        } catch let error as NSError {
            print("No fue posible listar las respuestas \(error), \(error.userInfo)")
        }
 
        verRespuestasTableView.reloadData()
    }
 
    // MARK: - Funciones TableViewCell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return respuestasList.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "respuestaCell", for: indexPath) as! RespuestaTableViewCell
 
        let respuesta = respuestasList[indexPath.row]
 
        cell.nombreUsuarioLabel.text = respuesta.usuario?.nombre
        cell.correoLabel.text = respuesta.usuario?.correo
        cell.telefonoLabel.text = respuesta.usuario?.telefono
 
        if let fecha = respuesta.fechaHoraRespuesta {
            cell.fechaHoraRespuestaLabel.text = tiempoTranscurrido(desde: fecha)
        } else {
            cell.fechaHoraRespuestaLabel.text = ""
        }
 
        cell.descripcionAvistamientoLabel.text = respuesta.descripcion
        cell.ubicacionAvistadoLabel.text = respuesta.ubicacionAvistado
 
        configurarMapa(cell.mapViewAvistado, latitud: respuesta.latitud, longitud: respuesta.longitud)
 
        if let datosImagen = respuesta.fotoMascota, let imagen = UIImage(data: datosImagen) {
            cell.fotoMascotaAvistado.image = imagen
            cell.fotoMascotaStackView.isHidden = false
        } else {
            cell.fotoMascotaStackView.isHidden = true
        }
 
        return cell
    }
 
    // MARK: - Mapa
 
    func configurarMapa(_ mapView: MKMapView, latitud: Double, longitud: Double) {
        mapView.removeAnnotations(mapView.annotations)
 
        let coordenada = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
 
        let region = MKCoordinateRegion(
            center: coordenada,
            latitudinalMeters: 800,
            longitudinalMeters: 800
        )
        mapView.setRegion(region, animated: false)
 
        let pin = MKPointAnnotation()
        pin.coordinate = coordenada
        mapView.addAnnotation(pin)
    }
 
    // MARK: - Utilidades
 
    func tiempoTranscurrido(desde fecha: Date) -> String {
        let calendario = Calendar.current
        let componentes = calendario.dateComponents(
            [.year, .month, .weekOfYear, .day, .hour, .minute],
            from: fecha,
            to: Date()
        )
 
        if let años = componentes.year, años > 0 {
            return años == 1 ? "Hace 1 año" : "Hace \(años) años"
        }
        if let meses = componentes.month, meses > 0 {
            return meses == 1 ? "Hace 1 mes" : "Hace \(meses) meses"
        }
        if let semanas = componentes.weekOfYear, semanas > 0 {
            return semanas == 1 ? "Hace 1 semana" : "Hace \(semanas) semanas"
        }
        if let dias = componentes.day, dias > 0 {
            return dias == 1 ? "Hace 1 día" : "Hace \(dias) días"
        }
        if let horas = componentes.hour, horas > 0 {
            return horas == 1 ? "Hace 1 hora" : "Hace \(horas) horas"
        }
        if let minutos = componentes.minute, minutos > 0 {
            return minutos == 1 ? "Hace 1 minuto" : "Hace \(minutos) minutos"
        }
 
        return "Hace unos segundos"
    }
}
