# Share Image WhatsApp 📱

[![pub package](https://img.shields.io/pub/v/share_image_whatsapp.svg)](https://pub.dartlang.org/packages/share_image_whatsapp)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://flutter.dev)

Un potente plugin de Flutter que te permite compartir contenido (texto, imágenes, o ambos) directamente a WhatsApp desde tu aplicación Flutter. Incluye soporte para WhatsApp y WhatsApp Business, capacidades de compartir códigos QR, y compatibilidad multiplataforma.

## ✨ Características

- 📤 Compartir mensajes de texto a WhatsApp
- 🖼️ Compartir imágenes a WhatsApp  
- 📱 Compartir combinaciones de texto + imagen
- 💼 Soporte para WhatsApp Business
- 📞 Compartir directamente a números específicos
- 🔗 Helper para compartir códigos QR incluido
- 🌐 Soporte multiplataforma (Android, iOS, Web, Desktop)
- 🎯 Diálogos de compartir nativos en plataformas móviles

## 🚀 Instalación

Agrega este paquete a tu `pubspec.yaml`:

```yaml
dependencies:
  share_image_whatsapp: ^1.0.2
```

Luego ejecuta:
```bash
flutter pub get
```

### 📱 Configuración Específica por Plataforma

#### Configuración iOS
Agrega esto a tu archivo `Info.plist` en el directorio `ios/Runner/`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>whatsapp</string>
    <string>whatsapp-business</string>
</array>
```

#### Configuración Android
¡No requiere configuración adicional! El plugin funciona de inmediato en Android.

## 🎯 Uso

### Compartir Texto Básico

```dart
import 'package:share_image_whatsapp/share_whatsapp.dart';

// Compartir texto simple
await shareImageWhatsapp.shareText(
  "¡Hola desde mi app de Flutter! 👋",
  phone: "+51987654321", // Opcional en Android, requerido en otras plataformas
);
```

### Compartir Imágenes

```dart
import 'package:cross_file/cross_file.dart';

// Compartir una imagen
final imageFile = XFile('ruta/a/tu/imagen.jpg');
await shareImageWhatsapp.shareFile(
  imageFile,
  phone: "+51987654321",
);
```

### Compartir Texto + Imagen Combinado

```dart
// Compartir texto con imagen (solo Android)
final imageFile = XFile('ruta/a/tu/imagen.jpg');
await shareImageWhatsapp.share(
  text: "¡Mira esta imagen increíble! 📸",
  file: imageFile,
  phone: "+51987654321",
  type: WhatsApp.standard, // o WhatsApp.business
);
```

### 🔍 Compartir Códigos QR

El plugin incluye un potente helper para compartir códigos QR:

```dart
import 'package:share_image_whatsapp/share_whatsapp.dart';

// Crear un widget QR con un GlobalKey
final GlobalKey qrKey = GlobalKey();

// En tu árbol de widgets
RepaintBoundary(
  key: qrKey,
  child: QrImageView(
    data: "Tus datos del QR aquí",
    version: QrVersions.auto,
    size: 200.0,
  ),
)

// Compartir el código QR
final success = await QRWhatsAppHelper.sendQRToWhatsApp(
  mensaje: "¡Aquí tienes un código QR! 📱",
  phone: "+51987654321",
  qrKey: qrKey,
  type: WhatsApp.standard,
);
```

### Verificar Instalación de WhatsApp

```dart
// Verificar si WhatsApp está instalado
bool isInstalled = await shareImageWhatsapp.installed();

// Verificar WhatsApp Business
bool isBusinessInstalled = await shareImageWhatsapp.installed(
  type: WhatsApp.business
);
```

## 🌍 Compatibilidad de Plataformas

|                    | Web | Android | iOS | MacOS | Windows | Linux |
|--------------------|:---:|:-------:|:---:|:-----:|:-------:|:-----:|
| Compartir Texto    | ✅  |   ✅    | ✅  |  ✅   |   ✅    |  ✅   |
| Compartir Imagen   | ❌  |   ✅    | ✅  |  ❌   |   ❌    |  ❌   |
| Texto+Imagen       | ❌  |   ✅    | ❌  |  ❌   |   ❌    |  ❌   |
| Enviar a Número    | ✅  |   ✅    | ❌* |  ✅   |   ✅    |  ✅   |
| WhatsApp Business  | ✅  |   ✅    | ✅  |  ✅   |   ✅    |  ✅   |
| Compartir QR       | ❌  |   ✅    | ✅  |  ❌   |   ❌    |  ❌   |

> **Notas:**
> - ✅ = Totalmente soportado
> - ❌ = No soportado  
> - ❌* = iOS ignora números de teléfono debido a limitaciones de la plataforma
> - Los números de teléfono son obligatorios para Web, MacOS, Windows y Linux
> - Los números de teléfono son opcionales solo para Android

## 📝 Referencia de API

### Métodos Principales

#### `shareText(String text, {String? phone, WhatsApp type})`
Compartir un mensaje de texto a WhatsApp.

#### `shareFile(XFile file, {String? phone, WhatsApp type})`
Compartir un archivo de imagen a WhatsApp.

#### `share({String? text, XFile? file, String? phone, WhatsApp type})`
Compartir texto y/o archivo a WhatsApp.

#### `installed({WhatsApp type})`
Verificar si WhatsApp está instalado en el dispositivo.

### Métodos de QRWhatsAppHelper

#### `sendQRToWhatsApp({required String mensaje, required String phone, required GlobalKey qrKey, WhatsApp type})`
Capturar un widget QR y compartirlo a WhatsApp.

#### `isWhatsAppAvailable({WhatsApp type})`
Verificar disponibilidad de WhatsApp antes de compartir.

### Enumeraciones

#### `WhatsApp`
- `WhatsApp.standard` - WhatsApp normal
- `WhatsApp.business` - WhatsApp Business

## 💡 Ejemplo

Revisa el ejemplo completo en la carpeta `/example` que demuestra:

- ✅ Verificación del estado de instalación de WhatsApp
- 📱 Generación y compartir códigos QR
- 🎯 Compartir texto e imágenes
- 💼 Integración con WhatsApp Business

## 🔧 Solución de Problemas

### Problemas Comunes

1. **iOS no abre WhatsApp**: Asegúrate de haber agregado los esquemas de URL al `Info.plist`
2. **Formato de número de teléfono**: Usa formato internacional con código de país (ej. "+51987654321")
3. **Compartir archivos en iOS**: Asegúrate de que tus archivos de imagen sean accesibles y estén en el formato correcto
4. **Compartir QR no funciona**: Verifica que el GlobalKey esté correctamente adjunto a un widget RepaintBoundary

### Formato de Números de Teléfono

El plugin formatea automáticamente los números de teléfono, pero asegúrate de que incluyan el código de país:

```dart
// ✅ Formatos correctos
"+51987654321"
"51987654321"
"987654321" // Se agregará automáticamente el código de país de Perú (+51)

// ❌ Evitar
"(+51) 987-654-321" // Se limpiará pero evita caracteres especiales
```

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor, siéntete libre de enviar un Pull Request. Para cambios importantes, por favor abre un issue primero para discutir lo que te gustaría cambiar.

1. Haz fork del proyecto
2. Crea tu rama de funcionalidad (`git checkout -b feature/CaracteristicaIncreible`)
3. Confirma tus cambios (`git commit -m 'Agregar alguna CaracteristicaIncreible'`)
4. Empuja a la rama (`git push origin feature/CaracteristicaIncreible`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - consulta el archivo [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Autor

**Gian Sandoval** - [GianSandoval5](https://github.com/GianSandoval5)

---

⭐ ¡Si este plugin te ayudó, por favor dale una estrella en [GitHub](https://github.com/GianSandoval5/share_image_whatsapp)!