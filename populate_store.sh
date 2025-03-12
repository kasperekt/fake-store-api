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

product3='{
    "id": 3,
    "title": "Wireless Headphones",
    "price": 149.99,
    "description": "Noise-cancelling wireless headphones with 20-hour battery life",
    "image": "https://example.com/headphones.jpg",
    "category": "electronics"
}'

product4='{
    "id": 4,
    "title": "Stainless Steel Water Bottle",
    "price": 24.99,
    "description": "Eco-friendly insulated water bottle that keeps drinks cold for 24 hours",
    "image": "https://example.com/bottle.jpg",
    "category": "lifestyle"
}'

product5='{
    "id": 5,
    "title": "Organic Cotton T-Shirt",
    "price": 29.99,
    "description": "Comfortable, sustainable t-shirt made from 100% organic cotton",
    "image": "https://example.com/tshirt.jpg",
    "category": "clothing"
}'

product6='{
    "id": 6,
    "title": "Smart Watch Series 5",
    "price": 299.99,
    "description": "Advanced smartwatch with health monitoring and GPS",
    "image": "https://example.com/smartwatch.jpg",
    "category": "electronics"
}'

product7='{
    "id": 7,
    "title": "Yoga Mat Premium",
    "price": 45.99,
    "description": "Non-slip, eco-friendly yoga mat with carrying strap",
    "image": "https://example.com/yogamat.jpg",
    "category": "fitness"
}'

product8='{
    "id": 8,
    "title": "Ceramic Coffee Mug Set",
    "price": 34.99,
    "description": "Set of 4 handcrafted ceramic coffee mugs",
    "image": "https://example.com/mugs.jpg",
    "category": "home"
}'

product9='{
    "id": 9,
    "title": "Leather Wallet",
    "price": 59.99,
    "description": "Genuine leather wallet with RFID protection",
    "image": "https://example.com/wallet.jpg",
    "category": "accessories"
}'

product10='{
    "id": 10,
    "title": "Portable Bluetooth Speaker",
    "price": 79.99,
    "description": "Waterproof portable speaker with 360° sound",
    "image": "https://example.com/speaker.jpg",
    "category": "electronics"
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

user3='{
    "id": 3,
    "email": "michael.johnson@example.com",
    "username": "mikejohnson",
    "password": "securepass789",
    "name": {
        "firstname": "Michael",
        "lastname": "Johnson"
    },
    "address": {
        "city": "Chicago",
        "street": "789 Pine St",
        "number": 12,
        "zipcode": "60601",
        "geolocation": {
            "lat": "41.8781",
            "long": "-87.6298"
        }
    },
    "phone": "1-555-555-0789"
}'

user4='{
    "id": 4,
    "email": "emily.brown@example.com",
    "username": "emilybrown",
    "password": "securepass101",
    "name": {
        "firstname": "Emily",
        "lastname": "Brown"
    },
    "address": {
        "city": "Houston",
        "street": "101 Maple Ave",
        "number": 34,
        "zipcode": "77001",
        "geolocation": {
            "lat": "29.7604",
            "long": "-95.3698"
        }
    },
    "phone": "1-555-555-0101"
}'

user5='{
    "id": 5,
    "email": "david.wilson@example.com",
    "username": "davidwilson",
    "password": "securepass202",
    "name": {
        "firstname": "David",
        "lastname": "Wilson"
    },
    "address": {
        "city": "Phoenix",
        "street": "202 Cedar Rd",
        "number": 56,
        "zipcode": "85001",
        "geolocation": {
            "lat": "33.4484",
            "long": "-112.0740"
        }
    },
    "phone": "1-555-555-0202"
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

cart3='{
    "id": 3,
    "userId": 3,
    "date": "2024-03-12T12:00:00.000Z",
    "products": [
        {
            "productId": 3,
            "quantity": 1
        },
        {
            "productId": 5,
            "quantity": 2
        },
        {
            "productId": 7,
            "quantity": 1
        }
    ]
}'

cart4='{
    "id": 4,
    "userId": 4,
    "date": "2024-03-12T13:00:00.000Z",
    "products": [
        {
            "productId": 6,
            "quantity": 1
        },
        {
            "productId": 8,
            "quantity": 4
        }
    ]
}'

cart5='{
    "id": 5,
    "userId": 5,
    "date": "2024-03-12T14:00:00.000Z",
    "products": [
        {
            "productId": 9,
            "quantity": 1
        },
        {
            "productId": 10,
            "quantity": 2
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
make_request "/products" "$product3" "Product 3 (Wireless Headphones)"
make_request "/products" "$product4" "Product 4 (Stainless Steel Water Bottle)"
make_request "/products" "$product5" "Product 5 (Organic Cotton T-Shirt)"
make_request "/products" "$product6" "Product 6 (Smart Watch Series 5)"
make_request "/products" "$product7" "Product 7 (Yoga Mat Premium)"
make_request "/products" "$product8" "Product 8 (Ceramic Coffee Mug Set)"
make_request "/products" "$product9" "Product 9 (Leather Wallet)"
make_request "/products" "$product10" "Product 10 (Portable Bluetooth Speaker)"

# Create users
make_request "/users" "$user1" "User 1 (John Doe)"
make_request "/users" "$user2" "User 2 (Jane Smith)"
make_request "/users" "$user3" "User 3 (Michael Johnson)"
make_request "/users" "$user4" "User 4 (Emily Brown)"
make_request "/users" "$user5" "User 5 (David Wilson)"

# Create carts
make_request "/carts" "$cart1" "Cart 1 for User 1"
make_request "/carts" "$cart2" "Cart 2 for User 2"
make_request "/carts" "$cart3" "Cart 3 for User 3"
make_request "/carts" "$cart4" "Cart 4 for User 4"
make_request "/carts" "$cart5" "Cart 5 for User 5"

echo -e "\n${GREEN}Database population completed!${NC}"