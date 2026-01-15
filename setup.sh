#!/bin/bash

# Script de configuración para crear ambiente conda
# Este script ayuda a configurar el ambiente de desarrollo para el proyecto

set -e  # Salir si hay algún error

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Configuración del Ambiente Conda ===${NC}\n"

# Función para verificar si conda está instalado
check_conda() {
    if command -v conda &> /dev/null; then
        echo -e "${GREEN}✓ Conda está instalado${NC}"
        conda --version
        return 0
    else
        return 1
    fi
}

# Verificar si conda está instalado
if ! check_conda; then
    echo -e "${YELLOW}⚠ Conda no está instalado en el sistema${NC}"
    read -p "¿Deseas descargar e instalar Miniconda? (s/n): " install_conda
    
    if [[ $install_conda == "s" || $install_conda == "S" ]]; then
        echo -e "${GREEN}Descargando Miniconda...${NC}"
        
        # Detectar el sistema operativo
        OS="$(uname -s)"
        ARCH="$(uname -m)"
        
        if [[ "$OS" == "Darwin" ]]; then
            if [[ "$ARCH" == "arm64" ]]; then
                CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
            else
                CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
            fi
        elif [[ "$OS" == "Linux" ]]; then
            CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
        else
            echo -e "${RED}Error: Sistema operativo no soportado automáticamente${NC}"
            echo "Por favor instala Miniconda manualmente desde: https://docs.conda.io/en/latest/miniconda.html"
            exit 1
        fi
        
        # Descargar e instalar
        INSTALLER="miniconda_installer.sh"
        curl -O "$CONDA_URL" -o "$INSTALLER"
        bash "$INSTALLER" -b -p "$HOME/miniconda3"
        rm "$INSTALLER"
        
        # Inicializar conda para el shell actual
        eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
        conda init
        
        echo -e "${GREEN}✓ Miniconda instalado exitosamente${NC}"
        echo -e "${YELLOW}⚠ Por favor, cierra y vuelve a abrir tu terminal, luego ejecuta este script nuevamente${NC}"
        exit 0
    else
        echo -e "${RED}No se puede continuar sin conda. Instálalo manualmente desde: https://docs.conda.io/en/latest/miniconda.html${NC}"
        exit 1
    fi
fi

# Función para encontrar la base de conda
find_conda_base() {
    # Intentar usar conda info si está disponible
    if command -v conda &> /dev/null; then
        CONDA_BASE=$(conda info --base 2>/dev/null)
        if [ -n "$CONDA_BASE" ] && [ -d "$CONDA_BASE" ]; then
            echo "$CONDA_BASE"
            return 0
        fi
    fi
    
    # Buscar en ubicaciones comunes
    for conda_path in "$HOME/miniconda3" "$HOME/anaconda3" "$HOME/opt/anaconda3" "$HOME/opt/miniconda3" "/opt/anaconda3" "/opt/miniconda3"; do
        if [ -d "$conda_path" ] && [ -f "$conda_path/etc/profile.d/conda.sh" ]; then
            echo "$conda_path"
            return 0
        fi
    done
    
    return 1
}

# Función para inicializar conda en el shell actual
init_conda() {
    # Si conda ya está disponible y funciona, no hacer nada
    if command -v conda &> /dev/null; then
        if conda info --envs &> /dev/null 2>&1; then
            return 0
        fi
    fi
    
    # Encontrar la base de conda
    CONDA_BASE=$(find_conda_base)
    if [ -n "$CONDA_BASE" ] && [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]; then
        source "$CONDA_BASE/etc/profile.d/conda.sh"
        return 0
    fi
    
    echo -e "${YELLOW}⚠ No se pudo inicializar conda automáticamente${NC}"
    return 1
}

# Función para activar un ambiente conda de manera robusta
activate_conda_env() {
    local env_name=$1
    
    # Intentar inicializar conda primero
    init_conda
    
    # Método 1: Intentar con conda activate (si conda está inicializado)
    if command -v conda &> /dev/null && conda info --envs &> /dev/null 2>&1; then
        if conda activate "$env_name" 2>/dev/null; then
            return 0
        fi
    fi
    
    # Método 2: Usar source activate (método legacy pero más compatible)
    CONDA_BASE=$(find_conda_base)
    if [ -n "$CONDA_BASE" ]; then
        # Activar usando el script de activación directo
        if [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]; then
            source "$CONDA_BASE/etc/profile.d/conda.sh"
            conda activate "$env_name" 2>/dev/null && return 0
        fi
        
        # Método 3: Activar directamente usando la ruta del ambiente
        local env_path="$CONDA_BASE/envs/$env_name"
        if [ -d "$env_path" ]; then
            export CONDA_DEFAULT_ENV="$env_name"
            export CONDA_PREFIX="$env_path"
            export PATH="$env_path/bin:$PATH"
            return 0
        fi
    fi
    
    echo -e "${RED}Error: No se pudo activar el ambiente '$env_name'${NC}"
    return 1
}

