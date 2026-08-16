//
//  InicioViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 7/08/26.
//

import UIKit
import CoreData

class InicioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {

    @IBOutlet weak var ReportesTableView: UITableView!
    @IBOutlet weak var barraBusqueda: UISearchBar!
    @IBOutlet weak var menuLateralButton: UIBarButtonItem!
    
    var reportesPublicadosList: [PublicacionEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarMenuLateral(modoOscuroActivado: false)
        
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
    
    func configurarMenuLateral(modoOscuroActivado: Bool) {
        //Crear la opción de Modo Oscuro con el estado dinámico
        let opcionModoOscuro = UIAction(title: "Modo Oscuro",image: UIImage(systemName: "moon"), state: modoOscuroActivado ? .on : .off
        ) { [weak self] action in
            guard let self = self else { return }
            
            let nuevoEstado = !modoOscuroActivado
            //Cambiar el tema en la app
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = nuevoEstado ? .dark : .light
            }
            //Reconstruir el menú
            self.configurarMenuLateral(modoOscuroActivado: nuevoEstado)
        }
        // Mantener desplegado
        opcionModoOscuro.attributes = .keepsMenuPresented
        // Cada opción dispara su propio segue hacia la pantalla correspondiente
        let opcion1 = UIAction(title: "Reportes publicados") { [weak self] _ in
            self?.performSegue(withIdentifier: "mostrarReportesPublicados", sender: self)
        }
        let opcion2 = UIAction(title: "Reportes recibidos") { [weak self] _ in
            self?.performSegue(withIdentifier: "mostrarReportesRecibidos", sender: self)
        }
        let opcion3 = UIAction(title: "Mapa general") { [weak self] _ in
            self?.performSegue(withIdentifier: "mostrarMapaGeneral", sender: self)
        }
        // Menu
        let menu = UIMenu(title: "Opciones", children: [opcion1, opcion2, opcion3, opcionModoOscuro])
        
        menuLateralButton.menu = menu
    }
    
    func configuracionInicial() {
        // Reemplaza el titulo del Navigation Bar(zona superior) por la barra de busqueda
        navigationItem.titleView = barraBusqueda
        barraBusqueda.placeholder = "Buscar"
        barraBusqueda.delegate = self
        
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
            cell.actualizacionStackView.isHidden = false

            cell.fechaHoraActualizacionLabel.text =
                tiempoTranscurrido(desde: fechaActualizacion)
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
     
        // Convierte Binary Data a UIImage
        if let datosImagen = reporte.fotoMascota {
            cell.fotoMascotaImageView.image = UIImage(data: datosImagen)
        } else {
            cell.fotoMascotaImageView.image = UIImage(named: "imagenMascotaDefault")
        }
     
        // Comportamiendo tipo hidden para el 2do tipo de publicacion
        if let nombreMascota = reporte.nombreMascota, !nombreMascota.isEmpty {
            cell.nombreMascotaLabel.text = nombreMascota
            cell.nombreMascotaLabel.isHidden = false
        } else {
            cell.nombreMascotaLabel.isHidden = true
        }
     
        //
        let montoValor = reporte.monto?.decimalValue ?? 0
        if montoValor > 0 {
            cell.montoRecompensaLabel.text = formatearMonto(montoValor)
            cell.montoRecompensaLabel.isHidden = false
        } else {
            cell.montoRecompensaLabel.isHidden = true
        }
     
        //
        let telefonoUsuario = reporte.telefonoUsuario ?? ""
        let telefonoOpcional = reporte.telefonoOpcional ?? ""
     
        if telefonoUsuario.isEmpty && telefonoOpcional.isEmpty {
            // Ninguno de los dos teléfonos existe: se oculta todo el stack view
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
         
        let yaGuardado = publicacionEstaGuardada(reporte)
        cell.configurarModoBotones(esMisPublicaciones: false, yaGuardado: yaGuardado)
         
        cell.accionBotonIzquierdo = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.alternarGuardado(reporte, celda: cell)
        }
         
        cell.accionBotonDerecho = { [weak self] in
            self?.responderPublicacion(reporte)
        }
        
        return cell
    }
    
