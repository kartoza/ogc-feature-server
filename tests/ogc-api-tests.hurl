# OGC Features API Test Suite
# Tests all endpoints and functionality of our pygeoapi server

# Test 1: Landing Page
GET http://localhost:5000
HTTP/1.1 200
[Asserts]
jsonpath "$.title" == "Sample OGC Features API Server"
jsonpath "$.description" == "A simple pygeoapi server exposing GeoJSON data via OGC API - Features"
jsonpath "$.links[?(@.rel == 'conformance')]" exists
jsonpath "$.links[?(@.rel == 'data')]" exists

# Test 2: Conformance Declaration
GET http://localhost:5000/conformance
HTTP/1.1 200
[Asserts]
jsonpath "$.conformsTo" exists
jsonpath "$.conformsTo" contains "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/core"
jsonpath "$.conformsTo" contains "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/geojson"

# Test 3: Collections Endpoint
GET http://localhost:5000/collections
HTTP/1.1 200
[Asserts]
jsonpath "$.collections" exists
jsonpath "$.collections" count == 1
jsonpath "$.collections[0].id" == "sample-features"
jsonpath "$.collections[0].title" == "Sample Features"

# Test 4: Collection Metadata
GET http://localhost:5000/collections/sample-features
HTTP/1.1 200
[Asserts]
jsonpath "$.id" == "sample-features"
jsonpath "$.title" == "Sample Features"
jsonpath "$.description" == "Sample GeoJSON features for testing"
jsonpath "$.keywords[0]" == "sample"
jsonpath "$.itemType" == "feature"

# Test 5: Features Collection (All Items)
GET http://localhost:5000/collections/sample-features/items
HTTP/1.1 200
[Asserts]
jsonpath "$.type" == "FeatureCollection"
jsonpath "$.numberMatched" == 3
jsonpath "$.numberReturned" == 3
jsonpath "$.features" count == 3
jsonpath "$.features[0].id" == 1
jsonpath "$.features[0].properties.name" == "Sample Point 1"

# Test 6: Individual Feature Retrieval
GET http://localhost:5000/collections/sample-features/items/1
HTTP/1.1 200
[Asserts]
jsonpath "$.type" == "Feature"
jsonpath "$.id" == 1
jsonpath "$.properties.name" == "Sample Point 1"
jsonpath "$.properties.description" == "This is the first sample point"
jsonpath "$.geometry.type" == "Point"
jsonpath "$.geometry.coordinates[0]" == -74.006

# Test 7: Limit Parameter
GET http://localhost:5000/collections/sample-features/items?limit=2
HTTP/1.1 200
[Asserts]
jsonpath "$.numberMatched" == 3
jsonpath "$.numberReturned" == 2
jsonpath "$.features" count == 2
jsonpath "$.links[?(@.rel == 'next')]" exists

# Test 8: Bounding Box Filter
GET http://localhost:5000/collections/sample-features/items?bbox=-75,40,-73,42
HTTP/1.1 200
[Asserts]
jsonpath "$.numberMatched" == 2
jsonpath "$.numberReturned" == 2
jsonpath "$.features" count == 2
# Should return features 1 and 3 (NYC area), not feature 2 (Chicago)

# Test 9: OpenAPI Documentation
GET http://localhost:5000/openapi
HTTP/1.1 200
[Asserts]
jsonpath "$.info.title" == "Sample OGC Features API Server"
jsonpath "$.info.version" exists
jsonpath "$.paths['/collections']" exists
jsonpath "$.paths['/collections/sample-features/items']" exists

# Test 10: Non-existent Feature Returns 404
GET http://localhost:5000/collections/sample-features/items/999
HTTP/1.1 404

# Test 11: Non-existent Collection Returns 404
GET http://localhost:5000/collections/nonexistent
HTTP/1.1 404

# Test 12: HTML Format Support
GET http://localhost:5000?f=html
HTTP/1.1 200
[Asserts]
header "Content-Type" contains "text/html"

# Test 13: JSON-LD Format Support
GET http://localhost:5000?f=jsonld
HTTP/1.1 200
[Asserts]
header "Content-Type" contains "application/ld+json"

# Test 14: Features in GeoJSON Format
GET http://localhost:5000/collections/sample-features/items?f=json
HTTP/1.1 200
[Asserts]
jsonpath "$.type" == "FeatureCollection"
header "Content-Type" contains "application/geo+json"

# Test 15: Queryables Endpoint
GET http://localhost:5000/collections/sample-features/queryables
HTTP/1.1 200
[Asserts]
jsonpath "$" exists