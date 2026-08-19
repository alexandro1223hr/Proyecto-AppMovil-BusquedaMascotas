//
//  PublicarReporteViewController.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 12/08/26.
//

import UIKit
import CoreData

class PublicarReporteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var seleccionarEstadoButton: UIButton!
    @IBOutlet weak var ciudadDistritoTextField: UITextField!
    @IBOutlet weak var descripcionFechaHoraTextField: UITextField!
    @IBOutlet weak var ubicacionTextField: UITextField!
    @IBOutlet weak var nombreMascotaTextField: UITextField!
    @IBOutlet weak var caracteristicaMascota1TextField: UITextField!
    @IBOutlet weak var caracteristicaMascota2TextField: UITextField!
    @IBOutlet weak var caracteristicaMascota3TextField: UITextField!
    @IBOutlet weak var fotoMascotaImageView: UIImageView!
    @IBOutlet weak var telefonoUsuarioTextField: UITextField!
    @IBOutlet weak var telefonoOpcionalTextField: UITextField!
    @IBOutlet weak var montoRecompensaTextField: UITextField!

    // Guarda el estado seleccionado del menú (texto real a guardar en CoreData,
    // separado del texto decorativo que se muestra en el botón)
    var estadoBusquedaSeleccionado: String = ""

    // Coordenadas seleccionadas en el mapa (nil hasta que el usuario elija una ubicación).
    // Se llenan en regresarConUbicacionSeleccionada cuando el usuario vuelve del mapa.
    var latitudSeleccionada: Double?
    var longitudSeleccionada: Double?

    // Imagen elegida por el usuario para la foto de la mascota
    var imagenSeleccionada: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        configurarMenuEstado()

        fotoMascotaImageView.contentMode = .scaleAspectFill
        fotoMascotaImageView.clipsToBounds = true
    }

    func configurarMenuEstado() {
        // El primer item es un placeholder visual, no un valor válido a guardar
        let opcionPorDefecto = UIAction(title: "Seleccionar                  ▼", state: .on) { _ in
            self.estadoBusquedaSeleccionado = ""
        }
        let opcionSeBusca = UIAction(title: "Se busca") { _ in
            self.estadoBusquedaSeleccionado = "Se busca"
        }
        let opcionEncontrado = UIAction(title: "Encontrado") { _ in
            self.estadoBusquedaSeleccionado = "Encontrado"
        }
        /*
        let opcionFinalizado = UIAction(title: "Finalizado") { _ in
            self.estadoBusquedaSeleccionado = "Finalizado"
        }
        */

        seleccionarEstadoButton.menu = UIMenu(children: [opcionPorDefecto, opcionSeBusca, opcionEncontrado])
        seleccionarEstadoButton.showsMenuAsPrimaryAction = true
        seleccionarEstadoButton.changesSelectionAsPrimaryAction = true

        seleccionarEstadoButton.layer.cornerRadius = 5.0
        seleccionarEstadoButton.layer.borderWidth = 1.0
        seleccionarEstadoButton.layer.borderColor = UIColor.systemGray4.cgColor
    }

    // MARK: - Ubicación

    //
    @IBAction func regresarConUbicacionSeleccionada(_ segue: UIStoryboardSegue) {
        guard let origen = segue.source as? SeleccionarUbicacionViewController else { return }

        if let lat = origen.latitudConfirmada, let lon = origen.longitudConfirmada {
            latitudSeleccionada = lat
            longitudSeleccionada = lon
            ubicacionTextField.text = origen.textoReferenciaConfirmado
        }
    }

    
    // MARK: - Foto de la mascota
    @IBAction func seleccionarFotoMascota(_ sender: UIButton) {
        let alert = UIAlertController(title: "Foto de la mascota", message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Tomar foto", style: .default) { _ in
                self.abrirImagePicker(sourceType: .camera)
            })
        }

        alert.addAction(UIAlertAction(title: "Elegir de la galería", style: .default) { _ in
            self.abrirImagePicker(sourceType: .photoLibrary)
        })

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        // Necesario en iPad para que el actionSheet no truene al no tener un origen claro
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

    // Delegate de UIImagePickerController. La clase conforma el protocolo
    // directamente en su declaración (arriba), sin usar extension.
    func imagePickerController(_ picker: UIImagePickerController,
                                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let imagenElegida = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)

        if let imagen = imagenElegida {
            imagenSeleccionada = imagen
            fotoMascotaImageView.image = imagen
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    // MARK: - Publicar reporte

    @IBAction func publicarReporte(_ sender: UIButton) {
        // 1. Recolectar valores de los campos
        let ciudadDistrito = ciudadDistritoTextField.text ?? ""
        let descripcionFechaHora = descripcionFechaHoraTextField.text ?? ""
        let ubicacionPerdido = ubicacionTextField.text ?? ""
        let nombreMascota = nombreMascotaTextField.text ?? ""
        let caracteristica1 = caracteristicaMascota1TextField.text ?? ""
        let caracteristica2 = caracteristicaMascota2TextField.text ?? ""
        let caracteristica3 = caracteristicaMascota3TextField.text ?? ""
        let telefonoUsuario = telefonoUsuarioTextField.text ?? ""
        let telefonoOpcional = telefonoOpcionalTextField.text ?? ""
        let montoTexto = montoRecompensaTextField.text ?? ""

        // 2. Validar sesión activa (se necesita el usuario dueño de la publicación)
        guard let idUsuarioString = UserDefaults.standard.string(forKey: "usuarioActualID"),
              let idUsuario = UUID(uuidString: idUsuarioString) else {
            mostrarError("Debes iniciar sesión para publicar un reporte")
            return
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        // Se busca el usuario para copiar su nombre en la publicación
        // (nombreUsuario está desnormalizado en PublicacionEntity para listados rápidos)
        let requestUsuario: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        requestUsuario.predicate = NSPredicate(format: "id == %@", idUsuario as CVarArg)
        requestUsuario.fetchLimit = 1

        guard let usuario = try? context.fetch(requestUsuario).first else {
            mostrarError("No se pudo verificar tu usuario")
            return
        }

        // 3. Validar campos obligatorios
        if estadoBusquedaSeleccionado.isEmpty {
            mostrarError("Selecciona el estado del reporte")
            return
        }
        if ciudadDistrito.isEmpty {
            mostrarError("Indica la ciudad o distrito")
            return
        }
        if descripcionFechaHora.isEmpty {
            mostrarError("Describe cuándo y dónde se perdió la mascota")
            return
        }
         
        // 4. Validar y convertir el monto (opcional, pero si se ingresa debe ser válido)
        var montoDecimal: Decimal = 0
        if !montoTexto.isEmpty {
            guard let monto = Decimal(string: montoTexto.replacingOccurrences(of: ",", with: ".")) else {
                mostrarError("El monto de la recompensa no es válido")
                return
            }
            montoDecimal = monto
        }

        // 5. Crear la publicación en CoreData
        let publicacion = PublicacionEntity(context: context)

        publicacion.idPublicacion = UUID()
        publicacion.idUsuario = idUsuario
        publicacion.nombreUsuario = usuario.nombre

        let ahora = Date()
        publicacion.fechaHoraPublicacion = ahora
        publicacion.fechaHoraActualizacion = nil

        publicacion.estadoBusqueda = estadoBusquedaSeleccionado

        publicacion.ciudadDistrito = ciudadDistrito
        publicacion.descripcionFechaHoraPerdido = descripcionFechaHora
        publicacion.ubicacionPerdido = ubicacionPerdido
        publicacion.latitud = latitudSeleccionada ?? 0.0
        publicacion.longitud = longitudSeleccionada ?? 0.0

        publicacion.nombreMascota = nombreMascota

        publicacion.caracteristicaMascota1 = caracteristica1
        publicacion.caracteristicaMascota2 = caracteristica2
        publicacion.caracteristicaMascota3 = caracteristica3

        // La foto es opcional; si no se eligió ninguna, se guarda nil
        if let imagen = imagenSeleccionada {
            publicacion.fotoMascota = imagen.jpegData(compressionQuality: 0.7)
        }

        publicacion.telefonoUsuario = telefonoUsuario
        publicacion.telefonoOpcional = telefonoOpcional.isEmpty ? nil : telefonoOpcional

        publicacion.monto = montoDecimal as NSDecimalNumber

        // 6. Guardar
        do {
            try context.save()
            print("Publicación registrada correctamente")
            navigationController?.popViewController(animated: true)
        } catch {
            context.delete(publicacion)
            mostrarError("No se pudo guardar la publicación: \(error.localizedDescription)")
        }
    }

    // MARK: - Utilidades

    func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }
}
// SCRUM-5
