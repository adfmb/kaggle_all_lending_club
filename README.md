# All Lending Club Data

Proyecto con todos los datos de préstamos de Lending Club para determinar a quién aprobar y a quién rechazar.

## 🚀 Configuración del Ambiente

Este repositorio utiliza `conda` para mantener la replicabilidad del ambiente de desarrollo.

### Requisitos Previos

- Sistema operativo: macOS o Linux
- Terminal con bash
- Archivos de datos: Descarga y coloca los siguientes archivos en la carpeta `data/`:
  - `rejected_2007_to_2018Q4.csv.gz`
  - `accepted_2007_to_2018Q4.csv.gz`

> **Nota**: El script `setup.sh` creará automáticamente la carpeta `data/` si no existe y descomprimirá los archivos `.csv.gz` si aún no están descomprimidos.

### Instalación Automática

Ejecuta el script de configuración que automatiza todo el proceso:

```bash
./setup.sh
```

El script realizará las siguientes acciones:

1. **Verifica si conda está instalado**: Si no está instalado, te preguntará si deseas descargar e instalar Miniconda automáticamente.

2. **Solicita el nombre del ambiente**: Puedes elegir un nombre personalizado o usar el predeterminado (`lending_club`).

3. **Crea el ambiente conda**: Genera un nuevo ambiente virtual con todas las dependencias necesarias.

4. **Instala las dependencias**: Instala automáticamente todos los paquetes listados en `requirements.txt`.

5. **Configura Jupyter**: Registra el ambiente como un kernel de Jupyter para usar en notebooks.

6. **Prepara los datos**: Crea la carpeta `data/` si no existe y descomprime automáticamente los archivos `.csv.gz` si aún no están descomprimidos.

### Instalación Manual

Si prefieres hacerlo manualmente:

```bash
# Crear el ambiente desde environment.yml
conda env create -f environment.yml

# Activar el ambiente
conda activate lending_club

# O instalar desde requirements.txt directamente
pip install -r requirements.txt
```

## 📓 Uso de Notebooks

### Seleccionar el Kernel en Cursor

Después de ejecutar `setup.sh`, el ambiente conda se registra como un kernel de Jupyter. Para usar este kernel en tus notebooks dentro de Cursor:

1. Abre un notebook (`.ipynb`) en Cursor
2. Haz clic en el selector de kernel en la esquina superior derecha del notebook (o presiona `Cmd+Shift+P` / `Ctrl+Shift+P` y busca "Select Kernel")
3. Selecciona el kernel que corresponde al nombre del ambiente que creaste (por ejemplo, `Python (lending_club)` o `Python (tu_nombre_ambiente)`)
4. Si no aparece el kernel, asegúrate de que el script `setup.sh` se ejecutó correctamente y que el kernel fue registrado

> **Nota**: El nombre del kernel será `Python (<nombre_del_ambiente>)` donde `<nombre_del_ambiente>` es el que elegiste al ejecutar `setup.sh` (o `lending_club` si usaste el predeterminado).

### Uso desde Terminal

También puedes usar los notebooks desde la terminal:

```bash
# Activar el ambiente
conda activate lending_club

# Iniciar Jupyter Notebook
jupyter notebook

# O iniciar JupyterLab
jupyter lab
```

Los notebooks deben guardarse en la carpeta `notebooks/`.

### Notebooks Principales

Este proyecto incluye dos notebooks principales para replicar el análisis completo:

1. **`notebooks/00_process_complete_until_training.ipynb`**: 
   - Procesa los datos originales
   - Identifica columnas disponibles al momento de originación
   - Entrena modelos de machine learning
   - Genera archivos de resultados y configuración

2. **`notebooks/01_results_and_performance.ipynb`**: 
   - Carga los resultados del entrenamiento
   - Calcula scores y métricas de performance
   - Genera visualizaciones y análisis SHAP

> **📖 Para instrucciones detalladas de replicación, consulta [REPLICATION.md](REPLICATION.md)**

**Datos necesarios para ejecutar los notebooks**:
- `data/Loan_status_2007-2020Q3.csv` (o `.csv.gz`)
- `data/accepted_2007_to_2018Q4.csv` (o `.csv.gz`)

> **Nota**: Estos archivos son grandes y no están incluidos en el repositorio. Debes descargarlos desde Kaggle o la fuente original.

## 📦 Dependencias

Las dependencias principales incluyen:

- **Data Science**: numpy, pandas, scipy
- **Machine Learning**: scikit-learn, xgboost, lightgbm, catboost
- **Explicabilidad**: shap
- **Visualización**: matplotlib, seaborn
- **Jupyter**: jupyter, ipykernel, notebook

Ver `requirements.txt` para la lista completa con versiones específicas.

## 🔄 Actualizar Dependencias

Si necesitas agregar nuevas dependencias:

1. Agrega el paquete a `requirements.txt`
2. Instálalo en el ambiente activo:
   ```bash
   conda activate lending_club
   pip install <nuevo_paquete>
   ```

## 📝 Estructura del Proyecto

```
.
├── data/              # Archivos de datos (no incluidos en repo, ver REPLICATION.md)
├── notebooks/         # Notebooks de Jupyter
│   ├── 00_process_complete_until_training.ipynb  # Procesamiento y entrenamiento
│   └── 01_results_and_performance.ipynb          # Análisis de resultados
├── config/            # Archivos de configuración (generados por notebooks)
├── results/           # Resultados de experimentos (generados por notebooks)
├── plots/             # Visualizaciones (generadas por notebooks)
├── requirements.txt   # Dependencias de Python
├── environment.yml    # Configuración del ambiente conda
├── setup.sh          # Script de configuración automática
├── README.md         # Este archivo
└── REPLICATION.md    # Guía detallada de replicación
```

## 🛠️ Solución de Problemas

### El script no encuentra conda después de instalarlo

Cierra y vuelve a abrir tu terminal, luego ejecuta `setup.sh` nuevamente.

### Error al activar el ambiente

Verifica que conda esté correctamente inicializado:
```bash
conda init
```

### El kernel de Jupyter no aparece

Reinstala el kernel:
```bash
conda activate lending_club
python -m ipykernel install --user --name lending_club --display-name "Python (lending_club)"
```
