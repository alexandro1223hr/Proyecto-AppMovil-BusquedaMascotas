import XCTest
import CoreData
@testable import ProyectoBusquedas

final class PublicacionesTests: XCTestCase {
    
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        let appBundle = Bundle(for: PublicacionEntity.self)
                
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

    // MARK: - 1. Creación de Reporte
    func testCrearPublicacionMascotaPerdida() throws {
        let publicacion = PublicacionEntity(context: context)
        publicacion.idPublicacion = UUID()
        publicacion.nombreMascota = "Firulais"
        publicacion.estadoBusqueda = "Se busca"
        publicacion.fechaHoraPublicacion = Date()
        
        try context.save()
        
        let fetchRequest: NSFetchRequest<PublicacionEntity> = PublicacionEntity.fetchRequest()
        let resultados = try context.fetch(fetchRequest)
        
        XCTAssertEqual(resultados.count, 1)
        XCTAssertEqual(resultados.first?.estadoBusqueda, "Se busca", "El reporte debe guardarse como PERDIDO")
    }

    // MARK: - 2. Filtros del Feed (Solo mostrar 'Se busca')
    func testFiltrarPublicacionesPorEstado() throws {
        // Given: Creamos dos publicaciones diferentes
        let pub1 = PublicacionEntity(context: context)
        pub1.estadoBusqueda = "Se busca"
        
        let pub2 = PublicacionEntity(context: context)
        pub2.estadoBusqueda = "Encontrado"
        
        try context.save()
        
        // When: Simulamos el filtro del usuario en la pantalla principal
        let fetchRequest: NSFetchRequest<PublicacionEntity> = PublicacionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "estadoBusqueda == %@", "Se busca")
        let filtrados = try context.fetch(fetchRequest)
        
        // Then: Solo debe traer la publicación 'SE BUSCA'
        XCTAssertEqual(filtrados.count, 1)
        XCTAssertEqual(filtrados.first?.estadoBusqueda, "Se busca")
    }

    // MARK: - 3. Actualización de Estado (Finalizado)
    func testActualizarEstadoAResuelto() throws {
        let publicacion = PublicacionEntity(context: context)
        publicacion.idPublicacion = UUID()
        publicacion.estadoBusqueda = "Se busca"
        try context.save()
        
        // When: El usuario marca que ya encontró a su mascota
        publicacion.estadoBusqueda = "Finalizado"
        try context.save()
        
        // Then
        let fetchRequest: NSFetchRequest<PublicacionEntity> = PublicacionEntity.fetchRequest()
        let resultados = try context.fetch(fetchRequest) as [PublicacionEntity]
        let actualizada = resultados.first
        
        XCTAssertEqual(actualizada?.estadoBusqueda, "Finalizado", "El estado debe actualizarse correctamente en la BD")
    }

}
