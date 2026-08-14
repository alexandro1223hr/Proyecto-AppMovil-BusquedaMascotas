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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Registrar usuario
        let usuario = UsuarioEntity(context: context)
        
        usuario.id = UUID()
        usuario.nombre = nombre
        usuario.correo = correo
        usuario.telefono = telefono
        usuario.password = password
        
        do {
            try context.save()
            print("Usuario registrado correctamente")
        } catch let error as NSError {
            print("Error al guardar usuario: \(error), \(error.userInfo)")
        }
        
        // Quita el View Controller actual y vuelve al anterior
        navigationController?.popViewController(animated: true)
    }
    // SCRUM-2
}