# Inicializar conda
init_conda

# Función para descomprimir archivos .csv.gz si es necesario
decompress_data() {
    echo -e "\n${GREEN}Verificando archivos de datos...${NC}"
    
    # Crear carpeta data si no existe
    if [ ! -d "data" ]; then
        echo -e "${YELLOW}Creando carpeta data/...${NC}"
        mkdir -p data
    fi
    
    # Archivos a verificar y descomprimir
    declare -a files=("rejected_2007_to_2018Q4.csv.gz" "accepted_2007_to_2018Q4.csv.gz")
    
    for file in "${files[@]}"; do
        gz_path="data/${file}"
        csv_path="data/${file%.gz}"  # Remueve .gz del nombre
        
        if [ -f "$gz_path" ]; then
            # Si el archivo .csv ya existe, no descomprimir
            if [ -f "$csv_path" ]; then
                echo -e "${GREEN}✓ ${csv_path} ya existe, omitiendo descompresión${NC}"
            else
                echo -e "${YELLOW}Descomprimiendo ${file}...${NC}"
                if command -v gunzip &> /dev/null; then
                    gunzip -k "$gz_path"  # -k mantiene el archivo original
                    echo -e "${GREEN}✓ ${file} descomprimido exitosamente${NC}"
                else
                    echo -e "${RED}Error: gunzip no está disponible. Por favor descomprime ${file} manualmente${NC}"
                fi
            fi
        else
            echo -e "${YELLOW}⚠ ${gz_path} no encontrado. Asegúrate de descargarlo y colocarlo en data/${NC}"
        fi
    done
}

# Solicitar nombre del ambiente
echo ""
read -p "Ingresa el nombre del ambiente conda (presiona Enter para usar 'lending_club'): " env_name
env_name=${env_name:-lending_club}

echo -e "\n${GREEN}Creando ambiente conda: ${env_name}${NC}"

# Verificar si el ambiente ya existe
if conda env list | grep -q "^${env_name} "; then
    echo -e "${YELLOW}⚠ El ambiente '${env_name}' ya existe${NC}"
    read -p "¿Deseas eliminarlo y recrearlo? (s/n): " recreate_env
    
    if [[ $recreate_env == "s" || $recreate_env == "S" ]]; then
        echo -e "${YELLOW}Eliminando ambiente existente...${NC}"
        conda env remove -n "$env_name" -y
    else
        echo -e "${GREEN}Usando ambiente existente${NC}"
        # Activar el ambiente de manera robusta
        if activate_conda_env "$env_name"; then
            echo -e "${GREEN}✓ Ambiente activado${NC}"
        else
            echo -e "${RED}Error: No se pudo activar el ambiente. Por favor ejecuta manualmente:${NC}"
            echo -e "  conda activate ${env_name}"
            exit 1
        fi
        
        # Preguntar si quiere descomprimir los archivos
        echo ""
        read -p "¿Deseas descomprimir los archivos .csv.gz en data/? (s/n): " decompress_choice
        
        if [[ $decompress_choice == "s" || $decompress_choice == "S" ]]; then
            decompress_data
        else
            echo -e "${YELLOW}Omitiendo descompresión de archivos${NC}"
        fi
        
        echo -e "\n${YELLOW}Para activar el ambiente en el futuro, ejecuta:${NC}"
        echo -e "  conda activate ${env_name}"
        echo -e "\n${YELLOW}Para iniciar Jupyter Notebook, ejecuta:${NC}"
        echo -e "  jupyter notebook"
        
        exit 0
    fi
fi

# Crear ambiente desde environment.yml
if [ -f "environment.yml" ]; then
    # Reemplazar el nombre en environment.yml temporalmente
    sed "s/name: .*/name: ${env_name}/" environment.yml > environment_temp.yml
    conda env create -f environment_temp.yml
    rm environment_temp.yml
else
    # Crear ambiente básico si no existe environment.yml
    conda create -n "$env_name" python=3.10.13 -y
    conda activate "$env_name"
    
    # Instalar requirements si existe
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
    fi
fi

# Activar el ambiente de manera robusta
if ! activate_conda_env "$env_name"; then
    echo -e "${RED}Error: No se pudo activar el ambiente después de crearlo${NC}"
    exit 1
fi

# Instalar ipykernel para usar con Jupyter
echo -e "\n${GREEN}Configurando kernel de Jupyter...${NC}"
python -m ipykernel install --user --name "$env_name" --display-name "Python ($env_name)"

# Descomprimir archivos de datos
decompress_data

echo -e "\n${GREEN}✓ Ambiente '${env_name}' creado y activado exitosamente${NC}"
echo -e "${GREEN}✓ Dependencias instaladas${NC}"
echo -e "\n${YELLOW}Para activar el ambiente en el futuro, ejecuta:${NC}"
echo -e "  conda activate ${env_name}"
echo -e "\n${YELLOW}Para iniciar Jupyter Notebook, ejecuta:${NC}"
echo -e "  jupyter notebook"

