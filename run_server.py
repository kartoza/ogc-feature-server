#!/usr/bin/env python3
"""
Simple script to run pygeoapi server
"""

import os
import sys
import json

if __name__ == '__main__':
    # Set the configuration file path
    config_file = os.path.join(os.path.dirname(__file__), 'pygeoapi-config.yml')
    os.environ['PYGEOAPI_CONFIG'] = config_file
    
    # Generate OpenAPI document automatically
    from pygeoapi.openapi import generate_openapi_document
    import json
    
    openapi_doc = generate_openapi_document(config_file, 'json')
    
    # Set OpenAPI environment variable
    os.environ['PYGEOAPI_OPENAPI'] = json.dumps(openapi_doc)
    
    # Import Flask app after setting environment variables
    from pygeoapi.flask_app import APP
    
    print(f"Starting pygeoapi server with config: {config_file}")
    print("Server will be available at: http://localhost:5000")
    print("Features collection: http://localhost:5000/collections/sample-features")
    print("Features items: http://localhost:5000/collections/sample-features/items")
    
    # Run the Flask app
    APP.run(host='0.0.0.0', port=5000, debug=True)