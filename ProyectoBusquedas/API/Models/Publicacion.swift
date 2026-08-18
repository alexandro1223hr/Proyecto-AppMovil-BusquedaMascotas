//
//  Publicacion.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 17/08/26.
//

import Foundation

struct Publicacion: Codable {
    let idPublicacion: UUID
    let usuario: UsuarioResumen
    let nombreUsuario: String?
    let telefonoUsuario: String?
    let telefonoOpcional: String?
    let nombreMascota: String?
    let caracteristicaMascota1: String?
    let caracteristicaMascota2: String?
    let caracteristicaMascota3: String?
    let descripcionFechaHoraPerdido: String?
    let ubicacionPerdido: String?
    let ciudadDistrito: String?
    let latitud: Double?
    let longitud: Double?
    let monto: Double?
    let estadoBusqueda: String?
    let fechaHoraPublicacion: String?
    let fechaHoraActualizacion: String?
    let fotoUrl: String?

    // Convierte el string ISO que envía LocalDateTime de Java (ej.
    // "2026-08-17T10:30:00") a un Date de Swift, usable directamente con
    // tiempoTranscurrido(desde:) igual que ya haces con CoreData.
    var fechaPublicacionComoDate: Date? {
        return Publicacion.formatearFecha(fechaHoraPublicacion)
    }

    var fechaActualizacionComoDate: Date? {
        return Publicacion.formatearFecha(fechaHoraActualizacion)
    }

    private static func formatearFecha(_ texto: String?) -> Date? {
        guard let texto = texto else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        // LocalDateTime de Java normalmente no incluye zona horaria ni "Z",
        // así que se intenta primero sin fracción de segundos y luego con ella
        if let fecha = formatter.date(from: texto + "Z") {
            return fecha
        }

        let formatterAlterno = DateFormatter()
        formatterAlterno.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatterAlterno.locale = Locale(identifier: "en_US_POSIX")
        formatterAlterno.timeZone = TimeZone(identifier: "UTC")

        return formatterAlterno.date(from: texto)
    }
}

// El backend serializa la relación @ManyToOne "usuario" completa dentro
// del JSON de Publicacion. Se modela un struct reducido porque solo
// necesitamos el id para relacionar con CoreData localmente.
struct UsuarioResumen: Codable {
    let id: UUID
    let nombre: String?
    let correo: String?
    let telefono: String?
}

// Cuerpo que se envía al crear una publicación (POST). Coincide con
// PublicacionDTO.java del backend. fotoUrl se envía siempre como nil.
struct CrearPublicacionDTO: Codable {
    let idUsuario: UUID
    let nombreUsuario: String
    let telefonoUsuario: String
    let telefonoOpcional: String?
    let nombreMascota: String
    let caracteristicaMascota1: String?
    let caracteristicaMascota2: String?
    let caracteristicaMascota3: String?
    let descripcionFechaHoraPerdido: String
    let ubicacionPerdido: String?
    let ciudadDistrito: String
    let latitud: Double?
    let longitud: Double?
    let monto: Double?
    let estadoBusqueda: String
    let fotoUrl: String?
}
