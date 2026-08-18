//
//  ProyectoBusquedasUITests.swift
//  ProyectoBusquedasUITests
//
//  Created by XCODE on 7/08/26.
//

import XCTest

final class ProyectoBusquedasUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - TestUI Registro
    func testNavegarDesdeInicioHastaRegistro() throws {
        let app = XCUIApplication()
        app.launch()
    
        // 1. Tocar la pestaña "Perfil" en el Tab Bar
        let perfilTab = app.tabBars.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
    
        let cerrarSesionButton = app.buttons["Cerrar sesión"]
        
        if cerrarSesionButton.exists {
            cerrarSesionButton.tap()
            // Opcional: si aparece un alerta de confirmación, búscala y dale a "Aceptar"
            // app.alerts.buttons["Aceptar"].tap()
        }

        // 2. Presionar el botón "Registrarse" en el Login
        let irARegistroButton = app.buttons["Registrarse"]
        XCTAssertTrue(irARegistroButton.waitForExistence(timeout: 5))
        irARegistroButton.tap()

        // 3. Llenar los campos del RegistroViewController
        let nombreField = app.textFields["nombreTextField"]
        XCTAssertTrue(nombreField.waitForExistence(timeout: 5))
        nombreField.tap()
        nombreField.typeText("Juan Perez")

        let correoField = app.textFields["correoTextField"]
        correoField.tap()
        correoField.typeText("juan@test.com")

        // 5. Llenar Teléfono
        let telefonoField = app.textFields["telefonoTextField"]
        telefonoField.tap()
        telefonoField.typeText("987654321")


        app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.25)).tap()

        // 3. Llenar los campos inferiores
        let passwordField = app.textFields["passwordTextField"]
        passwordField.tap()
        passwordField.typeText("123456")

        app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.25)).tap()

        let confirmarField = app.textFields["confirmarPasswordTextField"]
        confirmarField.tap()
        confirmarField.typeText("123456")

        app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.25)).tap()

        // 8. Tocar el botón final de Registrarse
        let registrarButton = app.buttons["Registrarse"]
        registrarButton.tap()
    }

    // MARK: - TestUI Login
    func testNavegarDesdeInicioHastaIniciarSesion() throws {
            
        let app = XCUIApplication()
        app.launch()

        // 1. Ir al Perfil desde el Tab Bar
        let perfilTab = app.tabBars.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()

        // 2. Ir a la pantalla de Iniciar Sesión
        // Asegúrate de que el botón en tu Login tenga el identificador "IniciarSesion"
        let irAIniciarSesionButton = app.buttons["Iniciar sesión"]
        XCTAssertTrue(irAIniciarSesionButton.waitForExistence(timeout: 5))
        irAIniciarSesionButton.tap()

        // 3. Llenar Correo
        let correoField = app.textFields["correoLoginTextField"]
        XCTAssertTrue(correoField.waitForExistence(timeout: 5))
        correoField.tap()
        correoField.typeText("juan@test.com")

        // 4. Cerrar el teclado antes de llenar la contraseña (por si acaso tapa la vista)
        app.staticTexts["Correo:"].tap()

        // 5. Llenar Contraseña
        let passwordField = app.descendants(matching: .any)["passwordLoginTextField"]
            XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
            passwordField.tap()
            passwordField.typeText("123456")

        // 6. Cerrar teclado nuevamente para liberar el botón
        app.staticTexts["Correo:"].tap()

        // 7. Tocar botón Iniciar Sesión
        let iniciarSesionButton = app.buttons["Iniciar sesión"]
        XCTAssertTrue(iniciarSesionButton.waitForExistence(timeout: 5))
        iniciarSesionButton.tap()
    }
    
    
    // MARK: - TestUI Publicacion
    func testFlujoPublicarReporteCompleto() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. VERIFICAR SI HAY SESIÓN INICIADA
        let perfilTab = app.tabBars.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()

        let iniciarSesionButtonEnPerfil = app.buttons["Iniciar sesión"]
        
        // Si el botón de iniciar sesión existe, significa que NO hay sesión activa y debemos loguearnos
        if iniciarSesionButtonEnPerfil.exists {
            iniciarSesionButtonEnPerfil.tap()

            let correoField = app.textFields["correoLoginTextField"]
            XCTAssertTrue(correoField.waitForExistence(timeout: 5))
            correoField.tap()
            correoField.typeText("juan@test.com")
            app.staticTexts["Correo:"].tap() // Cierra teclado

            let passwordField = app.descendants(matching: .any)["passwordLoginTextField"]
            passwordField.tap()
            passwordField.typeText("123456")
            app.staticTexts["Contraseña:"].tap() // Cierra teclado

            let btnLogin = app.buttons["Iniciar sesión"]
            btnLogin.tap()
        }

        // 2. IR A LA PANTALLA PRINCIPAL / HOME
        let inicioTab = app.tabBars.buttons["Inicio"]
        if inicioTab.exists {
            inicioTab.tap()
        }

        // 3. DARLE AL BOTÓN "+" (Arriba a la derecha)
        let agregarReporteButton = app.buttons["Publicar"] // Asegúrate de poner este Identifier en tu Storyboard
        XCTAssertTrue(agregarReporteButton.waitForExistence(timeout: 5))
        agregarReporteButton.tap()

        // 4. LLENAR CAMPOS SUPERIORES
    
    // 4. SELECCIONAR ESTADO DEL REPORTE (Combo Box / Desplegable)
        // Asumiendo que al tocar el botón del combo box se abre el menú con las opciones
        let estadoDropdownButton = app.buttons["estadoReporteDropdown"] // Ajusta el identifier del botón desplegable
        XCTAssertTrue(estadoDropdownButton.waitForExistence(timeout: 5))
        estadoDropdownButton.tap()
        
        // Seleccionamos la opción "Se Busca" (o "Encontrado" según prefieras)
        let opcionSeBusca = app.buttons["Se busca"]
        XCTAssertTrue(opcionSeBusca.waitForExistence(timeout: 2))
        opcionSeBusca.tap()
        // Ciudad / distrito
        let ciudadField = app.textFields["ciudadTextField"]
        XCTAssertTrue(ciudadField.waitForExistence(timeout: 5))
        ciudadField.tap()
        ciudadField.typeText("Lima, SJL")

        // Fecha, hora y/o descripción del extravío
        let descripcionField = app.textFields["descripcionExtravioTextField"]
        descripcionField.tap()
        descripcionField.typeText("Se perdió mi perrito cerca al parque principal.")

        
        // Interceptor para manejar automáticamente la alerta de permisos de ubicación de iOS
        addUIInterruptionMonitor(withDescription: "Permiso de Ubicación") { (alert) -> Bool in
            let allowButton = alert.buttons["Allow While Using App"]
            if allowButton.exists {
                allowButton.tap()
                return true
            }
            return false
        }

        // 2. Dar clic a "Seleccionar en mapa"
        let seleccionarEnMapaButton = app.buttons["Seleccionar en mapa"]
        XCTAssertTrue(seleccionarEnMapaButton.waitForExistence(timeout: 5))
        seleccionarEnMapaButton.tap()

        // Forzamos el toque para que el monitor procese la alerta si aparece
        app.tap()

        // 3. INTERACTUAR CON EL MAPA
        // Buscamos el mapa (a veces es un MKMapView o un botón grande que representa el mapa)
        // Tocamos el centro del mapa para simular la selección de una ubicación
        let mapaView = app.otherElements["mapaView"] // Asegúrate de darle este Identifier a tu vista de mapa o botón de mapa
        if mapaView.waitForExistence(timeout: 5) {
            mapaView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }

        // 4. Confirmar ubicación
        let confirmarUbicacionBtn = app.buttons["Confirmar ubicación"] // ID en el Storyboard
        XCTAssertTrue(confirmarUbicacionBtn.waitForExistence(timeout: 5))
        confirmarUbicacionBtn.tap()
        

        // Cerramos el teclado de la sección superior para liberar los siguientes campos
        app.staticTexts["Datos de la mascota"].tap()

        // 5. DATOS DE LA MASCOTA
        let nombreMascotaField = app.textFields["nombreMascotaTextField"]
        nombreMascotaField.tap()
        nombreMascotaField.typeText("Firulais")
    
        app.staticTexts["Datos de la mascota"].tap()

        let caracteristica1Field = app.textFields["caracteristica1TextField"]
                caracteristica1Field.tap()
                caracteristica1Field.typeText("Mestizo")

        app.staticTexts["Datos de la mascota"].tap()
        
                let caracteristica2Field = app.textFields["caracteristica2TextField"]
                caracteristica2Field.tap()
                caracteristica2Field.typeText("Color marrón")
        
        app.staticTexts["Datos de la mascota"].tap()

                let caracteristica3Field = app.textFields["caracteristica3TextField"]
                caracteristica3Field.tap()
                caracteristica3Field.typeText("Mancha blanca en el pecho")
        
        app.staticTexts["Datos de la mascota"].tap()

        // 1. Monitor para aceptar el permiso de acceso a fotos si aparece la alerta
        addUIInterruptionMonitor(withDescription: "Permiso de Fotos") { (alert) -> Bool in
            // Busca el botón de permitir (el texto exacto depende de tu iOS, suele ser "Allow Full Access" o "Permitir acceso completo")
            // Si está en español, busca "Permitir acceso completo"
            let allowButton = alert.buttons["Allow Full Access"].firstMatch.exists ? alert.buttons["Allow Full Access"] : alert.buttons["Permitir acceso completo"]
            if allowButton.exists {
                allowButton.tap()
                return true
            }
            return false
        }

        // 2. (Tu código existente) Botón "Seleccionar foto" y "Elegir de la galería"
        let seleccionarFotoButton = app.buttons["Seleccionar foto"]
        if seleccionarFotoButton.waitForExistence(timeout: 5) {
            seleccionarFotoButton.tap()
        }

        let elegirGaleriaButton = app.buttons["Elegir de la galería"]
        if elegirGaleriaButton.waitForExistence(timeout: 3) {
            elegirGaleriaButton.tap()
        } else {
            // Si el menú de "Elegir de la galería" no aparece (quizás porque ya aceptamos permisos antes),
            // el test debería continuar, pero para seguridad, intentamos forzar el toque en la galería del sistema:
        }

        // 3. (Aquí es donde se congela) Forzamos el tap en el centro de la pantalla por si la galería está vacía o no carga elementos
        // Si la galería está vacía, esto simplemente fallará rápido en lugar de colgarse.
        let primeraFoto = app.collectionViews.cells.element(boundBy: 0)
        if primeraFoto.waitForExistence(timeout: 10) {
            primeraFoto.tap()
        } else {
            // Si no hay fotos, intentamos tocar el centro de la pantalla por si acaso
            print("No se encontraron celdas de fotos, intentando tocar el centro como respaldo.")
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }

        // 4. Botón "Choose" o "Añadir"
        let chooseButton = app.buttons["Choose"].exists ? app.buttons["Choose"] : app.buttons["Añadir"]
        if chooseButton.waitForExistence(timeout: 5) {
            chooseButton.tap()
        }

        // Cerramos teclado de la sección media
        app.staticTexts["Datos de la mascota"].tap()

        // 6. DATOS FINALES
        let telefonoField = app.textFields["telefonoReporteTextField"]
        telefonoField.tap()
        telefonoField.typeText("987654321")

        app.staticTexts["Datos de la mascota"].tap()
    
        let telefonoAdicionalField = app.textFields["telefonoAdicionalTextField"]
        telefonoAdicionalField.tap()
        telefonoAdicionalField.typeText("912345678")

        app.staticTexts["Datos de la mascota"].tap()
    
        let recompensaField = app.textFields["recompensaTextField"]
        recompensaField.tap()
        recompensaField.typeText("1500000")

        // Cerramos teclado por última vez para liberar el botón de publicar
        app.staticTexts["Datos de la mascota"].tap()

        // 7. PUBLICAR REPORTE
        let publicarButton = app.buttons["Publicar"] // Identificador del botón inferior
        XCTAssertTrue(publicarButton.waitForExistence(timeout: 5))
        publicarButton.tap()
    }
    
    // MARK: - Funcion final por defecto
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
