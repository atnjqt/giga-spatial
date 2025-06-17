# HDX Data Download Quickstart

This guide explains how to use the GigaSpatial HDX handler to download and process data from the Humanitarian Data Exchange (HDX).

## Prerequisites
- Python 3.8+
- Install dependencies:
  ```bash
  pip install -r requirements.txt
  ```
- HDX API credentials (if required for private datasets)

## 1. Configure HDX Access
The handler uses the `hdx-python-api` library. By default, it connects to the public HDX site. You can set your user agent and site in the config:

Example dataset: [IDMC Uganda Dataset](https://data.humdata.org/dataset/idmc-event-data-for-uga)

```python
from gigaspatial.handlers.hdx import HDXConfig
from gigaspatial.core.io.data_store import DataStore

# Always create a DataStore instance first
data_store = DataStore()

# Then pass it to the config
config = HDXConfig(
    dataset_name="idmc-event-data-for-uga",
    data_store=data_store  # Important: pass data_store here!
)
```

## 2. Download Data
Use the `HDXDownloader` to download resources for a country or filter:

```python
from gigaspatial.handlers.hdx import HDXDownloader

# Create downloader using the SAME data_store instance
downloader = HDXDownloader(config=config, data_store=data_store)

# Download all resources for a country (e.g., Uganda)
paths = downloader.download("UGA")
print(f"Downloaded files: {paths}")
```

### Alternative: Use the integrated HDXHandler

For simplicity, you can use the HDXHandler class which sets up all components properly (recommended approach):

```python
from gigaspatial.core.io.data_store import DataStore
from gigaspatial.handlers.hdx import HDXHandler

# Create a data store
data_store = DataStore()

# Create a handler (automatically sets up config, downloader and reader)
handler = HDXHandler(
    dataset_name="idmc-event-data-for-uga",
    data_store=data_store
)

# Download using the handler's downloader
paths = handler.downloader.download("UGA")
print(f"Downloaded files: {paths}")

# If no files were downloaded, it might be a path issue
if not paths:
    print("Check that the output directory exists and has write permissions")
    print(f"Output directory: {handler.config.output_dir_path}")
```

You can also filter by resource metadata:

```python
# Download only CSV resources
paths = downloader.download({"format": "csv"})
```

## 3. Read Data
Use the `HDXReader` to load downloaded files as pandas or geopandas DataFrames:

```python
from gigaspatial.handlers.hdx import HDXReader

# Use the same data_store throughout
reader = HDXReader(config=config, data_store=data_store)

# Read all resources at once
data = reader.load_all_resources()
print(f"Loaded data: {data}")

# If using the handler:
data = handler.reader.load_all_resources()
```

## 4. Advanced Usage
- See `gigaspatial/handlers/hdx.py` for more options (e.g., filtering, custom output paths).
- Use the `HDXConfig` class to customize download location, user agent, or HDX site.

## Troubleshooting

### Missing DataStore Error
If you see an error like:
```
ERROR: DataStore.write_file() missing 1 required positional argument: 'data'
```

This usually means one of the following:

1. The DataStore wasn't properly passed to one of the components
2. The same DataStore instance wasn't used consistently
3. The resource object structure is unexpected
4. The output directory doesn't exist or has permission issues

**Solution:** 

```python
# The recommended way:
from gigaspatial.core.io.data_store import DataStore
from gigaspatial.handlers.hdx import HDXHandler

data_store = DataStore()
handler = HDXHandler(
    dataset_name="idmc-event-data-for-uga",
    data_store=data_store
)

# Check if output directory exists and create if necessary
output_dir = str(handler.config.output_dir_path)
if not data_store.is_dir(output_dir):
    data_store.make_dirs(output_dir)

# Now download
paths = handler.downloader.download("UGA")
```

**If you're using the components separately:**
- Create the DataStore first
- Pass it to HDXConfig using `data_store=data_store`
- Pass the same instance to all other components
- Ensure the output directory exists (create if necessary)

### Dataset Not Found
If your dataset doesn't exist or you have the wrong name:
```
ValueError: Dataset 'wrong-dataset-name' not found on HDX
```

**Solution:**
1. Go to [data.humdata.org](https://data.humdata.org/)
2. Search for your dataset 
3. Use the correct ID from the URL (e.g., "idmc-event-data-for-uga")

### Authentication Issues
For private datasets, you need proper authentication:
```python
from hdx.hdx_configuration import Configuration

Configuration.create(
    hdx_site="prod",
    user_agent="MyOrganization",  # Replace with your org name
    hdx_key="YOUR-API-KEY"  # Get from HDX
)
```

---
For more details, see the code in `gigaspatial/handlers/hdx.py` or the [HDX Python API documentation](https://github.com/OCHA-DAP/hdx-python-api).
