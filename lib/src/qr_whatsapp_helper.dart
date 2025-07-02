import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';

import '../share_whatsapp.dart';

/// Helper class for sharing QR codes specifically to WhatsApp
class QRWhatsAppHelper {
  /// Captures a QR widget and shares it to WhatsApp with a specific phone number
  ///
  /// [mensaje] - The message to send along with the QR code
  /// [phone] - The phone number to send to
  /// [qrKey] - GlobalKey attached to the QR widget to capture it
  /// [type] - WhatsApp type (standard or business)
  static Future<bool> sendQRToWhatsApp({
    required String mensaje,
    required String phone,
    required GlobalKey qrKey,
    WhatsApp type = WhatsApp.standard,
  }) async {
    try {
      // 1. Capture QR widget as image
      final RenderRepaintBoundary boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final ByteData? byteData =
          await image.toByteData(format: ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 2. Save image temporarily
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // 3. Format phone number
      String phoneNumber = _formatPhoneNumber(phone);

      // 4. Share using the share_whatsapp package
      final xFile = XFile(imagePath);
      final success = await shareImageWhatsapp.share(
        file: xFile,
        phone: phoneNumber,
        text: mensaje,
        type: type,
      );

      // 5. Clean up temporary file
      try {
        await imageFile.delete();
      } catch (e) {
        // Ignore cleanup errors
      }

      return success;
    } catch (e) {
      print('Error sharing QR to WhatsApp: $e');
      return false;
    }
  }

  /// Formats phone number to international format
  static String _formatPhoneNumber(String phone) {
    String phoneNumber = phone.trim();
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''); // Solo números

    // Add country code if not present (assuming Peru +51)
    if (!phoneNumber.startsWith('51') && phoneNumber.length == 9) {
      phoneNumber = '51$phoneNumber';
    }

    return '+$phoneNumber';
  }

  /// Checks if WhatsApp is installed before attempting to share
  static Future<bool> isWhatsAppAvailable({WhatsApp type = WhatsApp.standard}) {
    return shareImageWhatsapp.installed(type: type);
  }
}
