# Downloading UNHCR Data

This example demonstrates how to fetch and process UNHCR refugee/IDP camp geospatial data using the `UNHCRHandler` class.

## Prerequisites

Ensure you have installed the `gigaspatial` package and set up the necessary configuration. Follow the [Installation Guide](../getting-started/installation.md) if you haven't already.

## Example Code

```python
from gigaspatial.handlers.unhcr import UNHCRConfig, UNHCRHandler

# Create configuration
config = {
    "url": "https://gis.unhcr.org/arcgis/rest/services/core_v2/wrl_prp_p_unhcr_PoC/FeatureServer/0/query?where=1%3D1&outFields=*&f=geojson",
    "cache_path": "data/unhcr/camps.geojson"
}

# Initialize the handler
handler = UNHCRHandler(config)

# Fetch UNHCR refugee/IDP camp data
camps_gdf = handler.get_camps_data()
print(camps_gdf.head())

# Alternatively, use the utility function directly
from gigaspatial.handlers.unhcr import get_unhcr_camps_data
camps_gdf = get_unhcr_camps_data(config)
```

## Explanation

- **UNHCRHandler**: This class provides functionality to fetch and process UNHCR refugee and IDP camp geospatial data.
- **get_camps_data**: This method downloads and processes UNHCR camp data, returning a normalized GeoDataFrame.
- The handler handles caching to prevent repeated downloads and normalizes column names for consistency.

## Processing Examples

Once you have the camp data, you can perform various geospatial operations:

```python
import geopandas as gpd
from gigaspatial.handlers import AdminBoundaries
from gigaspatial.processing.tif_processor import TifProcessor

# Example 1: Work with administrative boundaries
admin_boundaries = AdminBoundaries.create(country_code="KEN", admin_level=1)
admin_gdf = admin_boundaries.to_geodataframe()

# Example 2: Convert camp points to raster
import rasterio
from rasterio import features
from rasterio.transform import from_origin
import numpy as np

# Get bounding box and create transform
bounds = camps_gdf.total_bounds
minx, miny, maxx, maxy = bounds
resolution = 0.01
width = int((maxx - minx) / resolution)
height = int((maxy - miny) / resolution)
transform = from_origin(minx, maxy, resolution, resolution)

# Create raster
output_tif = 'data/unhcr/camps_raster.tif'
raster = np.zeros((height, width), dtype=np.uint8)
with rasterio.open(
    output_tif, 'w', driver='GTiff',
    height=height, width=width, count=1,
    dtype=raster.dtype, crs=camps_gdf.crs,
    transform=transform,
) as dst:
    shapes = ((geom, 1) for geom in camps_gdf.geometry)
    rasterized = features.rasterize(shapes, out=raster, transform=transform)
    dst.write(rasterized, indexes=1)

# Example 3: Process the rasterized data
processor = TifProcessor("./data/unhcr/camps_raster.tif")
processed_data = processor.to_dataframe()
```

## Next Steps

After working with the UNHCR data, you can integrate it with other datasets like:

- [Climate data processing](../processing/climate.md)
- [Vector data analysis](../processing/vector.md)
- [Administrative boundaries](../downloading/hdx.md)

---

[Back to Examples](../index.md)
