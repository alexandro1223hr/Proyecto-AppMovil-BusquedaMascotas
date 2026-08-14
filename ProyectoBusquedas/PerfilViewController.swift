//
//  PerfilViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 7/08/26.
//

import UIKit
import CoreData

class PerfilViewController: UIViewController {

    @IBOutlet weak var sinSesionStackView: UIStackView!
    @IBOutlet weak var sesionIniciadaStackView: UIStackView!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var correoLabel: UILabel!
    @IBOutlet weak var telefonoLabel: UILabel!
    
    // Cambio de viewDidLoad a viewWillAppear para reverificar la sesión
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        verificarSesion()
    }

    func mostrarEstadoSinSesion() {
        sinSesionStackView.isHidden = false
        sesionIniciadaStackView.isHidden = true
    }

    func mostrarEstadoSesionIniciada() {
        sinSesionStackView.isHidden = true
        sesionIniciadaStackView.isHidden = false
    }
    
    func obtenerUsuarioActual() -> UsuarioEntity? {
        // Solicita ID que se guardó en UserDefaults al iniciar sesión
        guard let idString = UserDefaults.standard.string(forKey: "usuarioActualID"),
              let id = UUID(uuidString: idString) else { return nil }
        
        // CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Busca al UsuarioEntity con ID coincidente
        let request: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        // Recibe los datos para los labels
        do {
            return try context.fetch(request).first
        } catch {
            print("Error al obtener usuario: \(error)")
            return nil
        }
    }
    
    func verificarSesion() {
        if let usuario = obtenerUsuarioActual() {
            nombreLabel.text = usuario.nombre
            correoLabel.text = usuario.correo
            telefonoLabel.text = usuario.telefono
            
            mostrarEstadoSesionIniciada()
        } else {
            mostrarEstadoSinSesion()
        }
    }
    
    @IBAction func cerrarSesion(_ sender: UIButton) {
        // Remueve el ID de UserDefaults
        UserDefaults.standard.removeObject(forKey: "usuarioActualID")
        
        mostrarEstadoSinSesion()
    }
    
}
