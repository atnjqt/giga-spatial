# HDX Data Access with GigaSpatial

This guide shows how to configure, download, and read data from the Humanitarian Data Exchange (HDX) using the GigaSpatial library.

## Prerequisites

- Install the required packages:
  ```bash
  pip install gigaspatial hdx-python-api geopandas pandas
  ```
- (Optional) Set up your HDX API key if you need access to private datasets. For most public datasets, no key is required.

## Configuration

You can configure HDX access by creating an `HDXConfig` object. At minimum, specify the dataset name you want to download:

```python
from gigaspatial.handlers.hdx import HDXConfig, HDXDownloader, HDXReader

# Example: Download the "cod-ab-eth" dataset (Ethiopia admin boundaries)
config = HDXConfig(dataset_name="cod-ab-eth")
```

## Downloading Data

Use the `HDXDownloader` to download all resources for a dataset:

```python
downloader = HDXDownloader(config)
downloaded_files = downloader.download_dataset()
print("Downloaded files:", downloaded_files)
```

## Reading Data

Use the `HDXReader` to list and read resources from the downloaded dataset:

```python
reader = HDXReader(dataset_name="cod-ab-eth")

# List all files in the dataset
print(reader.list_resources())

# Read a specific resource (e.g., a shapefile or CSV)
gdf = reader.read_resource("cod-ab-eth-adm1.shp")  # for shapefile
print(gdf.head())
```

## Notes
- The first time you use the downloader, it will save data to the default path (see your config's `base_path`).
- You can filter resources by type or name using the `resource_filter` option in `HDXConfig`.
- For more details, see the [HDX Python API documentation](https://github.com/OCHA-DAP/hdx-python-api) and the GigaSpatial docs.

---

For more advanced usage, see the `gigaspatial/handlers/hdx.py` source code
