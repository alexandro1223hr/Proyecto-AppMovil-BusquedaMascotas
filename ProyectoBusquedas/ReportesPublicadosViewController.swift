//
//  ReportesPublicadosViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 14/08/26.
//

import UIKit
import CoreData

class ReportesPublicadosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var misReportesTableView: UITableView!
    
    var misReportesList: [PublicacionEntity] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        misReportesTableView.dataSource = self
        misReportesTableView.delegate = self
 
        listarMisReportes()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listarMisReportes()
    }
 
    func listarMisReportes() {
        // Solo tiene sentido ver "mis publicaciones" con sesión iniciada
        guard let idString = UserDefaults.standard.string(forKey: "usuarioActualID"),
              let idUsuario = UUID(uuidString: idString) else {
            misReportesList = []
            misReportesTableView.reloadData()
            return
        }
 
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
 
        let request: NSFetchRequest<PublicacionEntity> = PublicacionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "idUsuario == %@", idUsuario as CVarArg)
 
        let orden = NSSortDescriptor(key: "fechaHoraPublicacion", ascending: false)
        request.sortDescriptors = [orden]
 
        do {
            misReportesList = try context.fetch(request)
        } catch let error as NSError {
            print("No fue posible listar mis publicaciones \(error), \(error.userInfo)")
        }
 
        misReportesTableView.reloadData()
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return misReportesList.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reporteCell", for: indexPath) as! ReporteTableViewCell
 
        let reporte = misReportesList[indexPath.row]
 
        cell.nombreUsuarioLabel.text = reporte.nombreUsuario
 
        if let fechaPublicacion = reporte.fechaHoraPublicacion {
            cell.fechaHoraPublicacionLabel.text = tiempoTranscurrido(desde: fechaPublicacion)
        } else {
            cell.fechaHoraPublicacionLabel.text = ""
        }
 
        if let fechaActualizacion = reporte.fechaHoraActualizacion {
            cell.actualizacionStackView.isHidden = false
            cell.fechaHoraActualizacionLabel.text = tiempoTranscurrido(desde: fechaActualizacion)
        } else {
            cell.actualizacionStackView.isHidden = true
        }
 
        cell.estadoBusquedaLabel.text = reporte.estadoBusqueda
        cell.ciudadDistritoLabel.text = reporte.ciudadDistrito
        cell.descripcionFechaHoraPerdidoLabel.text = reporte.descripcionFechaHoraPerdido
        cell.ubicacionPerdidoLabel.text = reporte.ubicacionPerdido
        cell.caracteristicaMascota1Label.text = reporte.caracteristicaMascota1
        cell.caracteristicaMascota2Label.text = reporte.caracteristicaMascota2
        cell.caracteristicaMascota3Label.text = reporte.caracteristicaMascota3
 
        if let datosImagen = reporte.fotoMascota {
            cell.fotoMascotaImageView.image = UIImage(data: datosImagen)
        } else {
            cell.fotoMascotaImageView.image = UIImage(named: "imagenMascotaDefault")
        }
 
        if let nombreMascota = reporte.nombreMascota, !nombreMascota.isEmpty {
            cell.nombreMascotaLabel.text = nombreMascota
            cell.nombreMascotaLabel.isHidden = false
        } else {
            cell.nombreMascotaLabel.isHidden = true
        }
 
        let montoValor = reporte.monto?.decimalValue ?? 0
        if montoValor > 0 {
            cell.montoRecompensaLabel.text = formatearMonto(montoValor)
            cell.montoRecompensaLabel.isHidden = false
        } else {
            cell.montoRecompensaLabel.isHidden = true
        }
 
        let telefonoUsuario = reporte.telefonoUsuario ?? ""
        let telefonoOpcional = reporte.telefonoOpcional ?? ""
 
        if telefonoUsuario.isEmpty && telefonoOpcional.isEmpty {
            cell.comunicarseTelfefonosStackView.isHidden = true
        } else {
            cell.comunicarseTelfefonosStackView.isHidden = false
 
            if !telefonoUsuario.isEmpty {
                cell.telefonoUsuarioLabel.text = telefonoUsuario
                cell.telefonoUsuarioLabel.isHidden = false
            } else {
                cell.telefonoUsuarioLabel.isHidden = true
            }
 
            if !telefonoOpcional.isEmpty {
                cell.telefonoOpcionalLabel.text = telefonoOpcional
                cell.telefonoOpcionalLabel.isHidden = false
            } else {
                cell.telefonoOpcionalLabel.isHidden = true
            }
        }
 
        // Diferencia clave respecto a InicioViewController: modo "Mis Publicaciones"
        cell.reporteActual = reporte
        cell.configurarModoBotones(esMisPublicaciones: true)
 
        cell.accionBotonIzquierdo = { [weak self] in
            self?.finalizarReporte(reporte)
        }
 
        cell.accionBotonDerecho = { [weak self] in
            self?.irAReportesRecibidos()
        }
 
        return cell
    }
 
    // MARK: - Acciones de los botones
 
    func finalizarReporte(_ reporte: PublicacionEntity) {
        // TODO: cambiar reporte.estadoBusqueda a "Finalizado" y guardar contexto
    }
 
    func irAReportesRecibidos() {
        // No hay relación reporte→respuestas específica, así que simplemente
        // navega a la pantalla general de Reportes Recibidos
        performSegue(withIdentifier: "mostrarReportesRecibidos", sender: self)
    }
 
    // MARK: - Utilidades (mismas que InicioViewController)
 
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
 
    func formatearMonto(_ monto: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "es_PE")
 
        let numero = NSDecimalNumber(decimal: monto)
        let montoTexto = formatter.string(from: numero) ?? "\(numero)"
 
        return "¡Recompensa! S/. \(montoTexto)"
    }
}
