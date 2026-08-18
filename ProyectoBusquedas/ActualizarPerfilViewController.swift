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
        guard let idString = UserDefaults.standard.string(forKey: "usuarioActualID"),
              let id = UUID(uuidString: idString) else {
                print("No existe sesión activa")
                return }
 
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
 
        let request: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
 
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
 
        guard let usuario = usuarioActual, let idUsuario = usuario.id else {
            mostrarError("No se encontró al usuario")
            return
        }
 
        guard let token = UserDefaults.standard.string(forKey: "usuarioActualToken") else {
            mostrarError("Tu sesión expiró, vuelve a iniciar sesión")
            return
        }
 
        // Validaciones
        if correo.isEmpty || telefono.isEmpty || password.isEmpty {
            mostrarError("Los campos correo, teléfono y contraseña son obligatorios")
            return
        }
 
        // La contraseña actual siempre se valida localmente primero, antes
        // de gastar una llamada a la API, ya que el servidor solo confirmará
        // lo mismo pero contra el hash real
        if password != usuario.password {
            mostrarError("La contraseña actual es incorrecta")
            return
        }
 
        var seCambiaPassword = false
        if !nuevapassword.isEmpty || !confirmarnuevapassword.isEmpty {
            if nuevapassword != confirmarnuevapassword {
                mostrarError("Las nuevas contraseñas no coinciden")
                return
            }
            if nuevapassword.isEmpty {
                mostrarError("Ingresa la nueva contraseña")
                return
            }
            seCambiaPassword = true
        }
 
        // 1. Actualizar correo y teléfono contra la API
        APIService.actualizarPerfil(
            idUsuario: idUsuario.uuidString,
            nombre: usuario.nombre ?? "",
            correo: correo,
            telefono: telefono,
            token: token
        ) { [weak self] exito, mensaje, usuarioActualizado in
            guard let self = self else { return }
 
            if exito {
                // 2. Si además se pidió cambiar la contraseña, se hace una
                // segunda llamada al endpoint específico de contraseña
                if seCambiaPassword {
                    self.actualizarPasswordEnServidor(
                        idUsuario: idUsuario,
                        passwordActual: password,
                        nuevaPassword: nuevapassword,
                        token: token,
                        correo: correo,
                        telefono: telefono
                    )
                } else {
                    self.guardarCambiosLocales(correo: correo, telefono: telefono, nuevaPassword: nil)
                }
            } else if mensaje == "sin_conexion" {
                self.mostrarError("No hay conexión a internet. Intenta nuevamente más tarde.")
            } else {
                self.mostrarError(mensaje ?? "No se pudo actualizar el perfil")
            }
        }
    }
 
    func actualizarPasswordEnServidor(idUsuario: UUID, passwordActual: String, nuevaPassword: String, token: String, correo: String, telefono: String) {
        APIService.actualizarPassword(
            idUsuario: idUsuario.uuidString,
            passwordActual: passwordActual,
            nuevaPassword: nuevaPassword,
            token: token
        ) { [weak self] exito, mensaje in
            guard let self = self else { return }
 
            if exito {
                self.guardarCambiosLocales(correo: correo, telefono: telefono, nuevaPassword: nuevaPassword)
            } else if mensaje == "sin_conexion" {
                self.mostrarError("No hay conexión a internet. El perfil se actualizó, pero la contraseña no pudo cambiarse.")
            } else {
                self.mostrarError(mensaje ?? "No se pudo actualizar la contraseña")
            }
        }
    }
 
    // Refleja en CoreData los cambios ya confirmados por el servidor
    func guardarCambiosLocales(correo: String, telefono: String, nuevaPassword: String?) {
        guard let usuario = usuarioActual else { return }
 
        usuario.correo = correo
        usuario.telefono = telefono
        if let nuevaPassword = nuevaPassword {
            usuario.password = nuevaPassword
        }
 
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
 
        do {
            try context.save()
            print("Perfil actualizado correctamente")
            navigationController?.popViewController(animated: true)
        } catch {
            mostrarError("No se pudo guardar el cambio localmente: \(error.localizedDescription)")
        }
    }
 
    @IBAction func cancelarActualizacion(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
 
    func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }
}
