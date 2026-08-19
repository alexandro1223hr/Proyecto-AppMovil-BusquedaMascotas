//
//  APIService.swift
//  ProyectoBusquedas
//
//  Created by XCODE on 17/08/26.
//

import Foundation

struct APIService {
 
    // MARK: - Login
    // completion entrega: exito (true/false), mensaje de error si falló,
    // y los datos de la sesión si tuvo éxito
    static func login(correo: String, password: String,
                       completion: @escaping (Bool, String?, RespuestaLogin?) -> Void) {
 
        guard let url = URL(string: APIConstants.login) else {
            completion(false, "URL inválida", nil)
            return
        }
 
        let cuerpo: [String: String] = [
            "correo": correo,
            "password": password
        ]
 
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: cuerpo)
 
        URLSession.shared.dataTask(with: request) { datos, respuesta, error in
 
            // Si no hubo conexión o hubo un error de red
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, "sin_conexion", nil)
                }
                return
            }
 
            guard let httpRespuesta = respuesta as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(false, "Respuesta inválida del servidor", nil)
                }
                return
            }
 
            // El backend devuelve error si el correo o contraseña son incorrectos
            if httpRespuesta.statusCode != 200 {
                DispatchQueue.main.async {
                    completion(false, "Correo o contraseña incorrectos", nil)
                }
                return
            }
 
            guard let datos = datos else {
                DispatchQueue.main.async {
                    completion(false, "El servidor no envió datos", nil)
                }
                return
            }
 
            do {
                let resultado = try JSONDecoder().decode(RespuestaLogin.self, from: datos)
                DispatchQueue.main.async {
                    completion(true, nil, resultado)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "No se pudo leer la respuesta del servidor", nil)
                }
            }
 
        }.resume()
    }
 
    // MARK: - Registro
 
    static func registrar(nombre: String, correo: String, telefono: String, password: String,
                           completion: @escaping (Bool, String?, Usuario?) -> Void) {
 
        guard let url = URL(string: APIConstants.usuarios) else {
            completion(false, "URL inválida", nil)
            return
        }
 
        let cuerpo: [String: String] = [
            "nombre": nombre,
            "correo": correo,
            "telefono": telefono,
            "password": password
        ]
 
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: cuerpo)
 
        URLSession.shared.dataTask(with: request) { datos, respuesta, error in
 
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, "sin_conexion", nil)
                }
                return
            }
 
            guard let httpRespuesta = respuesta as? HTTPURLResponse, httpRespuesta.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(false, "No se pudo registrar el usuario", nil)
                }
                return
            }
 
            guard let datos = datos else {
                DispatchQueue.main.async {
                    completion(false, "El servidor no envió datos", nil)
                }
                return
            }
 
            do {
                let usuario = try JSONDecoder().decode(Usuario.self, from: datos)
                DispatchQueue.main.async {
                    completion(true, nil, usuario)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "No se pudo leer la respuesta del servidor", nil)
                }
            }
 
        }.resume()
    }
 
    // MARK: - Actualizar perfil
 
    static func actualizarPerfil(idUsuario: String, nombre: String, correo: String, telefono: String, token: String,
                                  completion: @escaping (Bool, String?, Usuario?) -> Void) {
 
        guard let url = URL(string: APIConstants.actualizarPerfil(idUsuario: idUsuario)) else {
            completion(false, "URL inválida", nil)
            return
        }
 
        let cuerpo: [String: String] = [
            "nombre": nombre,
            "correo": correo,
            "telefono": telefono
        ]
 
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: cuerpo)
 
        URLSession.shared.dataTask(with: request) { datos, respuesta, error in
 
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, "sin_conexion", nil)
                }
                return
            }
 
            guard let httpRespuesta = respuesta as? HTTPURLResponse, httpRespuesta.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(false, "No se pudo actualizar el perfil", nil)
                }
                return
            }
 
            guard let datos = datos else {
                DispatchQueue.main.async {
                    completion(false, "El servidor no envió datos", nil)
                }
                return
            }
 
            do {
                let usuario = try JSONDecoder().decode(Usuario.self, from: datos)
                DispatchQueue.main.async {
                    completion(true, nil, usuario)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "No se pudo leer la respuesta del servidor", nil)
                }
            }
 
        }.resume()
    }
 
    // MARK: - Actualizar contraseña
 
    static func actualizarPassword(idUsuario: String, passwordActual: String, nuevaPassword: String, token: String,
                                    completion: @escaping (Bool, String?) -> Void) {
 
        guard let url = URL(string: APIConstants.actualizarPassword(idUsuario: idUsuario)) else {
            completion(false, "URL inválida")
            return
        }
 
        let cuerpo: [String: String] = [
            "passwordActual": passwordActual,
            "nuevaPassword": nuevaPassword
        ]
 
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: cuerpo)
 
        URLSession.shared.dataTask(with: request) { _, respuesta, error in
 
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, "sin_conexion")
                }
                return
            }
 
            guard let httpRespuesta = respuesta as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(false, "Respuesta inválida del servidor")
                }
                return
            }
 
            if httpRespuesta.statusCode == 204 {
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, "No se pudo actualizar la contraseña")
                }
            }
 
        }.resume()
    }
}

