//
//  ActualizarPerfilViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 10/08/26.
//

import UIKit
import CoreData

class ActualizarPerfilViewController: UIViewController {

    @IBOutlet weak var correoTextField: UITextField!
    @IBOutlet weak var telefonoTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nuevaPasswordTextField: UITextField!
    @IBOutlet weak var confirmarNuevaPasswordTextField: UITextField!
    
    var usuarioActual: UsuarioEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cargarDatosUsuario()
    }
    
    func cargarDatosUsuario() {
        // Solicita ID que se guardó en UserDefaults de la sesión iniciada
        guard let idString = UserDefaults.standard.string(forKey: "usuarioActualID"),
              let id = UUID(uuidString: idString) else { 
                print("No existe sesión activa")
                return }
        
        // CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Busca UsuarioEntity con ID coincidente
        let request: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        // Carga los datos del usuario en los TextField
        do {
            usuarioActual = try context.fetch(request).first
            if let usuario = usuarioActual {
                correoTextField.text = usuario.correo
                telefonoTextField.text = usuario.telefono
            }
        } catch {
            print("Error al obtener usuario: \(error)")
        }
    }
    
    
    @IBAction func confirmarActualizacion(_ sender: UIButton) {
        let correo = correoTextField.text ?? ""
        let telefono = telefonoTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let nuevapassword = nuevaPasswordTextField.text ?? ""
        let confirmarnuevapassword = confirmarNuevaPasswordTextField.text ?? ""
        
        // Valida el usuario activo
        guard let usuario = usuarioActual else { print("No se encontró al usuario")
            return }
        
        // Validaciones
        if correo.isEmpty || telefono.isEmpty || password.isEmpty {
            print("Los campos correo, teléfono y contraseña son obligatorios")
            return
        }
        if !nuevapassword.isEmpty || !confirmarnuevapassword.isEmpty {
            if password != usuario.password {
                print("La contraseña actual es incorrecta")
                return
            }
            if nuevapassword != confirmarnuevapassword {
                print("Las nuevas contraseñas no coinciden")
                return
            }
            if nuevapassword.isEmpty {
                print("Ingresa la nueva contraseña")
                return
            }
            // Establece nueva contraseña
            usuario.password = nuevapassword
        }

        // Actualiza los datos nuevos
        usuario.correo = correo
        usuario.telefono = telefono
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            try context.save()
            print("Perfil actualizado correctamente")
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error al actualizar el perfil: \(error)")
        }
    }
    
    @IBAction func cancelarActualizacion(_ sender: UIButton) {
        // Regresa al Perfil
        navigationController?.popViewController(animated: true)
    }
}
