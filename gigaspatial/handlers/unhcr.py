# handlers/unhcr.py

from pathlib import Path
import geopandas as gpd
from gigaspatial.core.utils import download_url, read_dataset  # adjust if needed

def get_unhcr_camps_data(cfg):
    """
    Download and read UNHCR refugee/IDP camp geospatial data.

    Args:
        cfg (dict): {
            'url': GeoJSON/FeatureServer endpoint,
            'cache_path': path to save file
        }

    Returns:
        GeoDataFrame with normalized camp data
    """
    url = cfg.get("url")
    cache_path = Path(cfg.get("cache_path", "data/unhcr/camps.geojson"))

    # Download if not cached
    if not cache_path.exists():
        print(f"[UNHCR] Downloading data from {url}")
        download_url(url, cache_path)
    else:
        print(f"[UNHCR] Using cached data: {cache_path}")

    # Read GeoJSON
    gdf = read_dataset(cache_path)

    # Rename key columns for consistency
    gdf = gdf.rename(columns={
        "name": "camp_name",
        "Country": "country_name",
        "Latitude": "lat",
        "Longitude": "lon"
    })

    # Sanity check for geometry
    if not gdf.geometry.geom_type.isin(["Point"]).all():
        print("[UNHCR] Warning: Non-point geometries present in camp data")

    return gdf


# Optional CLI test block
if __name__ == "__main__":
    config = {
        "url": "https://gis.unhcr.org/arcgis/rest/services/core_v2/wrl_prp_p_unhcr_PoC/FeatureServer/0/query?where=1%3D1&outFields=*&f=geojson",
        "cache_path": "data/unhcr/camps.geojson"
    }
    

    df = get_unhcr_camps_data(config)