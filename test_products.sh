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

# Function to test product removal
test_product_removal() {
    local id=$1
    echo -e "Testing removal of product ID $id..."
    
    # First verify the product exists
    response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/products/$id")
    status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" -ne 200 ]; then
        echo -e "${RED}✗ Cannot test removal - product $id doesn't exist${NC}"
        return 1
    fi
    
    # Try to delete the product
    response=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/products/$id")
    status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" -eq 200 ]; then
        # Verify product is actually gone
        verify_response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/products/$id")
        verify_status=$(echo "$verify_response" | tail -n1)
        
        if [ "$verify_status" -eq 404 ]; then
            echo -e "${GREEN}✓ Product $id was successfully removed${NC}"
            return 0
        else
            echo -e "${RED}✗ Product $id still exists after deletion${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Failed to remove product $id. Status code: $status_code${NC}"
        return 1
    fi
}

# Function to test product update
test_product_update() {
    local id=$1
    local new_title="Updated Product Title"
    local new_price=199.99
    echo -e "Testing update of product ID $id..."
    
    # First verify the product exists
    response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/products/$id")
    status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" -ne 200 ]; then
        echo -e "${RED}✗ Cannot test update - product $id doesn't exist${NC}"
        return 1
    fi
    
    # Try to update the product
    response=$(curl -s -w "\n%{http_code}" -X PUT "$BASE_URL/products/$id" \
        -H "Content-Type: application/json" \
        -d "{
            \"title\": \"$new_title\",
            \"price\": $new_price,
            \"description\": \"Updated test description\",
            \"image\": \"https://example.com/updated-image.jpg\",
            \"category\": \"test\"
        }")
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 200 ]; then
        # Verify the update was successful by checking the returned data
        updated_title=$(echo "$response_body" | grep -o '"title":"[^"]*"' | cut -d'"' -f4)
        if [[ "$updated_title" == "$new_title" ]]; then
            echo -e "${GREEN}✓ Product $id was successfully updated with new title: $updated_title${NC}"
            return 0
        else
            echo -e "${RED}✗ Product update failed - title mismatch: $updated_title (expected: $new_title)${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Failed to update product $id. Status code: $status_code${NC}"
        echo "Response: $response_body"
        return 1
    fi
}

# Main execution
check_server

# First get all products and find an existing one to test with
echo -e "Getting list of products to find one for testing..."
response=$(curl -s -X GET "$BASE_URL/products")
first_product_id=$(echo "$response" | grep -o '"id":[0-9]*' | head -n1 | cut -d':' -f2)
first_product_title=$(echo "$response" | grep -o '"title":"[^"]*"' | head -n1 | cut -d'"' -f4)

if [ -z "$first_product_id" ]; then
    echo -e "${RED}No products found in the store to test with${NC}"
    exit 1
fi

echo -e "${YELLOW}Found product ID $first_product_id with title: $first_product_title${NC}"

# Test the existing product
test_product "$first_product_id" "$first_product_title"

# Test product update
test_product_update "$first_product_id"

# Test product removal with the product we know exists
test_product_removal "$first_product_id"

# Count total products
count_products

echo -e "\n${YELLOW}Summary:${NC}"
echo -e "If you see green checkmarks above, the products were successfully added to the store."
echo -e "If you see red error messages, there might be issues with the product creation or retrieval."