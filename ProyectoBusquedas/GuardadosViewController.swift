//
//  GuardadosViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 7/08/26.
//

import UIKit
import CoreData

class GuardadosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var guardadosTableView: UITableView!
    
    var guardadosList: [PublicacionEntity] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        guardadosTableView.dataSource = self
        guardadosTableView.delegate = self
 
        listarGuardados()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listarGuardados()
    }
 
    // Trae las PublicacionEntity cuyo idPublicacion aparece en
    // PublicacionGuardadaEntity para el usuario actual
    func listarGuardados() {
        guard let idUsuarioString = UserDefaults.standard.string(forKey: "usuarioActualID"),
              let idUsuario = UUID(uuidString: idUsuarioString) else {
            guardadosList = []
            guardadosTableView.reloadData()
            return
        }
 
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
 
        // 1. Buscar todos los registros de guardado del usuario actual
        let requestGuardados: NSFetchRequest<PublicacionGuardadaEntity> = PublicacionGuardadaEntity.fetchRequest()
        requestGuardados.predicate = NSPredicate(format: "idUsuario == %@", idUsuario as CVarArg)
 
        let ordenGuardados = NSSortDescriptor(key: "fechaGuardado", ascending: false)
        requestGuardados.sortDescriptors = [ordenGuardados]
 
        do {
            let guardados = try context.fetch(requestGuardados)
            let idsPublicacionesGuardadas = guardados.compactMap { $0.idPublicacion }
 
            if idsPublicacionesGuardadas.isEmpty {
                guardadosList = []
                guardadosTableView.reloadData()
                return
            }
 
            // 2. Buscar las publicaciones que coincidan con esos IDs
            let requestPublicaciones: NSFetchRequest<PublicacionEntity> = PublicacionEntity.fetchRequest()
            requestPublicaciones.predicate = NSPredicate(
                format: "idPublicacion IN %@",
                idsPublicacionesGuardadas
            )
 
            let publicaciones = try context.fetch(requestPublicaciones)
 
            // 3. Reordenar según el orden de guardado (más reciente primero),
            // ya que el IN de arriba no garantiza mantener ese orden
            guardadosList = idsPublicacionesGuardadas.compactMap { id in
                publicaciones.first { $0.idPublicacion == id }
            }
 
        } catch let error as NSError {
            print("No fue posible listar los guardados \(error), \(error.userInfo)")
            guardadosList = []
        }
 
        guardadosTableView.reloadData()
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guardadosList.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reporteCell", for: indexPath) as! ReporteTableViewCell
 
        let reporte = guardadosList[indexPath.row]
 
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
 
        // Modo Inicio (Guardar/Responder). Como esta pantalla lista solo
        // publicaciones guardadas, yaGuardado siempre es true al construir la celda.
        cell.reporteActual = reporte
        cell.configurarModoBotones(esMisPublicaciones: false, yaGuardado: true)
 
        cell.accionBotonIzquierdo = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.quitarDeGuardados(reporte, celda: cell)
        }
 
        cell.accionBotonDerecho = { [weak self] in
            self?.responderPublicacion(reporte)
        }
 
        return cell
    }
 
    // MARK: - Vista detalle
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reporte = guardadosList[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReporteDetalleViewController") as! ReporteDetalleViewController

        vc.descripcion = reporte.descripcionFechaHoraPerdido ?? ""
        vc.latitud = reporte.latitud
        vc.longitud = reporte.longitud
        vc.nombreMascotaPin = reporte.nombreMascota ?? ""

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Acciones
 
    // A diferencia de InicioViewController, aquí "quitar" también debe sacar
    // la fila de la tabla, no solo cambiar el ícono, ya que esta pantalla
    // solo muestra publicaciones guardadas
    func quitarDeGuardados(_ reporte: PublicacionEntity, celda: ReporteTableViewCell) {
        guard let idUsuarioString = UserDefaults.standard.string(forKey: "usuarioActualID"),
              let idUsuario = UUID(uuidString: idUsuarioString),
              let idPublicacion = reporte.idPublicacion else {
            return
        }
 
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
 
        let request: NSFetchRequest<PublicacionGuardadaEntity> = PublicacionGuardadaEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "idUsuario == %@ AND idPublicacion == %@",
            idUsuario as CVarArg,
            idPublicacion as CVarArg
        )
        request.fetchLimit = 1
 
        do {
            if let guardado = try context.fetch(request).first {
                context.delete(guardado)
                try context.save()
            }
 
            // Se quita de la lista local y se recarga la tabla para que
            // desaparezca la fila (no basta con cambiar el ícono aquí)
            guardadosList.removeAll { $0.idPublicacion == idPublicacion }
            guardadosTableView.reloadData()
 
        } catch {
            mostrarError("No se pudo quitar de guardados: \(error.localizedDescription)")
        }
    }
 
    func responderPublicacion(_ reporte: PublicacionEntity) {
        // TODO: navegar a pantalla de responder / contacto
    }
 
    // MARK: - Utilidades
 
    func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }
 
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
