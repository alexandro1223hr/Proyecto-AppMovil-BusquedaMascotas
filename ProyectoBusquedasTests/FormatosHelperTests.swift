import XCTest
@testable import ProyectoBusquedas

final class FormatosHelperTests: XCTestCase {
    
    var vc: GuardadosViewController!

    override func setUpWithError() throws {
        vc = GuardadosViewController()
    }

    override func tearDownWithError() throws {
        vc = nil
    }

    // MARK: - 1. Formateo de Dinero
    func testFormateoDeRecompensaMayorACero() {
        // When
        let resultado = vc.formatearMonto(250.0)
        
        // Then
        XCTAssertTrue(resultado.contains("S/."), "Debe tener el símbolo de soles")
        XCTAssertTrue(resultado.contains("250"), "Debe mantener el monto")
    }

    // MARK: - 2. Cálculos de Fechas (Tiempo transcurrido)
    func testTiempoTranscurridoEnHoras() {
        // Given: Una fecha de hace 4 horas exactas
        let haceCuatroHoras = Calendar.current.date(byAdding: .hour, value: -4, to: Date())!
        
        // When
        let resultado = vc.tiempoTranscurrido(desde: haceCuatroHoras)
        
        // Then
        XCTAssertTrue(resultado.contains("4"), "Debe mostrar el número 4")
        XCTAssertTrue(resultado.lowercased().contains("hora"), "Debe contener la palabra hora/horas")
    }
    
    func testTiempoTranscurridoEnDias() {
        // Given: Una fecha de hace 15 días
        let haceTresSemanas = Calendar.current.date(byAdding: .day, value: -21, to: Date())!
        
        // When
        let resultado = vc.tiempoTranscurrido(desde: haceTresSemanas)
        
        // Then
        XCTAssertTrue(resultado.contains("3"), "Debe mostrar 3")
        XCTAssertTrue(resultado.lowercased().contains("semanas") || resultado.lowercased().contains("semana"), "Debe contener la palabra semana/semanas")
    }
}
