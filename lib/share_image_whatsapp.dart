/// A powerful Flutter plugin for sharing text, images, and QR codes directly to WhatsApp.
/// Supports WhatsApp Business and multiple platforms with direct sending capabilities.
library share_image_whatsapp;

import 'package:cross_file/cross_file.dart';
import 'share_whatsapp_platform_interface.dart';
import 'src/enums.dart';

// Export all necessary components
export 'package:cross_file/cross_file.dart';
export 'share_whatsapp_url.dart';
export 'src/enums.dart' show WhatsApp;
export 'src/qr_whatsapp_helper.dart';

/// Global singleton [ShareImageWhatsapp] instance
final shareImageWhatsapp = ShareImageWhatsapp();

/// Backward compatibility - deprecated, use shareImageWhatsapp instead
@Deprecated('Use shareImageWhatsapp instead')
final shareWhatsapp = shareImageWhatsapp;

/// Share your text message or file directly into Whatsapp
class ShareImageWhatsapp {
  /// Checks whether whatsapp is installed in device platform
  ///
  /// [type] is optional enum parameter which is default to [WhatsApp.standard]
  /// for business whatsapp set it to [WhatsApp.business]
  ///
  /// return true if installed otherwise false.
  Future<bool> installed({WhatsApp type = WhatsApp.standard}) {
    return ShareWhatsappPlatform.instance.installed(type: type);
  }

  /// Share text message into whatsapp
  ///
  /// [phone] is optional for Android, mandatory for Web, MacOS, Linux and Windows.
  /// But it will be ignored on iOS.
  Future<bool> shareText(String text,
          {String? phone, WhatsApp type = WhatsApp.standard}) =>
      share(type: type, text: text, phone: phone);

  /// Share file into whatsapp
  ///
  /// [phone] is optional for Android, mandatory for Web, MacOS, Linux and Windows.
  /// But it will be ignored on iOS.
  Future<bool> shareFile(XFile file,
          {String? phone, WhatsApp type = WhatsApp.standard}) =>
      share(type: type, file: file, phone: phone);

  /// Share text message and or file into whatsapp
  ///
  /// [phone] is optional for Android, mandatory for Web, MacOS, Linux and Windows.
  /// But it will be ignored on iOS.
  ///
  /// You need to either set [text] and or [phone].
  Future<bool> share({
    WhatsApp type = WhatsApp.standard,
    String? phone,
    String? text,
    XFile? file,
  }) {
    assert(!(text == null && file == null), "Either set text and or file");

    return ShareWhatsappPlatform.instance
        .share(type: type, phone: phone, text: text, file: file);
  }
}
