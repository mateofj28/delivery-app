# DeliveryApp

Una aplicación móvil completa de pedidos a domicilio desarrollada en Flutter con panel de administración.

## 🚀 Características Principales

### Para Clientes
- **Pantalla inicial** con botón principal "Pedir domicilio"
- **Lista de negocios** disponibles con información detallada
- **Catálogo de productos** por negocio con categorías
- **Carrito de compras** con gestión de cantidades y precios
- **Formulario de pedido** con datos del cliente y dirección
- **Confirmación** y envío directo a WhatsApp (+573026699574)

### Para Administradores
- **Panel de administración** con login seguro (admin/admin123)
- **Dashboard** con estadísticas y resumen
- **Gestión de negocios** (crear, editar, eliminar)
- **Gestión de productos** por negocio con categorías
- **Formularios completos** con validación
- **Interfaz intuitiva** y responsive

## 🛠 Tecnologías Utilizadas

- **Flutter** 3.10+ con Dart
- **Riverpod** para gestión de estado reactivo
- **Go Router** para navegación declarativa
- **Google Fonts** (Poppins) para tipografía
- **URL Launcher** para integración WhatsApp
- **Material Design 3** para componentes UI

## 🏗 Arquitectura

El proyecto implementa **Clean Architecture** con separación clara de responsabilidades:

```
lib/
├── core/
│   ├── constants/     # Colores, strings, configuraciones
│   ├── router/        # Configuración de rutas
│   ├── theme/         # Tema y estilos globales
│   └── utils/         # Utilidades y helpers
├── data/
│   └── repositories/  # Implementaciones de repositorios
├── domain/
│   ├── entities/      # Modelos de datos (Business, Product, Admin)
│   └── repositories/  # Contratos de repositorios
└── presentation/
    ├── providers/     # Providers de Riverpod
    ├── screens/       # Pantallas de la aplicación
    │   ├── admin/     # Panel de administración
    │   └── customer/  # Flujo del cliente
    └── widgets/       # Componentes reutilizables
```

## 📱 Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.10+
- Dart SDK 3.0+
- Android Studio / VS Code
- Dispositivo Android o emulador

### Pasos de instalación
```bash
# 1. Clonar el repositorio
git clone https://github.com/mateofj28/delivery-app.git
cd delivery-app

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar la aplicación
flutter run
```

### Configuración Android NDK
El proyecto requiere Android NDK 27.0.12077973. Si encuentras advertencias, actualiza en `android/app/build.gradle.kts`:
```kotlin
android {
    ndkVersion = "27.0.12077973"
    // ...
}
```

## 🎨 Diseño y UI/UX

### Paleta de Colores
- **Primario**: Rojo coral (#E74C3C)
- **Secundario**: Amarillo mostaza (#F1C40F)
- **Fondo**: Blanco (#FFFFFF)
- **Superficie**: Gris claro (#F8F9FA)
- **Texto**: Negro/Gris oscuro

### Características de Diseño
- **Tipografía**: Poppins (moderna y legible)
- **Botones**: Estilo pill (totalmente redondeados)
- **Inputs**: Limpios sin bordes gruesos
- **Iconos**: Material Icons filled
- **Estilo**: Flat y minimalista
- **Responsive**: Adaptable a diferentes tamaños

## 🔄 Flujo de la Aplicación

### Flujo del Cliente
1. **Inicio** → Botón "Pedir domicilio"
2. **Negocios** → Seleccionar negocio disponible
3. **Productos** → Explorar catálogo y agregar al carrito
4. **Carrito** → Revisar pedido y cantidades
5. **Formulario** → Ingresar datos personales y dirección
6. **Confirmación** → Revisar pedido completo
7. **WhatsApp** → Envío automático del pedido

### Flujo del Administrador
1. **Login** → Credenciales admin/admin123
2. **Dashboard** → Vista general del sistema
3. **Negocios** → Gestionar lista de negocios
4. **Productos** → Administrar catálogo por negocio
5. **Formularios** → Crear/editar con validación completa

## 📋 Funcionalidades Implementadas

### ✅ Completado
- **Navegación fluida** entre todas las pantallas
- **Gestión de estado** reactiva con Riverpod
- **Carrito funcional** con persistencia temporal
- **Validación de formularios** completa
- **Integración WhatsApp** con mensaje estructurado
- **Panel admin completo** con CRUD de negocios/productos
- **Formato de precios** con separador de miles ($25.000)
- **UI responsive** sin errores de overflow
- **Tema consistente** en toda la aplicación

### 🎯 Características Técnicas
- **Clean Architecture** bien implementada
- **Separación de responsabilidades** clara
- **Código mantenible** y escalable
- **Gestión de estado** eficiente
- **Navegación declarativa** con Go Router
- **Validación robusta** de formularios
- **Manejo de errores** apropiado

## 📞 Configuración de WhatsApp

El número de WhatsApp está configurado globalmente como **+573026699574**. 

Para modificarlo, edita:
```dart
// lib/data/repositories/business_repository_impl.dart
// Buscar y cambiar el número en el método de envío
```

## 🔐 Credenciales de Administrador

- **Usuario**: `admin`
- **Contraseña**: `admin123`

## 📝 Estructura de Datos

### Business (Negocio)
```dart
class Business {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final bool isActive;
  final List<Product> products;
}
```

### Product (Producto)
```dart
class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String? category;
  final String? imageUrl;
  final bool isAvailable;
}
```

## 🚫 Limitaciones por Diseño

- **Sin sistema de pagos**: Enfocado en simplicidad
- **Sin registro de usuarios**: Acceso directo
- **Sin seguimiento en tiempo real**: Gestión por WhatsApp
- **Sin gestión de domiciliarios**: Responsabilidad del negocio
- **Almacenamiento local**: Sin base de datos externa

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👨‍💻 Desarrollado por

**Mateo FJ** - [GitHub](https://github.com/mateofj28)

---

*Aplicación desarrollada con Flutter siguiendo las mejores prácticas de Clean Architecture y Material Design.*