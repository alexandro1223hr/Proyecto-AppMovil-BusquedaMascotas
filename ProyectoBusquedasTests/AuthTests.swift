import XCTest
import CoreData
@testable import ProyectoBusquedas

final class AuthTests: XCTestCase {
    
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        // Obtenemos el bundle donde realmente vive el modelo
        let appBundle = Bundle(for: UsuarioEntity.self)
                
        // Cargamos el modelo usando el bundle de la app en lugar de Bundle.main
        guard let model = NSManagedObjectModel.mergedModel(from: [appBundle]) else {
            fatalError("No se pudo cargar el modelo de Core Data desde el bundle de la app.")
        }
                
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
                 
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
    }

    override func tearDownWithError() throws {
        context = nil
    }

    // MARK: - 1. Registro de Usuario
    func testRegistroDeUsuarioExitoso() throws {
        // Given: Los datos ingresados en el formulario de registro
        let nuevoUsuario = UsuarioEntity(context: context)
        nuevoUsuario.id = UUID()
        nuevoUsuario.correo = "lala@gmail.com"
        nuevoUsuario.password = "123"
        nuevoUsuario.nombre = "Lala"

        // When: Se guarda en CoreData
        try context.save()

        // Then: Verificamos que se haya guardado correctamente
        let fetchRequest: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "correo == %@", "lala@gmail.com")
        
        let resultados = try context.fetch(fetchRequest)
        
        XCTAssertEqual(resultados.count, 1, "Debería existir exactamente 1 usuario con ese correo")
        XCTAssertEqual(resultados.first?.nombre, "Lala", "El nombre guardado debe coincidir")
    }

    // MARK: - 2. Inicio de Sesión - exitoso
    func testLoginExitoso() throws {
        // Given: Un usuario que ya existe en la base de datos
        let usuario = UsuarioEntity(context: context)
        usuario.correo = "lala@gmail.com"
        usuario.password = "123"
        try context.save()

        // When: El usuario intenta iniciar sesión con credenciales correctas
        let fetchRequest: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "correo == %@ AND password == %@", "lala@gmail.com", "123")
        
        let usuarioLogueado = try context.fetch(fetchRequest).first

        // Then: La consulta debe devolver un usuario
        XCTAssertNotNil(usuarioLogueado, "El login debería ser exitoso y devolver el usuario")
    }

    // MARK: - 3. Inicio de Sesión - incorrecto
    func testLoginFallidoContrasenaIncorrecta() throws {
        // Given: Un usuario registrado
        let usuario = UsuarioEntity(context: context)
        usuario.correo = "lala@gmail.com"
        usuario.password = "rea123"
        try context.save()

        // When: Intenta iniciar sesión con una contraseña incorrecta
        let fetchRequest: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "correo == %@ AND password == %@", "lala@gmail.com", "real123")
        
        let usuarioLogueado = try context.fetch(fetchRequest).first

        // Then: La consulta NO debe devolver ningún usuario
        XCTAssertNil(usuarioLogueado, "El login debe fallar (ser nil) si la contraseña no coincide")
    }

    // MARK: - 4. Actualización (Cambio de Contraseña)
    func testCambioDeContrasena() throws {
        // Given: Un usuario existente
        let usuario = UsuarioEntity(context: context)
        usuario.correo = "lala@gmail.com"
        usuario.password = "123"
        try context.save()

        // When: El usuario solicita actualizar su contraseña
        usuario.password = "realize123"
        try context.save()

        // Then: Buscamos al usuario de nuevo para confirmar el cambio
        let fetchRequest: NSFetchRequest<UsuarioEntity> = UsuarioEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "correo == %@", "lala@gmail.com")
        
        let usuarioActualizado = try context.fetch(fetchRequest).first
        
        XCTAssertEqual(usuarioActualizado?.password, "realize123", "La contraseña en la base de datos debería haberse actualizado")
    }
}
