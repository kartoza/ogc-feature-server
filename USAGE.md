# OGC Features API Server with pygeoapi

A minimal example of exposing GeoJSON files as an OGC Features API service using pygeoapi.

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

1. Start the server:
```bash
python run_server.py
```

2. Access the API:
- Landing page: http://localhost:5000
- Collections: http://localhost:5000/collections
- Sample features collection: http://localhost:5000/collections/sample-features
- Sample features items: http://localhost:5000/collections/sample-features/items
- Individual feature: http://localhost:5000/collections/sample-features/items/1

## Adding Your Own GeoJSON

1. Place your GeoJSON file in the `data/` directory
2. Update `pygeoapi-config.yml`:
   - Add a new resource under `resources:`
   - Set the `data` path to your GeoJSON file
   - Set the `id_field` to match your feature ID property

## API Endpoints

The server provides OGC API - Features compliant endpoints:
- GET `/` - Landing page
- GET `/conformance` - API conformance
- GET `/collections` - Collections metadata
- GET `/collections/{collection}` - Collection metadata
- GET `/collections/{collection}/items` - Features in collection
- GET `/collections/{collection}/items/{item}` - Individual feature

Query parameters supported:
- `limit` - Number of items to return
- `bbox` - Bounding box filter
- `datetime` - Temporal filter