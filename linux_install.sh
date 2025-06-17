#!/bin/bash
# Linux installation script for giga-spatial dependencies
# This will install system dependencies needed for the Python packages

# Exit on error
set -e

echo "🔧 Starting Linux dependency installation for giga-spatial..."

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

# Check if we're running as root, if not use sudo
SUDO=""
if [ "$(id -u)" != "0" ]; then
    SUDO="sudo"
    echo "⚠️  Not running as root, using sudo for system installations"
fi

# 1. Install system dependencies based on detected distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "📦 Detected Linux distribution: $NAME"
    
    if [[ "$ID" == "ubuntu" ]] || [[ "$ID_LIKE" == *"debian"* ]]; then
        echo "📦 Installing dependencies for Ubuntu/Debian..."
        $SUDO apt-get update
        $SUDO apt-get install -y --no-install-recommends \
            build-essential \
            python3-dev \
            gdal-bin \
            libgdal-dev \
            libspatialindex-dev \
            libproj-dev \
            proj-bin \
            libgeos-dev \
            libudunits2-dev \
            libhdf5-dev \
            libnetcdf-dev
            
    elif [[ "$ID" == "centos" ]] || [[ "$ID" == "rhel" ]] || [[ "$ID" == "fedora" ]]; then
        echo "📦 Installing dependencies for CentOS/RHEL/Fedora..."
        $SUDO dnf install -y \
            gcc \
            gcc-c++ \
            make \
            python3-devel \
            gdal \
            gdal-devel \
            geos \
            geos-devel \
            proj \
            proj-devel \
            hdf5 \
            hdf5-devel \
            netcdf \
            netcdf-devel \
            spatialindex \
            spatialindex-devel
            
    elif [[ "$ID" == "arch" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
        echo "📦 Installing dependencies for Arch Linux..."
        $SUDO pacman -Sy --noconfirm \
            base-devel \
            python \
            gdal \
            geos \
            proj \
            hdf5 \
            netcdf \
            spatialindex
            
    else
        echo "⚠️ Unsupported distribution: $NAME. You may need to manually install GDAL and other dependencies."
    fi
else
    echo "⚠️ Could not detect Linux distribution. You may need to manually install GDAL and other dependencies."
fi

# 2. Set up required environment variables for GDAL
GDAL_VERSION=$(gdal-config --version)
if [ $? -ne 0 ]; then
    echo "❌ GDAL installation not found or not in PATH. Please check your installation."
    exit 1
fi

echo "✅ Found GDAL version: $GDAL_VERSION"
export GDAL_VERSION
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal

# 3. Install core dependencies in the correct order to avoid incompatibilities
echo "🐍 Installing core dependencies in the right order..."

# Create a temporary requirements file with adjusted dependencies
cat > temp_requirements.txt <<EOL
numpy>=1.24.0,<2.3.0  # Use a compatible numpy version range
GDAL==$GDAL_VERSION
rasterio>=1.2.0,<1.4.0  # Use a more flexible version range for rasterio
shapely>=2.0.0
geopandas>=1.0.1
EOL

# Install from the temporary requirements file
echo "🐍 Installing core geospatial packages..."
python3.10 -m pip install -r temp_requirements.txt

# 4. Install the remaining dependencies from requirements.txt, excluding what we've already installed
grep -v -E "numpy|rasterio|GDAL|shapely|geopandas" requirements.txt > remaining_requirements.txt
echo "🐍 Installing remaining dependencies..."
python3.10 -m pip install -r remaining_requirements.txt

# 5. Now install giga-spatial with an explicit dependency override
echo "🐍 Installing giga-spatial..."
PIP_NO_BUILD_ISOLATION=0 python3.10 -m pip install -e .

# Cleanup temporary files
rm temp_requirements.txt remaining_requirements.txt

echo "✅ Installation completed successfully!"
echo "🚀 You can now use giga-spatial on Linux"