    // MARK: Vista detalle
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reporte = reportesPublicadosList[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReporteDetalleViewController") as! ReporteDetalleViewController
        
        vc.descripcion = reporte.descripcionFechaHoraPerdido ?? ""
        vc.latitud = reporte.latitud
        vc.longitud = reporte.longitud
        vc.nombreMascotaPin = reporte.nombreMascota ?? ""
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Listar Reportes
    
    func listarReportesPublicados(filtro: String = "") {
        // CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Busca las publicaciones
        let request: NSFetchRequest<PublicacionEntity> = PublicacionEntity.fetchRequest()
        
        // Define texto para filtrar
        let texto = filtro.trimmingCharacters(in: .whitespacesAndNewlines)
        if !texto.isEmpty {
            // [cd] Ignora mayusculas y tildes
            let filtrarCiudad = NSPredicate(format: "ciudadDistrito CONTAINS[cd] %@", texto)
            let filtrarMascota = NSPredicate(format: "nombreMascota CONTAINS[cd] %@", texto)
            let filtrarUsuario = NSPredicate(format: "nombreUsuario CONTAINS[cd] %@", texto)
            let filtrarEstado = NSPredicate(format: "estadoBusqueda CONTAINS[cd] %@", texto)
            
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                filtrarCiudad, filtrarMascota, filtrarUsuario, filtrarEstado
            ])
        }
        
        // Las ordena por fecha mas reciente
        let orden = NSSortDescriptor(
                key: "fechaHoraPublicacion",
                ascending: false
            )
        request.sortDescriptors = [orden]
        
        do {
            let results = try
            managedContext.fetch(request)
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

        return "¡Recompensa! S/. \(montoTexto)"
    }
    
    func guardarPublicacion(_ reporte: PublicacionEntity) {
        // TODO: crear PublicacionGuardadaEntity
    }

    // Revisa si el usuario actual ya guardó esta publicación específica
    func publicacionEstaGuardada(_ reporte: PublicacionEntity) -> Bool {
        guard let idUsuarioString = UserDefaults.standard.string(forKey: "usuarioActualID"),
              let idUsuario = UUID(uuidString: idUsuarioString),
              let idPublicacion = reporte.idPublicacion else {
            return false
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
            return try context.fetch(request).first != nil
        } catch {
            print("Error al verificar si está guardada: \(error)")
            return false
        }
    }
     
    // Alterna el estado guardado: si ya estaba guardada la quita, si no, la guarda.
    // Actualiza el ícono de inmediato sobre la celda visible, sin esperar a
    // recargar toda la tabla.
    func alternarGuardado(_ reporte: PublicacionEntity, celda: ReporteTableViewCell) {
        guard let idUsuarioString = UserDefaults.standard.string(forKey: "usuarioActualID"),
              let idUsuario = UUID(uuidString: idUsuarioString) else {
            mostrarError("Debes iniciar sesión para guardar una publicación")
            return
        }
     
        guard let idPublicacion = reporte.idPublicacion else { return }
     
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
            let existentes = try context.fetch(request)
     
            if let guardado = existentes.first {
                // Ya estaba guardada: se elimina
                context.delete(guardado)
                try context.save()
                celda.actualizarIconoGuardado(yaGuardado: false)
            } else {
                // No estaba guardada: se crea
                let nuevoGuardado = PublicacionGuardadaEntity(context: context)
                nuevoGuardado.id = UUID()
                nuevoGuardado.idUsuario = idUsuario
                nuevoGuardado.idPublicacion = idPublicacion
                nuevoGuardado.fechaGuardado = Date()
     
                try context.save()
                celda.actualizarIconoGuardado(yaGuardado: true)
            }
        } catch {
            mostrarError("No se pudo actualizar el guardado: \(error.localizedDescription)")
        }
    }
     
    func responderPublicacion(_ reporte: PublicacionEntity) {
        // TODO: navegar a pantalla de responder / contacto
    }
     
    func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }
    
    
    // MARK: Funciones para la Barra de busqueda
    // Se ejecuta cuando el usuario presiona el botón "Buscar" del teclado
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        listarReportesPublicados(filtro: searchBar.text ?? "")
    }
     
    // Se ejecuta si el usuario borra todo el texto y la barra queda vacía;
    // sin esto, tendría que presionar "Buscar" con el campo vacío para
    // volver a ver todas las publicaciones
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if (searchBar.text ?? "").isEmpty {
            listarReportesPublicados(filtro: "")
        }
    }
    
}
