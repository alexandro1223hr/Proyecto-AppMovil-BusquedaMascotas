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
    }
    
    @IBAction func iniciarSesion(_ sender: UIButton) {
        let correo = correoTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        // Validar campos vacíos
        if correo.isEmpty || password.isEmpty {
            print("Ambos campos son obligatorios")
            return
        }
        
        // CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Busca un UsuarioEntity que tenga correo y contraseña coincidentes
        let request: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        request.predicate = NSPredicate(format: "correo == %@ AND password == %@", correo, password)
        request.fetchLimit = 1
        
        // Crea la sesión y guarda ID en UserDefaults
        do {
            let usuarios = try context.fetch(request)
            
            if let usuario = usuarios.first {
                UserDefaults.standard.set(
                    usuario.id?.uuidString,
                    forKey: "usuarioActualID"
                )
                print("Sesión iniciada correctamente")
            } else {
                print("Correo o contraseña incorrectos")
            }
        } catch {
            print("Error al iniciar sesión \(error)")
        }
        
        // Quita el View Controller actual y vuelve al anterior
        navigationController?.popViewController(animated: true)
    }
    
}
