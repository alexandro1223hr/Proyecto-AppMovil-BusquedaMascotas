//
//  RegistroViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 7/08/26.
//

import UIKit
import CoreData

class RegistroViewController: UIViewController {

    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var correoTextField: UITextField!
    @IBOutlet weak var telefonoTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmarPasswordTextField: UITextField!
    
    var usuarios: [UsuarioEntity] = []
    
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
    
    @IBAction func registrarUsuario(_ sender: UIButton) {
        let nombre = nombreTextField.text ?? ""
        let correo = correoTextField.text ?? ""
        let telefono = telefonoTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let confirmarPassword = confirmarPasswordTextField.text ?? ""
        
        // Validar campos vacíos
        if nombre.isEmpty || correo.isEmpty || telefono.isEmpty ||
            password.isEmpty || confirmarPassword.isEmpty {
            print("Todos los campos son obligatorios")
            return
        }
        
        // Validar contraseñas iguales en ambos campos
        if password != confirmarPassword {
            print("Las contraseñas no coinciden")
            return
        }
        
        
        // El registro se hace contra la API (siempre requiere conexión,
        // no tiene sentido crear un usuario "offline" que el servidor no conoce)
        APIService.registrar(nombre: nombre, correo: correo, telefono: telefono, password: password) { [weak self] exito, mensaje, usuario in
            guard let self = self else { return }
 
            if exito, let usuario = usuario {
                // Registro en API y CoreData
                self.guardarUsuarioLocal(usuario: usuario, password: password)
 
                print("Usuario registrado correctamente")
                self.navigationController?.popViewController(animated: true)
 
            } else if mensaje == "sin_conexion" {
                self.mostrarError("No hay conexión a internet. Intenta nuevamente más tarde.")
            } else {
                self.mostrarError(mensaje ?? "No se pudo registrar el usuario")
            }
        }
    }
 
    // Crea el UsuarioEntity local con los datos confirmados por el servidor
    func guardarUsuarioLocal(usuario: Usuario, password: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
 
        let nuevoUsuario = UsuarioEntity(context: context)
 
        nuevoUsuario.id = usuario.id
        nuevoUsuario.nombre = usuario.nombre
        nuevoUsuario.correo = usuario.correo
        nuevoUsuario.telefono = usuario.telefono ?? ""
        nuevoUsuario.password = password
 
        do {
            try context.save()
        } catch let error as NSError {
            print("Error al guardar usuario localmente: \(error), \(error.userInfo)")
        }
    }
 
    func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }
    // SCRUM-3
}
