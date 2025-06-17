# ECMWF Demo

- https://www.ecmwf.int/

## Get storm tracks data from IBTrACS

```python
# Get storm tracks data from IBTrACS
import geopandas as gpd
import requests
from zipfile import ZipFile
from io import BytesIO
from pathlib import Path

def download_and_extract_zip(url: str, extract_to: Path):
    print(f"Downloading {url}")
    r = requests.get(url)
    r.raise_for_status()
    with ZipFile(BytesIO(r.content)) as zip_ref:
        zip_ref.extractall(extract_to)
    print(f"Extracted to {extract_to}")

if __name__ == "__main__":
    # IBTrACS North Atlantic storm tracks shapefile (example)
    ibtracs_url = "https://www.ncei.noaa.gov/data/international-best-track-archive-for-climate-stewardship-ibtracs/v04r01/access/shapefile/IBTrACS.ALL.list.v04r01.points.zip"
    ibtracs_url2 = "https://www.ncei.noaa.gov/data/international-best-track-archive-for-climate-stewardship-ibtracs/v04r01/access/shapefile/IBTrACS.ALL.list.v04r01.lines.zip"
    extract_path = Path("./data/storms/ibtracs")

    download_and_extract_zip(ibtracs_url, extract_path)
    download_and_extract_zip(ibtracs_url2, extract_path)

    # Load shapefile into GeoDataFrame
    shp_path = extract_path / "IBTrACS.ALL.list.v04r01.points.shp"
    #shp_path = extract_path / "IBTrACS.ALL.list.v04r01.lines.shp"
    storms_gdf = gpd.read_file(shp_path)
    print(storms_gdf.head())
```

## Download and process ECMWF forecast data

```python
# Download and process ECMWF forecast data
from ecmwf.opendata import Client
import xarray as xr
import numpy as np

client = Client()

client.retrieve(
    request={
        "time": 0,
        "type": "fc",
        "step": [0, 24, 48],
        "param": ["msl"],
    },
    target="forecast.grib2",
)

ds = xr.load_dataset("forecast.grib2", engine="cfgrib")
msl = ds["msl"]

# Find potential cyclone centers (lowest pressure points)
min_pressures = msl.min(dim=["longitude", "latitude"])
print("Cyclone indicators (low pressures):")
print(min_pressures)
```

## Get climate data with ECMWF Open Data API


```python
# Get climate data with ECMWF Open Data API
import subprocess
from pathlib import Path
import geopandas as gpd
import rasterio
import rioxarray
import xarray as xr
from shapely.geometry import Point
import requests
from ecmwf.opendata import Client

# Output paths
out = Path("data/ecmwf")
out.mkdir(parents=True, exist_ok=True)
grib_path = out / "forecast.grib2"
#tif_path = out / "forecast.tif"
cyclone_tif = out / "cyclone_tracks.grib2"
#cyclone_geojson = out / "cyclone_tracks.geojson"

def fetch_ecmwf_forecast():
    client = Client()
    client.retrieve(
        request={
            "time": 0,
            "type": "fc",
            "step": [0, 24, 48],  # today + 1- and 2-day ahead
            "param": ["msl"],
        },
        target=str(grib_path),
    )
    ds = xr.load_dataset(str(grib_path), engine="cfgrib")
    msl = ds["msl"]
    return ds

climate_data = fetch_ecmwf_forecast()
```