#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Base URL
BASE_URL="http://localhost:8765"

echo -e "${YELLOW}Testing if products were successfully added to the store...${NC}"

# Function to check if the server is running
check_server() {
    echo "Checking if the server is running..."
    if ! curl -s "$BASE_URL" > /dev/null; then
        echo -e "${RED}Error: Cannot connect to $BASE_URL${NC}"
        echo "Please make sure the server is running and try again."
        exit 1
    fi
    echo -e "${GREEN}Server is running.${NC}\n"
}

# Function to test if a product exists
test_product() {
    local id=$1
    local expected_title=$2
    
    echo -e "Testing product ID $id (expected: $expected_title)..."
    
    response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/products/$id")
    
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 200 ]; then
        # Extract the title from the JSON response
        title=$(echo "$response_body" | grep -o '"title":"[^"]*"' | cut -d'"' -f4)
        
        if [[ "$title" == "$expected_title" ]]; then
            echo -e "${GREEN}✓ Product $id exists with correct title: $title${NC}"
            return 0
        else
            echo -e "${RED}✗ Product $id exists but has wrong title: $title (expected: $expected_title)${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Failed to retrieve product $id. Status code: $status_code${NC}"
        echo "Response: $response_body"
        return 1
    fi
}

# Function to get all products and count them
count_products() {
    echo "Counting total products in the store..."
    
    response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/products")
    
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 200 ]; then
        # Count the number of products by counting the occurrences of "id":
        product_count=$(echo "$response_body" | grep -o '"id"' | wc -l)
        
        echo -e "${GREEN}Total products found: $product_count${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to retrieve products. Status code: $status_code${NC}"
        echo "Response: $response_body"
        return 1
    fi
}

# Main execution
check_server

# Test specific products
test_product 1 "Laptop Pro X"
test_product 2 "Classic Denim Jacket"

# Count total products
count_products

echo -e "\n${YELLOW}Summary:${NC}"
echo -e "If you see green checkmarks above, the products were successfully added to the store."
echo -e "If you see red error messages, there might be issues with the product creation or retrieval."