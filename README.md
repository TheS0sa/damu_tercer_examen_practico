# Springfield Archive

Aplicación Flutter para explorar personajes de **Los Simpson** con datos reales
de [The Simpsons API](https://thesimpsonsapi.com/). La interfaz usa una estética
editorial retro, con colores inspirados en Springfield y un diseño distinto al
proyecto de referencia.

## Funcionalidades

- Catálogo consultado por HTTPS con paginación desde la API.
- Búsqueda local por nombre dentro de la página cargada.
- Ficha con imagen, estado, ocupación, género, edad, fecha de nacimiento y una
  frase cuando esos datos están disponibles.
- Favoritos que se pueden agregar o quitar y que se conservan localmente entre
  ejecuciones mediante `SharedPreferences`.
- Indicadores de carga, estados vacíos, mensajes comprensibles de error y
  opción para reintentar.
- Sustituto visual si no se puede cargar una imagen remota.

## Tecnologías y API

- Flutter y Dart.
- Paquete `http` para solicitudes GET.
- Paquete `shared_preferences` para persistir favoritos.
- Catálogo: `https://thesimpsonsapi.com/api/characters?page=1`
- Detalle: `https://thesimpsonsapi.com/api/characters/{id}`
- Imágenes: `https://cdn.thesimpsonsapi.com/500` + `portrait_path`
- Documentación: [thesimpsonsapi.com](https://thesimpsonsapi.com/)

No requiere servidor propio ni base de datos: la evaluación solicita guardar
localmente los favoritos y no requiere una API propia.

## Ejecutar

Desde esta carpeta:

```powershell
flutter pub get
flutter run
```

Validación:

```powershell
flutter analyze
flutter test
```

## Integrantes

- Completar con los nombres de los integrantes del equipo.
