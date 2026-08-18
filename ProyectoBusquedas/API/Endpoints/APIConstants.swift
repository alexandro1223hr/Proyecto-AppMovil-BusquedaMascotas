//
//  APIConstants.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 17/08/26.
//

import Foundation

struct APIConstants {
    // URL
    static let baseURL = "https://proyecto-busqueda.onrender.com"
    
    // Usuarios
    static let login = baseURL + "/api/auth/login"
    static let usuarios = baseURL + "/api/usuarios"
    
    static func actualizarPerfil(idUsuario: String) -> String {
        return baseURL + "/api/usuarios/\(idUsuario)/perfil"
    }
    
    static func actualizarPassword(idUsuario: String) -> String {
        return baseURL + "/api/auth/password/\(idUsuario)"
    }
    
    // Publicaciones
    static let publicaciones = baseURL + "/api/publicaciones"
 
    static func publicacionesPorUsuario(idUsuario: String) -> String {
        return baseURL + "/api/publicaciones/usuario/\(idUsuario)"
    }
 
    static func publicacionPorId(id: String) -> String {
        return baseURL + "/api/publicaciones/\(id)"
    }
 
    static func cambiarEstadoPublicacion(id: String, estado: String) -> String {
        let estadoCodificado = estado.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? estado
        return baseURL + "/api/publicaciones/\(id)/estado?estado=\(estadoCodificado)"
    }
}
