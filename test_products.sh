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

# New function to test user creation
test_user_creation() {
    echo -e "Testing user creation..."
    
    response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/users" \
        -H "Content-Type: application/json" \
        -d '{
            "email": "test@example.com",
            "username": "testuser",
            "password": "test123",
            "firstname": "Test",
            "lastname": "User",
            "city": "Test City",
            "street": "123 Test St",
            "number": 42,
            "zipcode": "12345",
            "phone": "1-234-567-8900"
        }')
    
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 201 ]; then
        # Extract the user id from response and check if it's not empty
        user_id=$(echo "$response_body" | grep -o '"id":[0-9]*' | head -n1 | cut -d':' -f2)
        if [ -n "$user_id" ]; then  # Check if user_id is not empty
            echo -e "${GREEN}✓ User created successfully with ID: $user_id${NC}"
            echo "$user_id"  # Return the ID for later use
            return 0
        else
            echo -e "${RED}✗ Failed to extract user ID from response${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Failed to create user. Status code: $status_code${NC}"
        echo "Response: $response_body"
        return 1
    fi
}

# Function to test getting user data
test_get_user() {
    local id=$1
    echo -e "Testing get user ID $id..."
    
    response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/users/$id")
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 200 ]; then
        username=$(echo "$response_body" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$username" ]; then  # Check if username is not empty
            echo -e "${GREEN}✓ Successfully retrieved user $id with username: $username${NC}"
            return 0
        else
            echo -e "${RED}✗ Failed to extract username from response${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Failed to retrieve user $id. Status code: $status_code${NC}"
        echo "Response: $response_body"
        return 1
    fi
}

# Function to test user update - modify the request body to include password
test_user_update() {
    local id=$1
    echo -e "Testing update of user ID $id..."
    
    response=$(curl -s -w "\n%{http_code}" -X PUT "$BASE_URL/users/$id" \
        -H "Content-Type: application/json" \
        -d '{
            "email": "updated@example.com",
            "username": "updateduser",
            "password": "updatedpass123",
            "firstname": "Updated",
            "lastname": "User",
            "city": "Updated City",
            "street": "456 Updated St",
            "number": 43,
            "zipcode": "54321",
            "phone": "1-234-567-8901"
        }')
    
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 200 ]; then
        username=$(echo "$response_body" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$username" ]; then
            if [[ "$username" == "updateduser" ]]; then
                echo -e "${GREEN}✓ User $id was successfully updated${NC}"
                return 0
            else
                echo -e "${RED}✗ User update failed - username mismatch${NC}"
                return 1
            fi
        else
            echo -e "${RED}✗ Failed to extract username from response${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Failed to update user $id. Status code: $status_code${NC}"
        echo "Response: $response_body"
        return 1
    fi
}

# Function to test user deletion
test_user_deletion() {
    local id=$1
    echo -e "Testing deletion of user ID $id..."
    
    response=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/users/$id")
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 200 ]; then
        echo -e "${GREEN}✓ Delete request successful${NC}"
        echo "Response: $response_body"
        return 0
    else
        echo -e "${RED}✗ Failed to delete user $id. Status code: $status_code${NC}"
        echo "Response: $response_body"
        return 1
    fi
}

# Add new function to create a test product
test_product_creation() {
    echo -e "Creating a test product..."
    
    response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/products" \
        -H "Content-Type: application/json" \
        -d '{
            "title": "Test Product",
            "price": 99.99,
            "description": "A test product for API testing",
            "image": "https://example.com/test-image.jpg",
            "category": "test"
        }')
    
    status_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq 201 ]; then
        # Extract the product id from response
        product_id=$(echo "$response_body" | grep -o '"id":[0-9]*' | head -n1 | cut -d':' -f2)
        if [ -n "$product_id" ]; then
            echo -e "${GREEN}✓ Product created successfully with ID: $product_id${NC}"
            echo "$product_id"  # Return the ID for later use
            return 0
        else
            echo -e "${RED}✗ Failed to extract product ID from response${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Failed to create product. Status code: $status_code${NC}"
        echo "Response: $response_body"
        return 1
    fi
}

# Main execution
check_server

echo -e "\n${YELLOW}Testing Product API...${NC}"

# Create a test product first
echo -e "Creating test product..."
product_creation_output=$(test_product_creation)
first_product_id=$(echo "$product_creation_output" | grep -o '[0-9]*$')

if [ -n "$first_product_id" ] && [[ "$first_product_id" =~ ^[0-9]+$ ]]; then
    # Test the created product
    test_product "$first_product_id" "Test Product"
    
    # Test product update
    test_product_update "$first_product_id"
    
    # Test product removal
    test_product_removal "$first_product_id"
    
    # Count total products
    count_products
else
    echo -e "${RED}Failed to create test product, skipping product tests${NC}"
fi

# Continue with user tests...
echo -e "\n${YELLOW}Testing User API...${NC}"
# Create and test a new user
user_creation_output=$(test_user_creation)
user_id=$(echo "$user_creation_output" | grep -o '[0-9]*$')

if [ -n "$user_id" ] && [[ "$user_id" =~ ^[0-9]+$ ]]; then
    # Test getting user data
    test_get_user "$user_id"
    
    # Test updating user data
    test_user_update "$user_id"
    
    # Test user deletion
    test_user_deletion "$user_id"
else
    echo -e "${RED}Skipping user tests due to creation failure${NC}"
fi

echo -e "\n${YELLOW}Summary:${NC}"
echo -e "If you see green checkmarks above, all operations were successful."
echo -e "If you see red error messages, there might be issues with the API endpoints."