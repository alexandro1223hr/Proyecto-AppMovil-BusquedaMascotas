//
//  Usuario.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 17/08/26.
//

import Foundation

struct Usuario: Codable {
    let id: UUID
    let nombre: String
    let correo: String
    let telefono: String?
}

struct RespuestaLogin: Codable {
    let token: String
    let idUsuario: UUID
    let nombre: String
    let correo: String
}
