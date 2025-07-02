import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_image_whatsapp/share_image_whatsapp.dart';

class QRWhatsAppHelper {
  /// Envía una imagen QR a WhatsApp con manejo de errores y reintentos
  static Future<bool> sendQRToWhatsApp({
    required String mensaje,
    required String phone,
    required GlobalKey qrKey,
    int maxRetries = 3,
    WhatsApp whatsAppType = WhatsApp.standard,
  }) async {
    // Validaciones iniciales
    if (phone.trim().isEmpty) {
      debugPrint('ERROR: Número de teléfono vacío');
      return false;
    }

    if (mensaje.trim().isEmpty) {
      debugPrint('ERROR: Mensaje vacío');
      return false;
    }

    // Limpiar el número de teléfono (remover espacios, caracteres especiales)
    String cleanPhone = _cleanPhoneNumber(phone);
    debugPrint('Teléfono limpio: $cleanPhone');

    // Generar formatos alternativos para probar
    List<String> phoneFormats = _generatePhoneFormats(cleanPhone);
    debugPrint('Formatos a probar: $phoneFormats');

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('Intento $attempt de $maxRetries para enviar QR');
        
        // Capturar la imagen del QR
        Uint8List? qrImageBytes = await _captureQRImage(qrKey);
        if (qrImageBytes == null) {
          debugPrint('ERROR: No se pudo capturar la imagen QR');
          if (attempt == maxRetries) return false;
          continue;
        }

        // Guardar la imagen temporalmente
        String? imagePath = await _saveTemporaryImage(qrImageBytes);
        if (imagePath == null) {
          debugPrint('ERROR: No se pudo guardar la imagen temporal');
          if (attempt == maxRetries) return false;
          continue;
        }

        // Probar con diferentes formatos de número
        bool success = false;
        for (int formatIndex = 0; formatIndex < phoneFormats.length; formatIndex++) {
          String phoneToTry = phoneFormats[formatIndex];
          debugPrint('Probando formato ${formatIndex + 1}/${phoneFormats.length}: $phoneToTry');
          
          success = await _sendToWhatsApp(
            imagePath: imagePath,
            message: mensaje,
            phone: phoneToTry,
            whatsAppType: whatsAppType,
          );
          
          if (success) {
            debugPrint('¡Éxito con formato: $phoneToTry!');
            break;
          } else {
            debugPrint('Falló formato: $phoneToTry');
            // Esperar un poco antes del siguiente formato
            if (formatIndex < phoneFormats.length - 1) {
              await Future.delayed(Duration(milliseconds: 300));
            }
          }
        }

        // Limpiar archivo temporal
        await _cleanupTemporaryFile(imagePath);

        if (success) {
          debugPrint('QR enviado exitosamente en intento $attempt');
          return true;
        } else {
          debugPrint('Fallaron todos los formatos en intento $attempt');
          if (attempt < maxRetries) {
            // Esperar antes del siguiente intento
            await Future.delayed(Duration(milliseconds: 500 * attempt));
          }
        }
      } catch (e) {
        debugPrint('Error en intento $attempt: $e');
        if (attempt == maxRetries) return false;
        // Esperar antes del siguiente intento
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    return false;
  }

  /// Limpia el número de teléfono removiendo caracteres no numéricos
  static String _cleanPhoneNumber(String phone) {
    // Remover espacios, guiones, paréntesis, etc.
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    debugPrint('Número original: $phone');
    debugPrint('Número limpio: $cleaned');
    
    // Manejar diferentes casos de números peruanos
    if (cleaned.length == 9) {
      // Número de 9 dígitos (formato local peruano)
      // Agregar código de país 51
      String result = '51$cleaned';
      debugPrint('Número con código país: $result');
      return result;
    } else if (cleaned.length == 11 && cleaned.startsWith('51')) {
      // Ya tiene código de país 51
      debugPrint('Número ya tiene código país: $cleaned');
      return cleaned;
    } else if (cleaned.length == 12 && cleaned.startsWith('051')) {
      // Formato 051XXXXXXXXX, remover el 0 inicial
      String result = cleaned.substring(1);
      debugPrint('Removido 0 inicial: $result');
      return result;
    } else if (cleaned.length == 10 && cleaned.startsWith('1')) {
      // Posible número con 1 inicial extra
      String withoutOne = cleaned.substring(1);
      if (withoutOne.length == 9) {
        String result = '51$withoutOne';
        debugPrint('Removido 1 inicial, agregado código país: $result');
        return result;
      }
    }
    
    // Si no coincide con ningún patrón conocido, devolver tal como está
    debugPrint('Número no reconocido, devolviendo: $cleaned');
    return cleaned;
  }

  /// Captura la imagen del QR desde el GlobalKey
  static Future<Uint8List?> _captureQRImage(GlobalKey qrKey) async {
    try {
      RenderRepaintBoundary boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturando imagen QR: $e');
      return null;
    }
  }

  /// Guarda la imagen temporalmente en el dispositivo
  static Future<String?> _saveTemporaryImage(Uint8List imageBytes) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String imagePath = '${tempDir.path}/qr_temp_$timestamp.png';
      
      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);
      
      debugPrint('Imagen temporal guardada en: $imagePath');
      return imagePath;
    } catch (e) {
      debugPrint('Error guardando imagen temporal: $e');
      return null;
    }
  }

  /// Envía la imagen a WhatsApp usando el package share_image_whatsapp
  static Future<bool> _sendToWhatsApp({
    required String imagePath,
    required String message,
    required String phone,
    WhatsApp whatsAppType = WhatsApp.standard,
  }) async {
    try {
      debugPrint('Enviando a WhatsApp - Teléfono: $phone, Mensaje: $message');
      
      // Crear instancia del helper
      ShareImageWhatsapp shareImageWhatsapp = ShareImageWhatsapp();
      
      // Usar el método de instancia
      bool result = await shareImageWhatsapp.share(
        file: XFile(imagePath),
        phone: phone,
        text: message,
        type: whatsAppType, // Cambiar a WhatsApp.business si es necesario
      );
      
      debugPrint('Resultado del envío: $result');
      return result;
    } catch (e) {
      debugPrint('Error enviando a WhatsApp: $e');
      return false;
    }
  }

  /// Limpia el archivo temporal
  static Future<void> _cleanupTemporaryFile(String imagePath) async {
    try {
      File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Archivo temporal eliminado: $imagePath');
      }
    } catch (e) {
      debugPrint('Error eliminando archivo temporal: $e');
    }
  }

  /// Genera diferentes formatos de número para probar
  static List<String> _generatePhoneFormats(String cleanPhone) {
    List<String> formats = [];
    
    // Agregar el formato principal
    formats.add(cleanPhone);
    
    // Si el número tiene 11 dígitos y empieza con 51
    if (cleanPhone.length == 11 && cleanPhone.startsWith('51')) {
      String localNumber = cleanPhone.substring(2); // Remover 51
      
      // Agregar formatos alternativos
      formats.add('+$cleanPhone');           // +51XXXXXXXXX
      formats.add(localNumber);              // XXXXXXXXX (solo local)
      formats.add('+51$localNumber');        // +51XXXXXXXXX (redundante pero por si acaso)
    }
    
    // Si el número tiene 9 dígitos (formato local)
    if (cleanPhone.length == 9) {
      formats.add('+51$cleanPhone');         // +51XXXXXXXXX
      formats.add('51$cleanPhone');          // 51XXXXXXXXX
    }
    
    // Remover duplicados manteniendo el orden
    return formats.toSet().toList();
  }
}
