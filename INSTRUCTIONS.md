# Database Setup Instructions for Fake Store API

This document provides instructions on how to set up and configure the database for the Fake Store API application.

## Prerequisites

Before setting up the database, ensure you have the following installed:
- MongoDB (version 4.4 or higher)
- Node.js (version 14 or higher)
- npm (version 6 or higher)

## Option 1: Using Docker (Recommended)

The easiest way to set up the database is using Docker and the provided docker-compose file.

### Steps:

1. **Install Docker and Docker Compose**
   - Follow the instructions at [Docker's official website](https://docs.docker.com/get-docker/)
   - Make sure Docker Compose is also installed

2. **Start the MongoDB container**
   ```bash
   docker compose up
   ```
   This will start MongoDB in a container and create a volume for persistent data storage.

3. **Verify the MongoDB container is running**
   ```bash
   docker ps
   ```
   You should see a MongoDB container running.

## Configuring the Application

1. **Set up environment variables**
   Make sure your `.env` file contains the correct MongoDB connection string:

   ```
   DATABASE_URL=mongodb://localhost:27017/fake_store_db
   PORT=8765
   ```

   Adjust the connection string if you're using a different MongoDB setup.

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the application**
   ```bash
   npm start
   ```

4. **Populate the database**
   Run the provided script to populate the database with sample data:
   ```bash
   chmod +x populate_store.sh
   ./populate_store.sh
   ```

## Verifying the Setup

To verify that your database is set up correctly:

1. **Check if the server is running**
   ```bash
   curl http://localhost:8765
   ```
   You should receive a response from the server.

2. **Test the API endpoints**
   ```bash
   curl http://localhost:8765/products
   ```
   This should return a list of products if the database is populated correctly.

3. **Run the test script**
   ```bash
   chmod +x test_products.sh
   ./test_products.sh
   ```
   This script will verify if products were successfully added to the database.

## Troubleshooting

If you encounter issues with the database setup:

1. **Check MongoDB connection**
   - Verify MongoDB is running: `mongo --eval "db.version()"`
   - Check the connection string in your `.env` file

2. **Check application logs**
   - Look for error messages in the console when starting the application

3. **Verify network settings**
   - If using Docker, ensure ports are properly mapped
   - Check if any firewall is blocking the MongoDB port (default: 27017)

4. **Reset the database**
   If you need to start fresh:
   ```bash
   mongo
   > use fake_store_db
   > db.dropDatabase()
   ```
   Then run the populate script again.

## Database Schema

The Fake Store API uses the following collections:

1. **Products**
   - id: Number (unique identifier)
   - title: String
   - price: Number
   - description: String
   - image: String (URL)
   - category: String

2. **Users**
   - id: Number (unique identifier)
   - email: String
   - username: String
   - password: String
   - name: Object (firstname, lastname)
   - address: Object (city, street, number, zipcode, geolocation)
   - phone: String

3. **Carts**
   - id: Number (unique identifier)
   - userId: Number (reference to User)
   - date: Date
   - products: Array of Objects (productId, quantity)

## Backup and Restore

To backup your MongoDB database:
```bash
mongodump --db fake_store_db --out ./backup
```

To restore from a backup:
```bash
mongorestore --db fake_store_db ./backup/fake_store_db
```
```

These files provide an enhanced `populate_store.sh` script with 10 examples of products, users, and carts, as well as comprehensive instructions for setting up the database in a new Markdown file called `DATABASE_SETUP.md`.