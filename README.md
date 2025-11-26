# OGC Features API Server

A minimal, production-ready implementation of an **OGC Features API** server using [pygeoapi](https://pygeoapi.io/) to expose GeoJSON data. Built with **Nix flakes** for reproducible development and deployment, complete with automated API testing using [Hurl](https://hurl.dev/).

## 🚀 Quick Start

```bash
# Clone and enter directory
git clone <your-repo-url>
cd ogc-feature-server

# Start the server (runs on http://localhost:5000)
nix run .

# In another terminal, run the test suite
nix run .#test
```

That's it! The server exposes your GeoJSON data via a fully compliant OGC Features API.

## 📁 Project Structure

```
ogc-feature-server/
├── data/
│   └── sample.geojson           # Sample GeoJSON data
├── tests/
│   └── ogc-api-tests.hurl       # Hurl-based API test suite
├── flake.nix                    # Nix flake for reproducible environment
├── pygeoapi-config.yml          # pygeoapi server configuration
├── run_server.py                # Python server startup script
├── requirements.txt             # Python dependencies
├── .envrc                       # direnv integration
└── README.md                    # This file
```

## 🛠 Development Setup

### Prerequisites
- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) (optional but recommended)

### Environment Setup
```bash
# Option 1: Using direnv (automatic)
direnv allow

# Option 2: Manual nix development shell
nix develop

# Option 3: Using the legacy method
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Running the Server
```bash
# Method 1: Using nix (recommended)
nix run .

# Method 2: In development shell
python run_server.py

# Method 3: Using pygeoapi CLI
export PYGEOAPI_CONFIG=$(pwd)/pygeoapi-config.yml
pygeoapi serve
```

## 🧪 Testing

### Automated Test Suite
Run the complete API test suite using Hurl:
```bash
nix run .#test
```

The test suite covers:
- ✅ **15 comprehensive tests**
- ✅ Landing page & conformance endpoints
- ✅ Collections and features retrieval
- ✅ Query parameters (`limit`, `bbox`)
- ✅ Multiple output formats (JSON, HTML, JSON-LD)
- ✅ Error handling for non-existent resources
- ✅ OpenAPI documentation endpoint

### Manual Testing
```bash
# Landing page
curl http://localhost:5000

# All features
curl http://localhost:5000/collections/sample-features/items

# Individual feature
curl http://localhost:5000/collections/sample-features/items/1

# With pagination
curl "http://localhost:5000/collections/sample-features/items?limit=2"

# Spatial filtering
curl "http://localhost:5000/collections/sample-features/items?bbox=-75,40,-73,42"

# HTML format
curl "http://localhost:5000?f=html"

# OpenAPI documentation
curl http://localhost:5000/openapi
```

## 📊 API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /` | Landing page with server metadata |
| `GET /conformance` | OGC API conformance declaration |
| `GET /collections` | List all feature collections |
| `GET /collections/{collection}` | Collection metadata |
| `GET /collections/{collection}/items` | Features in collection |
| `GET /collections/{collection}/items/{id}` | Individual feature |
| `GET /openapi` | OpenAPI documentation |

### Query Parameters
- `f=json|html|jsonld` - Output format
- `limit=N` - Number of items to return
- `bbox=minx,miny,maxx,maxy` - Spatial bounding box filter
- `offset=N` - Pagination offset

## 🗂 Adding Your Own Data

### 1. Replace the Sample Data
```bash
# Replace the sample file
cp your-data.geojson data/sample.geojson
```

### 2. Update Configuration
Edit `pygeoapi-config.yml` to add new collections:

```yaml
resources:
  your-collection:
    type: collection
    title: Your Data Collection
    description: Description of your data
    keywords:
      - your-keywords
    providers:
      - type: feature
        name: GeoJSON
        data: data/your-data.geojson
        id_field: your_id_field
```

### 3. Restart the Server
```bash
nix run .
```

## 🏗 Architecture

