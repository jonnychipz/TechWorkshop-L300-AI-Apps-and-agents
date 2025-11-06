#!/bin/bash

# Local Docker Build and Test Script
# This script helps test the Docker build process locally before pushing to GitHub

set -e

echo "🔧 Local Docker Build Test Script"
echo "================================="

# Check if we're in the right directory
if [ ! -f "src/Dockerfile" ]; then
    echo "❌ Error: Please run this script from the repository root directory"
    echo "   The src/Dockerfile should be accessible from here"
    exit 1
fi

# Check if .env file exists in src/
if [ ! -f "src/.env" ]; then
    echo "⚠️  Warning: No .env file found in src/ directory"
    echo "   For local testing, you should create src/.env with your environment variables"
    echo "   You can copy from src/env_sample.txt and fill in your values"
    echo ""
    read -p "Continue without .env file? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted. Please create src/.env first."
        exit 1
    fi
fi

# Set image name and tag
IMAGE_NAME="ai-shopping-assistant"
TAG="local-test"
FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"

echo "📦 Building Docker image: ${FULL_IMAGE_NAME}"
echo "   Context: ./src"
echo "   Dockerfile: ./src/Dockerfile"
echo ""

# Build the Docker image
docker build -t "${FULL_IMAGE_NAME}" ./src

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Docker build completed successfully!"
    echo ""
    echo "🚀 To run the container locally:"
    echo "   docker run -p 8000:8000 ${FULL_IMAGE_NAME}"
    echo ""
    echo "🌐 Access the application at: http://localhost:8000"
    echo ""
    echo "🔍 To inspect the image:"
    echo "   docker run -it --entrypoint /bin/bash ${FULL_IMAGE_NAME}"
    echo ""
    echo "🧹 To clean up the image later:"
    echo "   docker rmi ${FULL_IMAGE_NAME}"
else
    echo ""
    echo "❌ Docker build failed!"
    echo "   Check the error messages above for details"
    exit 1
fi