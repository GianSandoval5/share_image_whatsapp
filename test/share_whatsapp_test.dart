import 'package:flutter_test/flutter_test.dart';
import '../lib/share_whatsapp.dart';
import '../lib/share_whatsapp_platform_interface.dart';
import '../lib/share_whatsapp_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockShareWhatsappPlatform
    with MockPlatformInterfaceMixin
    implements ShareWhatsappPlatform {
  @override
  Future<bool> installed({WhatsApp type = WhatsApp.standard}) =>
      Future.value(type == WhatsApp.standard);

  @override
  Future<bool> share({
    WhatsApp type = WhatsApp.standard,
    String? phone,
    String? text,
    XFile? file,
  }) =>
      Future.value(true);
}

void main() {
  final ShareWhatsappPlatform initialPlatform = ShareWhatsappPlatform.instance;

  test('$MethodChannelShareWhatsapp is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelShareWhatsapp>());
  });

  test('installed whatsapp standard', () async {
    ShareImageWhatsapp shareWhatsappPlugin = ShareImageWhatsapp();
    MockShareWhatsappPlatform fakePlatform = MockShareWhatsappPlatform();
    ShareWhatsappPlatform.instance = fakePlatform;

    expect(await shareWhatsappPlugin.installed(type: WhatsApp.standard), true);
  });

  test('not installed whatsapp business', () async {
    ShareImageWhatsapp shareWhatsappPlugin = ShareImageWhatsapp();
    MockShareWhatsappPlatform fakePlatform = MockShareWhatsappPlatform();
    ShareWhatsappPlatform.instance = fakePlatform;

    expect(await shareWhatsappPlugin.installed(type: WhatsApp.business), false);
  });
}
