#!/bin/bash

set -e

echo "========================================="
echo "Building Restore DB Lambda Package"
echo "========================================="

# Clean previous build
rm -rf package
rm -f function.zip

mkdir package

# Install dependencies (if requirements.txt has any)
if [ -s requirements.txt ]; then
    pip3 install -r requirements.txt -t package
fi

# Copy source files
cp lambda_function.py package/
cp config.py package/

# Create deployment package
cd package
zip -r ../function.zip .
cd ..

echo ""
echo "Build completed successfully."
echo "Package created: function.zip"

ls -lh function.zip