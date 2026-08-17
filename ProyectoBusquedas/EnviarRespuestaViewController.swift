//
//  EnviarRespuestaViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 15/08/26.
//

import UIKit
import CoreData

class EnviarRespuestaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var descripcionPosibleAvistamientoTextView: UITextView!
    @IBOutlet weak var ubicacionAvistadoTextField: UITextField!
    @IBOutlet weak var fotoMascotaAvistadaImageView: UIImageView!
    
    var idPublicacion: UUID?
    var latitudSeleccionada: Double?
    var longitudSeleccionada: Double?
    var imagenSeleccionada: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fotoMascotaAvistadaImageView.contentMode = .scaleToFill
        fotoMascotaAvistadaImageView.clipsToBounds = true
    }
    
    // MARK: - Ubicación

    // Identifier del segue: "unwindAEnviarRespuesta"
    @IBAction func regresarConUbicacionAvistamiento(_ segue: UIStoryboardSegue) {
        guard let origen = segue.source as? SeleccionarUbicacionViewController else { return }
 
        if let lat = origen.latitudConfirmada, let lon = origen.longitudConfirmada {
            latitudSeleccionada = lat
            longitudSeleccionada = lon
            ubicacionAvistadoTextField.text = origen.textoReferenciaConfirmado
        }
    }
 
    // El botón "marcarUbicacionButton" tiene un segue 'show' conectado
    // directamente en el storyboard hacia SeleccionarUbicacionViewController.
    // Antes de que ocurra, prepare(for:sender:) le indica a cuál unwind volver.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mostrarSeleccionarUbicacionDesdeRespuesta",
           let destino = segue.destination as? SeleccionarUbicacionViewController {
            destino.identifierUnwindDestino = "unwindAEnviarRespuesta"
        }
    }
    
    // MARK: - Foto de la mascota avistada
    @IBAction func seleccionarFotoButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Foto del avistamiento", message: nil, preferredStyle: .actionSheet)
 
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Tomar foto", style: .default) { _ in
                self.abrirImagePicker(sourceType: .camera)
            })
        }
 
        alert.addAction(UIAlertAction(title: "Elegir de la galería", style: .default) { _ in
            self.abrirImagePicker(sourceType: .photoLibrary)
        })
 
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
 
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
 
        present(alert, animated: true)
    }
 
    func abrirImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
 
    func imagePickerController(_ picker: UIImagePickerController,
                                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let imagenElegida = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
 
        if let imagen = imagenElegida {
            imagenSeleccionada = imagen
            fotoMascotaAvistadaImageView.image = imagen
        }
 
        picker.dismiss(animated: true)
    }
 
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
 
    // MARK: - Registrar respuesta
 
    @IBAction func registrarRespuesta(_ sender: UIButton) {
        let descripcion = descripcionPosibleAvistamientoTextView.text ?? ""
        let ubicacionAvistado = ubicacionAvistadoTextField.text ?? ""
 
        // 1. Validar sesión activa
        guard let idUsuarioString = UserDefaults.standard.string(forKey: "usuarioActualID"),
              let idUsuario = UUID(uuidString: idUsuarioString) else {
            mostrarError("Debes iniciar sesión para enviar una respuesta")
            return
        }
 
        // 2. Validar que se sepa a qué publicación se está respondiendo
        guard let idPublicacion = idPublicacion else {
            mostrarError("No se pudo identificar la publicación a responder")
            return
        }
 
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
 
        // Se busca el UsuarioEntity real para poder asignar la relación
        let requestUsuario: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        requestUsuario.predicate = NSPredicate(format: "id == %@", idUsuario as CVarArg)
        requestUsuario.fetchLimit = 1
 
        guard let usuario = try? context.fetch(requestUsuario).first else {
            mostrarError("No se pudo verificar tu usuario")
            return
        }
 
        // 3. Validar campos obligatorios
        if descripcion.isEmpty {
            mostrarError("Describe el posible avistamiento")
            return
        }
        if ubicacionAvistado.isEmpty || latitudSeleccionada == nil || longitudSeleccionada == nil {
            mostrarError("Marca la ubicación donde viste a la mascota")
            return
        }
 
        // 4. Crear la respuesta en CoreData
        let respuesta = RespuestaEntity(context: context)
 
        respuesta.idRespuesta = UUID()
        respuesta.idPublicacion = idPublicacion
        respuesta.descripcion = descripcion
        respuesta.ubicacionAvistado = ubicacionAvistado
        respuesta.latitud = latitudSeleccionada ?? 0.0
        respuesta.longitud = longitudSeleccionada ?? 0.0
        respuesta.fechaHoraRespuesta = Date()
 
        if let imagen = imagenSeleccionada {
            respuesta.fotoMascota = imagen.jpegData(compressionQuality: 0.7)
        }
 
        // Relación hacia el usuario que responde (To One)
        respuesta.usuario = usuario
 
        // 5. Guardar
        do {
            try context.save()
            print("Respuesta registrada correctamente")
            navigationController?.popViewController(animated: true)
        } catch {
            context.delete(respuesta)
            mostrarError("No se pudo guardar la respuesta: \(error.localizedDescription)")
        }
    }
 
    // MARK: - Utilidades
 
    func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }
}
