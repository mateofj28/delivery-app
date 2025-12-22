# DeliveryApp

Una aplicación móvil simple de pedidos a domicilio desarrollada en Flutter.

## Características

- **Pantalla inicial** con botón principal "Pedir domicilio"
- **Lista de negocios** disponibles
- **Catálogo de productos** por negocio
- **Carrito de compras** con gestión de cantidades
- **Formulario de pedido** con datos del cliente
- **Confirmación** y envío directo a WhatsApp

## Tecnologías utilizadas

- **Flutter** 3.10+
- **Riverpod** para gestión de estado
- **Go Router** para navegación
- **Google Fonts** (Poppins)
- **URL Launcher** para WhatsApp

## Arquitectura

El proyecto sigue **Clean Architecture** con la siguiente estructura:

```
lib/
├── core/           # Constantes, temas, utilidades
├── data/           # Implementaciones de repositorios
├── domain/         # Entidades y contratos
└── presentation/   # UI, providers, screens, widgets
```

## Instalación

1. Clona el repositorio
2. Ejecuta `flutter pub get`
3. Ejecuta `flutter run`

## Funcionalidades

### ✅ Implementado
- Navegación entre pantallas
- Gestión de estado con Riverpod
- Carrito de compras funcional
- Formulario de pedido con validación
- Generación de mensaje para WhatsApp
- Diseño minimalista con colores corporativos

### 🎨 Diseño
- Color principal: Rojo coral (#E74C3C)
- Color de acción: Amarillo mostaza (#F1C40F)
- Tipografía: Poppins
- Botones tipo pill
- Estilo flat y minimalista

## Flujo de la aplicación

1. **Inicio** → Botón "Pedir domicilio"
2. **Negocios** → Seleccionar negocio
3. **Productos** → Agregar al carrito
4. **Carrito** → Revisar pedido
5. **Formulario** → Datos del cliente
6. **Confirmación** → Enviar a WhatsApp

## Configuración de WhatsApp

Los números de WhatsApp están configurados en el repositorio de datos. Para cambiarlos, edita el archivo:
`lib/data/repositories/business_repository_impl.dart`

## Notas

- No incluye sistema de pagos
- No requiere registro de usuarios
- Enfocado en simplicidad y rapidez
- Envío directo a WhatsApp del negocio