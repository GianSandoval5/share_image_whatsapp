import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/share_whatsapp_method_channel.dart';
import '../lib/src/enums.dart';

void main() {
  MethodChannelShareWhatsapp platform = MethodChannelShareWhatsapp();
  const MethodChannel channel = MethodChannel('share_whatsapp');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'installed') {
        if (methodCall.arguments == WhatsApp.standard.packageName) {
          return 1;
        } else if (methodCall.arguments == WhatsApp.business.packageName) {
          return 0;
        }
      }

      throw PlatformException(
        code: 'UNKNOWN_METHOD',
        message: 'Unknown method ${methodCall.method}',
      );
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('installed', () async {
    expect(await platform.installed(type: WhatsApp.standard), true);
    expect(await platform.installed(type: WhatsApp.business), false);
  });
}
