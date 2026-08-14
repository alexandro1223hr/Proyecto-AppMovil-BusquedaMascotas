//
//  InicioViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 7/08/26.
//

import UIKit
import CoreData

class InicioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var ReportesTableView: UITableView!

    @IBOutlet weak var barraBusqueda: UISearchBar!

    var reportesPublicadosList: [PublicacionEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ReportesTableView.dataSource = self
        ReportesTableView.delegate = self
        
        configuracionInicial()
        listarReportesPublicados()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Te muestra tu publicacion en el Inicio luego de crearla tu mismo
        listarReportesPublicados()
    }
    
    func configuracionInicial() {
        // Reemplaza el titulo del Navigation Bar(zona superior) por la barra de busqueda
        navigationItem.titleView = barraBusqueda
        barraBusqueda.placeholder = "Buscar"
        
        // Pinta los iconos del Tab Bar(zona inferior) de verde
        if let tabBar = tabBarController?.tabBar {
            tabBar.tintColor = .systemGreen
            tabBar.unselectedItemTintColor = .gray
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportesPublicadosList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reporteCell", for: indexPath) as! ReporteTableViewCell
    
        let reporte = reportesPublicadosList[indexPath.row]
        
        cell.nombreUsuarioLabel.text = reporte.nombreUsuario
        
        // Tiempo transcurrido desde la fecha y hora de la publicacion
        if let fechaPublicacion = reporte.fechaHoraPublicacion {
            cell.fechaHoraPublicacionLabel.text =
                tiempoTranscurrido(desde: fechaPublicacion)
        } else {
            cell.fechaHoraPublicacionLabel.text = ""
        }
        
        // Tiempo transcurrido desde la actualización, solo si existe
        if let fechaActualizacion = reporte.fechaHoraActualizacion {
            cell.ultimaActualizacionLabel.isHidden = false
            cell.fechaHoraActualizacionLabel.isHidden = false

            cell.fechaHoraActualizacionLabel.text =
                tiempoTranscurrido(desde: fechaActualizacion)
        } else {
            cell.ultimaActualizacionLabel.isHidden = true
            cell.fechaHoraActualizacionLabel.isHidden = true
        }
        
        cell.estadoBusquedaLabel.text = reporte.estadoBusqueda
        cell.ciudadDistritoLabel.text = reporte.ciudadDistrito
        cell.descripcionFechaHoraPerdidoLabel.text = reporte.descripcionFechaHoraPerdido
        cell.nombreMascotaLabel.text = reporte.nombreMascota
        cell.caracteristicaMascota1Label.text = reporte.caracteristicaMascota1
        cell.caracteristicaMascota2Label.text = reporte.caracteristicaMascota2
        cell.caracteristicaMascota3Label.text = reporte.caracteristicaMascota3
        
        // Convierte Binary Data a UIImage
        if let datosImagen = reporte.fotoMascota {
            cell.fotoMascotaImageView.image = UIImage(data: datosImagen)
        } else {
            cell.fotoMascotaImageView.image = UIImage(named: "imagenMascotaDefault")
        }
        
        cell.telefonoUsuarioLabel.text = reporte.telefonoUsuario
        
        // Oculta teléfono opcional si está vacío
        if let telefonoOpcional = reporte.telefonoOpcional,
           !telefonoOpcional.isEmpty {

            cell.telefonoOpcionalLabel.text = telefonoOpcional
            cell.telefonoOpcionalLabel.isHidden = false

        } else {
            cell.telefonoOpcionalLabel.isHidden = true
        }
        
        cell.montoRecompensaLabel.text = formatearMonto(reporte.monto! as Decimal)
        
        return cell
    }

    func listarReportesPublicados() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Busca las publicaciones
        let request: NSFetchRequest<PublicacionEntity> =
            PublicacionEntity.fetchRequest()
        
        // Las ordena por fecha mas reciente
        let orden = NSSortDescriptor(
                key: "fechaHoraPublicacion",
                ascending: false
            )
        request.sortDescriptors = [orden]
        
        do {
            let results = try
            managedContext.fetch(PublicacionEntity.fetchRequest())
            reportesPublicadosList = results as [PublicacionEntity]
        }
        catch let error as NSError {
            print("No fue posible listar los datos \(error), \(error.userInfo)")
        }
        ReportesTableView.reloadData()
    }
    
    // Funciones de utilidad
    
    // Calcula tiempo transcurrido y lo establece como texto String
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
    
    // Le da formato de texto al monto
    func formatearMonto(_ monto: Decimal) -> String {
        let formatter = NumberFormatter()

        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "es_PE")

        let numero = NSDecimalNumber(decimal: monto)
        let montoTexto = formatter.string(from: numero) ?? "\(numero)"

        return montoTexto
    }
}
