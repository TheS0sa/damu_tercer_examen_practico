# Archivo de Springfield - Tercer Examen Práctico

Esta aplicación móvil fue desarrollada en Flutter para la materia de Desarrollo de Aplicaciones Móviles. El objetivo del proyecto es conectarse a la API pública de Los Simpson para consultar su catálogo de personajes, ver la información de cada uno y guardar una lista de favoritos en el dispositivo.

## Integrantes del equipo

- **Jeferson Isac Umaña**
- **Brayant Steven Sosa**

**Docente:** Ing. Eduardo Vásquez

## ¿Qué hace la aplicación?

1. **Inicio de sesión (Login):** Antes de entrar al catálogo, la app pide iniciar sesión validando que los campos no estén vacíos y comprobando las credenciales del usuario (`admin` / `1234`). También incluye un botón en la pantalla principal para cerrar sesión.
2. **Catálogo con paginación:** Al entrar, se descarga la primera página de personajes desde la API mostrando su foto, nombre, edad, estado y ocupación. Abajo tiene los botones de "Anterior" y "Siguiente" para moverse entre las 60 páginas disponibles.
3. **Buscador global por nombre:** Permite escribir el nombre de cualquier personaje en la barra de búsqueda y lo busca en todas las páginas del catálogo, sin importar si está en la página 1 o en la última.
4. **Ficha de detalle:** Al tocar un personaje, se abre otra pantalla con su imagen más grande y más datos como su edad, género, fecha de nacimiento y frases conocidas.
5. **Favoritos guardados:** Se pueden marcar o quitar personajes como favoritos tocando el ícono de guardado. Estos favoritos se guardan en la memoria local con `SharedPreferences` para que no se pierdan al cerrar y volver a abrir la aplicación.
6. **Manejo de errores y carga:** Muestra animaciones mientras carga la información, avisa cuando una búsqueda no tiene resultados y muestra un botón para reintentar si se va el internet.

## Herramientas utilizadas

- **Flutter y Dart** para toda la interfaz y lógica.
- Paquete **`http`** para conectarse a `https://thesimpsonsapi.com/`.
- Paquete **`shared_preferences`** para guardar la lista de favoritos en el dispositivo.
- **`ChangeNotifier`** para actualizar la pantalla cuando cambian las páginas o los favoritos.
