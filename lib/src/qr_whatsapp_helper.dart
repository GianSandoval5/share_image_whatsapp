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

        // Intentar enviar a WhatsApp
        bool success = await _sendToWhatsApp(
          imagePath: imagePath,
          message: mensaje,
          phone: cleanPhone,
        );

        // Limpiar archivo temporal
        await _cleanupTemporaryFile(imagePath);

        if (success) {
          debugPrint('QR enviado exitosamente en intento $attempt');
          return true;
        } else {
          debugPrint('Falló el envío en intento $attempt');
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
    
    // Si empieza con código de país, asegurar que esté bien formateado
    if (cleaned.startsWith('51') && cleaned.length > 9) {
      // Para Perú, mantener el formato con código de país
      return cleaned;
    } else if (cleaned.length == 9) {
      // Si es solo el número sin código de país, agregar 51 para Perú
      return '51$cleaned';
    }
    
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
        type: WhatsApp.standard, // Cambiar a WhatsApp.business si es necesario
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
}