extension APIService {
 
    // MARK: - Registrar publicación
 
    // Ahora recibe el token explícitamente
    static func registrarPublicacion(_ dto: CrearPublicacionDTO, token: String,
                                      completion: @escaping (Bool, String?, Publicacion?) -> Void) {
 
        guard let url = URL(string: APIConstants.publicaciones) else {
            print("[registrarPublicacion] URL inválida: \(APIConstants.publicaciones)")
            completion(false, "URL inválida", nil)
            return
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
 
        do {
            let cuerpo = try JSONEncoder().encode(dto)
            request.httpBody = cuerpo
 
            if let jsonTexto = String(data: cuerpo, encoding: .utf8) {
                print("[registrarPublicacion] Enviando body:\n\(jsonTexto)")
            }
        } catch {
            print("[registrarPublicacion] Error al codificar el DTO: \(error)")
            completion(false, "No se pudo preparar la solicitud", nil)
            return
        }
 
        print("[registrarPublicacion] POST -> \(url.absoluteString)")
        print("[registrarPublicacion] Authorization: Bearer \(token.prefix(15))...")
 
        URLSession.shared.dataTask(with: request) { datos, respuesta, error in
 
            if let error = error {
                let nsError = error as NSError
                print("[registrarPublicacion] Error de red: \(error.localizedDescription)")
                print("[registrarPublicacion] Código NSError: \(nsError.code), dominio: \(nsError.domain)")
 
                DispatchQueue.main.async {
                    completion(false, "sin_conexion", nil)
                }
                return
            }
 
            guard let httpRespuesta = respuesta as? HTTPURLResponse else {
                print("[registrarPublicacion] La respuesta no es HTTPURLResponse")
                DispatchQueue.main.async {
                    completion(false, "Respuesta inválida del servidor", nil)
                }
                return
            }
 
            print("[registrarPublicacion] Código HTTP recibido: \(httpRespuesta.statusCode)")
 
            if let datos = datos, let cuerpoTexto = String(data: datos, encoding: .utf8) {
                print("[registrarPublicacion] Body de respuesta:\n\(cuerpoTexto)")
            } else {
                print("[registrarPublicacion] Sin cuerpo de respuesta, o no se pudo leer como texto")
            }
 
            // 403 específicamente indica que Spring Security bloqueó la
            // petición (token ausente, inválido, o expirado) antes de que
            // llegara al controller
            if httpRespuesta.statusCode == 403 {
                print("[registrarPublicacion] 403: la petición fue rechazada por seguridad (token ausente/inválido/expirado)")
                DispatchQueue.main.async {
                    completion(false, "Tu sesión no es válida, vuelve a iniciar sesión", nil)
                }
                return
            }
 
            guard httpRespuesta.statusCode == 200 else {
                print("[registrarPublicacion] Código distinto de 200, se reporta como fallo")
                DispatchQueue.main.async {
                    completion(false, "No se pudo registrar la publicación (código \(httpRespuesta.statusCode))", nil)
                }
                return
            }
 
            guard let datos = datos else {
                print("[registrarPublicacion] Código 200 pero sin datos en el body")
                DispatchQueue.main.async {
                    completion(false, "El servidor no envió datos", nil)
                }
                return
            }
 
            do {
                let publicacion = try JSONDecoder().decode(Publicacion.self, from: datos)
                print("[registrarPublicacion] Decode exitoso. idPublicacion: \(publicacion.idPublicacion)")
                DispatchQueue.main.async {
                    completion(true, nil, publicacion)
                }
            } catch {
                print("[registrarPublicacion] Error al decodificar la respuesta: \(error)")
                DispatchQueue.main.async {
                    completion(false, "No se pudo leer la respuesta del servidor", nil)
                }
            }
 
        }.resume()
    }
    
 
    // MARK: - Listar todas las publicaciones
 
    static func listarPublicaciones(completion: @escaping (Bool, String?, [Publicacion]?) -> Void) {
 
        guard let url = URL(string: APIConstants.publicaciones) else {
            completion(false, "URL inválida", nil)
            return
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
 
        URLSession.shared.dataTask(with: request) { datos, respuesta, error in
 
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, "sin_conexion", nil)
                }
                return
            }
 
            guard let httpRespuesta = respuesta as? HTTPURLResponse, httpRespuesta.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(false, "No se pudo obtener la lista de publicaciones", nil)
                }
                return
            }
 
            guard let datos = datos else {
                DispatchQueue.main.async {
                    completion(false, "El servidor no envió datos", nil)
                }
                return
            }
 
            do {
                let publicaciones = try JSONDecoder().decode([Publicacion].self, from: datos)
                DispatchQueue.main.async {
                    completion(true, nil, publicaciones)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "No se pudo leer la respuesta del servidor", nil)
                }
            }
 
        }.resume()
    }
 
    // MARK: - Listar publicaciones de un usuario específico
 
    static func listarPublicacionesPorUsuario(idUsuario: String,
                                               completion: @escaping (Bool, String?, [Publicacion]?) -> Void) {
 
        guard let url = URL(string: APIConstants.publicacionesPorUsuario(idUsuario: idUsuario)) else {
            completion(false, "URL inválida", nil)
            return
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
 
        URLSession.shared.dataTask(with: request) { datos, respuesta, error in
 
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, "sin_conexion", nil)
                }
                return
            }
 
            guard let httpRespuesta = respuesta as? HTTPURLResponse, httpRespuesta.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(false, "No se pudo obtener tus publicaciones", nil)
                }
                return
            }
 
            guard let datos = datos else {
                DispatchQueue.main.async {
                    completion(false, "El servidor no envió datos", nil)
                }
                return
            }
 
            do {
                let publicaciones = try JSONDecoder().decode([Publicacion].self, from: datos)
                DispatchQueue.main.async {
                    completion(true, nil, publicaciones)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "No se pudo leer la respuesta del servidor", nil)
                }
            }
 
        }.resume()
    }
 

    // MARK: - Cambiar estado de una publicación (ej. "Finalizar")
 
    // Requiere token
    static func cambiarEstadoPublicacion(id: String, nuevoEstado: String, token: String,
                                          completion: @escaping (Bool, String?, Publicacion?) -> Void) {
 
        guard let url = URL(string: APIConstants.cambiarEstadoPublicacion(id: id, estado: nuevoEstado)) else {
            print("[cambiarEstadoPublicacion] URL inválida")
            completion(false, "URL inválida", nil)
            return
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
 
        print("[cambiarEstadoPublicacion] PATCH -> \(url.absoluteString)")
 
        URLSession.shared.dataTask(with: request) { datos, respuesta, error in
 
            if let error = error {
                print("[cambiarEstadoPublicacion] Error de red: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, "sin_conexion", nil)
                }
                return
            }
 
            guard let httpRespuesta = respuesta as? HTTPURLResponse else {
                print("[cambiarEstadoPublicacion] Respuesta inválida")
                DispatchQueue.main.async {
                    completion(false, "Respuesta inválida del servidor", nil)
                }
                return
            }
 
            print("[cambiarEstadoPublicacion] Código HTTP: \(httpRespuesta.statusCode)")
 
            if let datos = datos, let cuerpoTexto = String(data: datos, encoding: .utf8) {
                print("[cambiarEstadoPublicacion] Body de respuesta:\n\(cuerpoTexto)")
            }
 
            if httpRespuesta.statusCode == 403 {
                print("[cambiarEstadoPublicacion] 403: token ausente/inválido/expirado")
                DispatchQueue.main.async {
                    completion(false, "Tu sesión no es válida, vuelve a iniciar sesión", nil)
                }
                return
            }
 
            if httpRespuesta.statusCode == 404 {
                DispatchQueue.main.async {
                    completion(false, "La publicación no existe", nil)
                }
                return
            }
 
            guard httpRespuesta.statusCode == 200, let datos = datos else {
                DispatchQueue.main.async {
                    completion(false, "No se pudo actualizar el estado (código \(httpRespuesta.statusCode))", nil)
                }
                return
            }
 
            do {
                let publicacion = try JSONDecoder().decode(Publicacion.self, from: datos)
                DispatchQueue.main.async {
                    completion(true, nil, publicacion)
                }
            } catch {
                print("[cambiarEstadoPublicacion] Error al decodificar: \(error)")
                DispatchQueue.main.async {
                    completion(false, "No se pudo leer la respuesta del servidor", nil)
                }
            }
 
        }.resume()
    }
    
}
