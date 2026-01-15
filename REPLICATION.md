# Guía de Replicación

Esta guía explica cómo replicar los resultados de los notebooks principales:
- `notebooks/00_process_complete_until_training.ipynb`
- `notebooks/01_results_and_performance.ipynb`

## 📋 Requisitos Previos

1. **Datos necesarios**: Descarga los siguientes archivos de datos y colócalos en la carpeta `data/`:
   - `Loan_status_2007-2020Q3.csv` (o `Loan_status_2007-2020Q3.csv.gz`)
   - `accepted_2007_to_2018Q4.csv` (o `accepted_2007_to_2018Q4.csv.gz`)

   > **Nota**: Estos archivos son grandes y no están incluidos en el repositorio. Debes descargarlos desde Kaggle o la fuente original.

2. **Ambiente Python**: Sigue las instrucciones del `README.md` para configurar el ambiente conda.

## 🔄 Proceso de Replicación

### Paso 1: Ejecutar `00_process_complete_until_training.ipynb`

Este notebook:
- Procesa los datos originales
- Identifica columnas disponibles al momento de originación
- Entrena los modelos
- Guarda los resultados en `results/` y `config/`

**Archivos generados** (necesarios para el siguiente notebook):
- `data/data_train_oot_round01.csv` - Datos procesados
- `results/experimentos_catboost_round01_complete_*.pkl` - Resultados completos de experimentos
- `config/columnas_config_round01.json` - Configuración de columnas

> **Importante**: Los nombres de archivos incluyen timestamps. Después de ejecutar este notebook, actualiza las rutas en el siguiente notebook con los nombres reales generados.

### Paso 2: Actualizar rutas en `01_results_and_performance.ipynb`

Antes de ejecutar el segundo notebook, actualiza las siguientes celdas con los nombres de archivos generados en el Paso 1:

1. **Cargar datos procesados** (aproximadamente línea 210):
   ```python
   df_old02 = pd.read_csv("../data/data_train_oot_round01.csv")
   ```

2. **Cargar resultados de experimentos** (aproximadamente línea 212):
   ```python
   results_from_pickle = load_experiment_results(
       file_path="../results/experimentos_catboost_round01_complete_YYYYMMDD_HHMMSS.pkl"
   )
   ```
   > Reemplaza `YYYYMMDD_HHMMSS` con el timestamp real del archivo generado.

3. **Cargar configuración de columnas** (aproximadamente línea 231):
   ```python
   config_cargado = load_dict_with_lists(
       file_path='../config/columnas_config_round01.json'
   )
   ```

### Paso 3: Ejecutar `01_results_and_performance.ipynb`

Este notebook:
- Carga los resultados del entrenamiento
- Calcula scores para la población
- Genera visualizaciones y análisis de SHAP

**Nota sobre paths**: Los paths de guardado en este notebook usan rutas relativas (`../plots/`, `../results/`). Asegúrate de ejecutar los notebooks desde la carpeta `notebooks/` o ajusta los paths según tu estructura.

## 📁 Estructura de Archivos Esperada

```
.
├── data/
│   ├── Loan_status_2007-2020Q3.csv (o .csv.gz)
│   ├── accepted_2007_to_2018Q4.csv (o .csv.gz)
│   └── data_train_oot_round01.csv (generado por notebook 00)
├── config/
│   └── columnas_config_round01.json (generado por notebook 00)
├── results/
│   └── experimentos_catboost_round01_complete_*.pkl (generado por notebook 00)
├── plots/ (generado por notebook 01, opcional)
└── notebooks/
    ├── 00_process_complete_until_training.ipynb
    └── 01_results_and_performance.ipynb
```

## ⚠️ Notas Importantes

1. **Timestamps en nombres de archivos**: Los archivos de resultados incluyen timestamps. Debes actualizar manualmente las rutas en el segundo notebook después de ejecutar el primero.

2. **Paths relativos**: Los notebooks asumen que se ejecutan desde la carpeta `notebooks/`. Si ejecutas desde otra ubicación, ajusta los paths (`../data/` → ruta correcta).

3. **Datos grandes**: Los archivos de datos y modelos entrenados no están en el repositorio. Debes descargarlos o generarlos ejecutando el notebook 00.

4. **Reproducibilidad**: Para resultados exactamente iguales, asegúrate de usar las mismas versiones de las librerías especificadas en `requirements.txt` y establecer las mismas semillas (ya configuradas en el código).

## 🐛 Solución de Problemas

### Error: "File not found"
- Verifica que los archivos de datos estén en `data/`
- Verifica que hayas ejecutado el notebook 00 antes del 01
- Actualiza las rutas con los nombres de archivos reales generados

### Error: "Module not found"
- Asegúrate de haber activado el ambiente conda: `conda activate lending_club`
- Verifica que todas las dependencias estén instaladas: `pip install -r requirements.txt`

### Los resultados son diferentes
- Verifica que estés usando las mismas versiones de librerías
- Asegúrate de que las semillas estén configuradas (ya están en el código)
- Verifica que los datos de entrada sean los mismos

