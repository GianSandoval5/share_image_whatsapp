import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_image_whatsapp/share_image_whatsapp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final _mapInstalled = WhatsApp.values.asMap().map<WhatsApp, String?>((
    key,
    value,
  ) {
    return MapEntry(value, null);
  });
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkInstalledWhatsApp();
  }

  Future<void> _checkInstalledWhatsApp() async {
    String whatsAppInstalled = await _check(WhatsApp.standard),
        whatsAppBusinessInstalled = await _check(WhatsApp.business);

    if (!mounted) return;

    setState(() {
      _mapInstalled[WhatsApp.standard] = whatsAppInstalled;
      _mapInstalled[WhatsApp.business] = whatsAppBusinessInstalled;
    });
  }

  Future<String> _check(WhatsApp type) async {
    try {
      return await shareImageWhatsapp.installed(type: type)
          ? 'INSTALLED'
          : 'NOT INSTALLED';
    } on PlatformException catch (e) {
      return e.message ?? 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share WhatsApp Example')),
      body: Column(
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: RepaintBoundary(
              key: _qrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(10),
                child: QrImageView(
                  data:
                      "https://cdn.pixabay.com/photo/2012/04/13/01/23/moon-31665_1280.png",
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  embeddedImage: AssetImage(''),
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(40, 40),
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Share QR Code'),
            trailing: const Icon(Icons.share),
            onTap: () async {
              String numero = '984505564'; // Reemplaza con el número real
              // Usar el nuevo helper para compartir QR
              final success = await QRWhatsAppHelper.sendQRToWhatsApp(
                mensaje: "HOLA PROBANDO COMPARTIR QR - probando desde el package",
                phone: numero,
                qrKey: _qrKey,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'QR compartido exitosamente'
                          : 'Error al compartir QR',
                    ),
                  ),
                );
              }
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('ℹ️ Información'),
            subtitle: Text('Si el número no está en tus contactos, WhatsApp pedirá seleccionar contacto. Esto es normal y esperado.'),
          ),
          const ListTile(title: Text('STATUS INSTALLATION')),
          ...WhatsApp.values.map((type) {
            final status = _mapInstalled[type];

            return ListTile(
              title: Text(type.toString()),
              trailing: status != null
                  ? Text(status)
                  : const CircularProgressIndicator.adaptive(),
            );
          }),
        ],
      ),
    );
  }
}
