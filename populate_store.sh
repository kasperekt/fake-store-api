#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Base URL
BASE_URL="http://localhost:8765"

echo "Starting to populate the fake store database..."

# Function to make POST requests
make_request() {
    local endpoint=$1
    local data=$2
    local entity=$3
    
    echo "Creating $entity..."
    response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL$endpoint" \
        -H "Content-Type: application/json" \
        -d "$data")
    
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 201 ]; then
        echo -e "${GREEN}✓ Successfully created $entity${NC}"
    else
        echo -e "${RED}✗ Failed to create $entity. Status code: $status_code${NC}"
        echo "Response: $response_body"
    fi
    
    # Add a small delay between requests
    sleep 1
}

# Create Products
product1='{
    "id": 1,
    "title": "Laptop Pro X",
    "price": 999.99,
    "description": "High-performance laptop with 16GB RAM",
    "image": "https://example.com/laptop.jpg",
    "category": "electronics"
}'

product2='{
    "id": 2,
    "title": "Classic Denim Jacket",
    "price": 89.99,
    "description": "Stylish denim jacket for all seasons",
    "image": "https://example.com/jacket.jpg",
    "category": "clothing"
}'

# Create Users
user1='{
    "id": 1,
    "email": "john.doe@example.com",
    "username": "johndoe",
    "password": "securepass123",
    "name": {
        "firstname": "John",
        "lastname": "Doe"
    },
    "address": {
        "city": "New York",
        "street": "123 Main St",
        "number": 45,
        "zipcode": "10001",
        "geolocation": {
            "lat": "40.7128",
            "long": "-74.0060"
        }
    },
    "phone": "1-555-555-0123"
}'

user2='{
    "id": 2,
    "email": "jane.smith@example.com",
    "username": "janesmith",
    "password": "securepass456",
    "name": {
        "firstname": "Jane",
        "lastname": "Smith"
    },
    "address": {
        "city": "Los Angeles",
        "street": "456 Oak Ave",
        "number": 78,
        "zipcode": "90001",
        "geolocation": {
            "lat": "34.0522",
            "long": "-118.2437"
        }
    },
    "phone": "1-555-555-0456"
}'

# Create Carts
cart1='{
    "id": 1,
    "userId": 1,
    "date": "2024-03-12T10:00:00.000Z",
    "products": [
        {
            "productId": 1,
            "quantity": 1
        },
        {
            "productId": 2,
            "quantity": 2
        }
    ]
}'

cart2='{
    "id": 2,
    "userId": 2,
    "date": "2024-03-12T11:00:00.000Z",
    "products": [
        {
            "productId": 1,
            "quantity": 3
        }
    ]
}'

echo "Checking if the server is running..."
if ! curl -s "$BASE_URL" > /dev/null; then
    echo -e "${RED}Error: Cannot connect to $BASE_URL${NC}"
    echo "Please make sure the server is running and try again."
    exit 1
fi

echo -e "\n${GREEN}Server is running. Starting data population...${NC}\n"

# Create products
make_request "/products" "$product1" "Product 1 (Laptop Pro X)"
make_request "/products" "$product2" "Product 2 (Classic Denim Jacket)"

# Create users
make_request "/users" "$user1" "User 1 (John Doe)"
make_request "/users" "$user2" "User 2 (Jane Smith)"

# Create carts
make_request "/carts" "$cart1" "Cart 1 for User 1"
make_request "/carts" "$cart2" "Cart 2 for User 2"

echo -e "\n${GREEN}Database population completed!${NC}"