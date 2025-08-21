# 🗺️ CitiesApp

Aplicación iOS desarrollada en **Swift** con arquitectura **MVVM**, que permite explorar y buscar entre ~200k ciudades del mundo. Incluye información detallada de cada ciudad y acceso rápido a su ubicación en el mapa.

## ✨ Características

- Descarga una lista de **~200k ciudades** desde un servicio remoto.  
- Búsqueda rápida y eficiente con soporte **case/diacritic insensitive** (ignora mayúsculas y acentos).  
- Filtrado por texto y por **favoritos**.  
- Vista de detalle de ciudad con:  
  - Nombre del país  
  - Moneda  
  - Bandera  
  - Ubicación en el mapa  
- Persistencia de favoritos con `UserDefaults`.  
- Soporte de **localización** (`Localizable.xcstrings`).  
- Tests unitarios de la lógica de negocio.  

## 🏛️ Arquitectura

El proyecto sigue el patrón **MVVM**:  

- **Model**  
  - `City`, `Coord` (entidades `Codable`).  

- **ViewModel**  
  - `CityListViewModel`: carga de ciudades, búsqueda, filtrado y manejo de favoritos.  
  - `CityInfoViewModel`: obtiene datos complementarios como país, moneda y bandera.  

- **View (SwiftUI)**  
  - `CityListView`: listado con buscador y gestión de favoritos.  
  - `CityInfoView`: detalle de ciudad con mapa, bandera e información adicional.  

## ⚙️ Configuración

1. Clonar el repositorio:  
   ```bash
   git clone https://github.com/usuario/citiesapp.git
   cd citiesapp
   ```  

2. Abrir el proyecto en Xcode:  
   ```bash
   open CitiesApp.xcodeproj
   ```  

3. Configurar las URLs en `AppConfig`:  
   - `citiesURL`: URL del JSON de ciudades.  
   - `flagsURL`: plantilla para banderas (ej: `"https://flaglog.com/codes/standardized-rectangle-120px/%@.png"`).  

4. Ejecutar en el simulador.  

## 🧪 Tests

El proyecto incluye dos tipos de pruebas automatizadas:  

- **`CitiesAppTests`** → pruebas unitarias de la lógica interna  
  - Carga y parseo de datos  
  - Búsqueda y filtrado  
  - Persistencia de favoritos  

- **`CitiesAppUITests`** → pruebas de interfaz de usuario  
  - Validan flujos completos de la app  
  - Interacciones como búsqueda, selección y visualización de detalles  

Ejecutar los tests:  
```bash
⌘ + U
```  

## 📄 Requisitos

- Xcode 15+  
- iOS 17+  
- Swift 5.9+  

## 📌 Próximos pasos / Mejoras

- Soporte offline.  
- UI mejorada para tablets.  
