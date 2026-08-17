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
 
    // MARK: - Listar mis Reportes
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
 
    // MARK: - Funciones TableViewCell
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
 
        cell.reporteActual = reporte
 
        cell.accionBotonIzquierdo = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.finalizarReporte(reporte, celda: cell)
        }
 
        cell.accionBotonDerecho = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.irAVerRespuestas(celda: cell)
        }
 
        let estaFinalizado = (reporte.estadoBusqueda == "Finalizado")
        cell.actualizarIconoFinalizado(yaFinalizado: estaFinalizado)
        
        return cell
    }
 
    func irAVerRespuestas(celda: ReporteTableViewCell) {
        // Se busca el indexPath actual de esa celda específica en el momento
        // del toque (no se puede confiar en el indexPath del momento de creación,
        // porque la celda pudo haberse reutilizado para otra fila mientras tanto)
        guard let indexPath = respuestasTableView(for: celda) else { return }
     
        let reporte = misReportesList[indexPath.row]
        performSegue(withIdentifier: "mostrarVerRespuestas", sender: reporte)
    }
     
    // Encuentra el indexPath actual de una celda dada, buscándola en el table view
    func respuestasTableView(for celda: ReporteTableViewCell) -> IndexPath? {
        return misReportesTableView.indexPath(for: celda)
    }
    
    // MARK: - idPublicacion para VerRespuestasVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mostrarVerRespuestas",
           let destino = segue.destination as? VerRespuestasViewController,
           let reporte = sender as? PublicacionEntity {
            destino.idPublicacion = reporte.idPublicacion
        }
    }
    
    // MARK: - Vista detalle
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reporte = misReportesList[indexPath.row]
     
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReporteDetalleViewController") as! ReporteDetalleViewController
     
        vc.descripcion = reporte.descripcionFechaHoraPerdido ?? ""
        vc.latitud = reporte.latitud
        vc.longitud = reporte.longitud
        vc.nombreMascotaPin = reporte.nombreMascota ?? ""
     
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Acciones de los botones
    func finalizarReporte(_ reporte: PublicacionEntity, celda: ReporteTableViewCell) {
        let alerta = UIAlertController(title: "Finalizar reporte",
                                       message: "¿Está seguro de finalizar este reporte? Ya no será visible para otros usuarios",
                                       preferredStyle: .alert)
        
        let accionConfirmar = UIAlertAction(title: "Confirmar", style: .default) { _ in
            reporte.estadoBusqueda = "Finalizado"
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            do {
                try context.save()
                // La celda actualiza su propio botón izquierdo internamente
                celda.actualizarIconoFinalizado(yaFinalizado: true)
                celda.estadoBusquedaLabel?.text = "Finalizado"
            } catch {
                print("Error al guardar el estado finalizado: \(error)")
            }
        }
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alerta.addAction(accionCancelar)
        alerta.addAction(accionConfirmar)
        
        present(alerta, animated: true, completion: nil)
    }
 
    func irAReportesRecibidos() {
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
