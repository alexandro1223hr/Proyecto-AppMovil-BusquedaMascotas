import XCTest
import CoreData
@testable import ProyectoBusquedas

final class RelacionesTests: XCTestCase {
    
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        let appBundle = Bundle(for: PublicacionGuardadaEntity.self)
                
        guard let modelURL = appBundle.url(forResource: "BusquedasDataModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("No se pudo cargar el modelo de Core Data desde el archivo .momd en el bundle.")
                }
                         
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
                         
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
    }

    override func tearDownWithError() throws {
        context = nil
    }

    // MARK: - 1. Guardar publicación
    func testAgregarPublicacionAGuardados() throws {
        let idMiUsuario = UUID()
        let idPublicacionAjena = UUID()
        
        // When: Guardo la publicación
        let guardado = PublicacionGuardadaEntity(context: context)
        guardado.id = UUID()
        guardado.idUsuario = idMiUsuario
        guardado.idPublicacion = idPublicacionAjena
        try context.save()
        
        // Then: Verifico que esté en mi lista
        let fetchRequest: NSFetchRequest<PublicacionGuardadaEntity> = PublicacionGuardadaEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idUsuario == %@", idMiUsuario as CVarArg)
        
        let misGuardados = try context.fetch(fetchRequest)
        XCTAssertEqual(misGuardados.count, 1)
        XCTAssertEqual(misGuardados.first?.idPublicacion, idPublicacionAjena)
    }

    // MARK: - 2. Quitar publicación de Guardados
    func testEliminarDeGuardados() throws {
        let idMiUsuario = UUID()
        let guardado = PublicacionGuardadaEntity(context: context)
        guardado.idUsuario = idMiUsuario
        try context.save()
        
        // When: Le quito el "guardado"
        context.delete(guardado)
        try context.save()
        
        // Then: Mi lista debe estar vacía
        let fetchRequest: NSFetchRequest<PublicacionGuardadaEntity> = PublicacionGuardadaEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idUsuario == %@", idMiUsuario as CVarArg)
        
        let misGuardados = try context.fetch(fetchRequest)
        XCTAssertEqual(misGuardados.count, 0, "El registro de guardado debe desaparecer")
    }

    // MARK: - 3. Respuestas a una publicación
    func testObtenerRespuestasDeUnaPublicacion() throws {
        let idPostOriginal = UUID()
        let idOtroPost = UUID()
        
        // Given: Dos respuestas a la publicación original y una a otra diferente
        let resp1 = RespuestaEntity(context: context)
        resp1.idPublicacion = idPostOriginal
        resp1.descripcion = "Lo vi en el parque"
        
        let resp2 = RespuestaEntity(context: context)
        resp2.idPublicacion = idPostOriginal
        resp2.descripcion = "Estaba asustado"
        
        let resp3 = RespuestaEntity(context: context)
        resp3.idPublicacion = idOtroPost
        
        try context.save()
        
        // When: Entro al detalle de la publicación original y cargo sus respuestas
        let fetchRequest: NSFetchRequest<RespuestaEntity> = RespuestaEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idPublicacion == %@", idPostOriginal as CVarArg)
        
        let respuestasDelPost = try context.fetch(fetchRequest)
        
        // Then: Solo debe traer las 2 respuestas asociadas a esa publicación
        XCTAssertEqual(respuestasDelPost.count, 2)
    }
}
