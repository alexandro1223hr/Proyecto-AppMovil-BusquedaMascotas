//
//  LoginViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 7/08/26.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var correoTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // TestUI
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
            
    }
    
    // TestUI
    @objc func ocultarTeclado() {
        view.endEditing(true)
    }
    
    @IBAction func iniciarSesion(_ sender: UIButton) {
        let correo = correoTextField.text ?? ""
        let password = passwordTextField.text ?? ""
 
        // Validar campos vacíos
        if correo.isEmpty || password.isEmpty {
            print("Ambos campos son obligatorios")
            return
        }
 
        APIService.login(correo: correo, password: password) { [weak self] exito, mensaje, resultado in
            guard let self = self else { return }
 
            if exito, let resultado = resultado {
                self.guardarSesion(idUsuario: resultado.idUsuario, token: resultado.token)
                self.sincronizarUsuarioLocal(idUsuario: resultado.idUsuario, nombre: resultado.nombre, correo: resultado.correo, password: password)
 
                print("Sesión iniciada correctamente")
                self.navigationController?.popViewController(animated: true)
 
            } else if mensaje == "sin_conexion" {
                // Sin conexión: se intenta validar con los datos guardados
                // localmente de un login exitoso anterior
                self.intentarLoginOffline(correo: correo, password: password)
 
            } else {
                self.mostrarError(mensaje ?? "Correo o contraseña incorrectos")
            }
        }
    }
 
    // MARK: - Login sin conexión (respaldo)
 
    func intentarLoginOffline(correo: String, password: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
 
        let request: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        request.predicate = NSPredicate(format: "correo == %@ AND password == %@", correo, password)
        request.fetchLimit = 1
 
        do {
            let usuarios = try context.fetch(request)
 
            if let usuario = usuarios.first, let id = usuario.id {
                // No hay token nuevo posible sin conexión; se guarda solo
                // el id, para que la app funcione en modo local hasta que
                // vuelva la conexión y se pueda iniciar sesión de nuevo
                UserDefaults.standard.set(id.uuidString, forKey: "usuarioActualID")
 
                print("Sesión iniciada en modo sin conexión")
                navigationController?.popViewController(animated: true)
            } else {
                mostrarError("No hay conexión, y no se encontró una sesión guardada con esas credenciales")
            }
        } catch {
            print("Error al iniciar sesión sin conexión \(error)")
            mostrarError("No se pudo validar la sesión sin conexión")
        }
    }
 
    // MARK: - Guardado de sesión
 
    func guardarSesion(idUsuario: UUID, token: String) {
        UserDefaults.standard.set(idUsuario.uuidString, forKey: "usuarioActualID")
        UserDefaults.standard.set(token, forKey: "usuarioActualToken")
    }
 
    // Crea o actualiza el UsuarioEntity local para que coincida con los
    // datos confirmados por el servidor
    func sincronizarUsuarioLocal(idUsuario: UUID, nombre: String, correo: String, password: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
 
        let request: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", idUsuario as CVarArg)
        request.fetchLimit = 1
 
        do {
            let usuario = try context.fetch(request).first ?? UsuarioEntity(context: context)
 
            usuario.id = idUsuario
            usuario.nombre = nombre
            usuario.correo = correo
            usuario.password = password
 
            try context.save()
        } catch let error as NSError {
            print("Error al sincronizar usuario local: \(error), \(error.userInfo)")
        }
    }
 
    func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }
    // SCRUM-5
}
