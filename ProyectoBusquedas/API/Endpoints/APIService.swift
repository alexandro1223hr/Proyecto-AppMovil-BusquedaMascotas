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
 
    static func registrarPublicacion(_ dto: CrearPublicacionDTO,
                                      completion: @escaping (Bool, String?, Publicacion?) -> Void) {
 
        guard let url = URL(string: APIConstants.publicaciones) else {
            completion(false, "URL inválida", nil)
            return
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
 
        do {
            request.httpBody = try JSONEncoder().encode(dto)
        } catch {
            completion(false, "No se pudo preparar la solicitud", nil)
            return
        }
 
        URLSession.shared.dataTask(with: request) { datos, respuesta, error in
 
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, "sin_conexion", nil)
                }
                return
            }
 
            guard let httpRespuesta = respuesta as? HTTPURLResponse, httpRespuesta.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(false, "No se pudo registrar la publicación", nil)
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
                let publicacion = try JSONDecoder().decode(Publicacion.self, from: datos)
                DispatchQueue.main.async {
                    completion(true, nil, publicacion)
                }
            } catch {
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
 
    static func cambiarEstadoPublicacion(id: String, nuevoEstado: String,
                                          completion: @escaping (Bool, String?, Publicacion?) -> Void) {
 
        guard let url = URL(string: APIConstants.cambiarEstadoPublicacion(id: id, estado: nuevoEstado)) else {
            completion(false, "URL inválida", nil)
            return
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
 
        URLSession.shared.dataTask(with: request) { datos, respuesta, error in
 
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, "sin_conexion", nil)
                }
                return
            }
 
            guard let httpRespuesta = respuesta as? HTTPURLResponse, httpRespuesta.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(false, "No se pudo actualizar el estado", nil)
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
                let publicacion = try JSONDecoder().decode(Publicacion.self, from: datos)
                DispatchQueue.main.async {
                    completion(true, nil, publicacion)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "No se pudo leer la respuesta del servidor", nil)
                }
            }
 
        }.resume()
    }
}