### Technology Stack
- **[pygeoapi](https://pygeoapi.io/)** - OGC API server implementation
- **[Nix Flakes](https://nixos.wiki/wiki/Flakes)** - Reproducible development environment
- **[Hurl](https://hurl.dev/)** - HTTP API testing
- **[direnv](https://direnv.net/)** - Automatic environment management
- **Python 3.13** with virtual environment for packages not in nixpkgs

### OGC Standards Compliance
This server implements:
- ✅ **OGC API - Features 1.0** (Core)
- ✅ **OGC API - Common 1.0** (Core, JSON, HTML)
- ✅ **GeoJSON** output format
- ✅ **OpenAPI 3.0** documentation
- ✅ **CRS support** (WGS84/CRS84)

### Environment Management
- **Nix flake** provides system dependencies (GDAL, PROJ, GEOS, etc.)
- **Python venv** handles Python packages not available in nixpkgs
- **direnv** automatically activates the environment when entering the directory

## 🚢 Deployment

### Production Deployment
```bash
# Build the package
nix build .

# Run in production mode
./result/bin/ogc-feature-server

# Or using a container
nix run nixpkgs#nixos-generators -- -f docker -c flake.nix
```

### Configuration for Production
1. Update `pygeoapi-config.yml`:
   - Change `server.url` to your production URL
   - Update contact information in `metadata.contact`
   - Configure proper `server.bind` settings

2. Use a production WSGI server:
   ```bash
   gunicorn -w 4 -b 0.0.0.0:5000 pygeoapi.flask_app:APP
   ```

## 🔧 Configuration Reference

### pygeoapi-config.yml
Key configuration sections:
- `server` - Server settings (URL, CORS, etc.)
- `metadata` - Server metadata and contact info
- `resources` - Feature collections configuration

### Python Dependencies
- **pygeoapi** - OGC API server implementation
- **Flask** - Web framework
- **PyYAML** - Configuration parsing
- **Gunicorn** - WSGI server for production

### System Dependencies (via Nix)
- **GDAL** - Geospatial data processing
- **PROJ** - Coordinate reference system transformations
- **GEOS** - Geometric operations
- **SQLite** - Database support

## 🧪 Testing Framework

### Hurl Test Format
Tests are written in [Hurl format](https://hurl.dev/docs/manual.html):
```hurl
# Test description
GET http://localhost:5000/collections
HTTP/1.1 200
[Asserts]
jsonpath "$.collections" count == 1
jsonpath "$.collections[0].id" == "sample-features"
```

### Adding New Tests
1. Edit `tests/ogc-api-tests.hurl`
2. Add new test cases following the existing format
3. Run tests: `nix run .#test`

## 🤝 Contributing

1. **Development**: Use `nix develop` or `direnv allow`
2. **Testing**: All changes must pass `nix run .#test`
3. **Documentation**: Update README.md for new features
4. **Code Style**: Follow existing patterns and conventions

## 📚 References

- [OGC API - Features Specification](https://docs.ogc.org/is/17-069r3/17-069r3.html)
- [pygeoapi Documentation](https://docs.pygeoapi.io/)
- [Hurl Documentation](https://hurl.dev/docs/)
- [Nix Flakes Tutorial](https://nixos.wiki/wiki/Flakes)

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 🏆 Features

- ✅ **Fully OGC Compliant** - Implements OGC API - Features 1.0
- ✅ **Reproducible Environment** - Nix flakes ensure consistent builds
- ✅ **Automated Testing** - 15 comprehensive API tests with Hurl
- ✅ **Multiple Formats** - JSON, GeoJSON, HTML, JSON-LD output
- ✅ **Spatial Filtering** - Bounding box and other OGC filters
- ✅ **Production Ready** - WSGI compatible, configurable for deployment
- ✅ **Developer Friendly** - Hot reload, comprehensive documentation
- ✅ **Modern Stack** - Python 3.13, latest dependencies