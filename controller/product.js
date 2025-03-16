const Product = require("../model/product");

module.exports.getAllProducts = (req, res) => {
	const limit = Number(req.query.limit) || 0;
	const sort = req.query.sort == "desc" ? -1 : 1;

	Product.find()
		.select(["-_id"])
		.limit(limit)
		.sort({ id: sort })
		.then((products) => {
			res.json(products);
		})
		.catch((err) => console.log(err));
};

module.exports.getProduct = (req, res) => {
	const id = req.params.id;

	Product.findOne({
		id,
	})
		.select(["-_id"])
		.then((product) => {
			if (!product) {
				return res.status(404).json({
					status: "error",
					message: "Product not found"
				});
			}
			res.json(product);
		})
		.catch((err) => {
			console.log(err);
			res.status(500).json({
				status: "error",
				message: "Server error"
			});
		});
};

module.exports.getProductCategories = (req, res) => {
	Product.distinct("category")
		.then((categories) => {
			res.json(categories);
		})
		.catch((err) => console.log(err));
};

module.exports.getProductsInCategory = (req, res) => {
	const category = req.params.category;
	const limit = Number(req.query.limit) || 0;
	const sort = req.query.sort == "desc" ? -1 : 1;

	Product.find({
		category,
	})
		.select(["-_id"])
		.limit(limit)
		.sort({ id: sort })
		.then((products) => {
			res.json(products);
		})
		.catch((err) => console.log(err));
};

module.exports.addProduct = (req, res) => {
	if (typeof req.body == undefined) {
		res.json({
			status: "error",
			message: "data is undefined",
		});
	} else {
		// Create a new Product instance with the data from the request
		const product = new Product({
			id: req.body.id || Math.floor(Math.random() * 1000), // Use provided ID or generate a random one
			title: req.body.title,
			price: req.body.price,
			description: req.body.description,
			image: req.body.image,
			category: req.body.category,
		});

		// Save the product to the database
		product
			.save()
			.then((savedProduct) => {
				res.status(201).json(savedProduct);
			})
			.catch((err) => {
				console.log(err);
				res.status(500).json({
					status: "error",
					message: "Failed to save product",
					error: err.message,
				});
			});
	}
};

module.exports.editProduct = (req, res) => {
	if (typeof req.body == undefined || req.params.id == null) {
		res.json({
			status: "error",
			message: "something went wrong! check your sent data",
		});
	} else {
		const id = parseInt(req.params.id);
		
		// Create an object with the updated fields
		const updatedProduct = {
			title: req.body.title,
			price: req.body.price,
			description: req.body.description,
			image: req.body.image,
			category: req.body.category,
		};
		
		// Find the product by id and update it
		Product.findOneAndUpdate(
			{ id: id },
			updatedProduct,
			{ new: true, runValidators: true }
		)
			.then((product) => {
				if (!product) {
					return res.status(404).json({
						status: "error",
						message: "Product not found",
					});
				}
				res.status(200).json(product);
			})
			.catch((err) => {
				console.log(err);
				res.status(500).json({
					status: "error",
					message: "Failed to update product",
					error: err.message,
				});
			});
	}
};

module.exports.deleteProduct = (req, res) => {
	const id = req.params.id;
	console.log(`Attempting to delete product with ID: ${id}`);

	if (!id) {
		console.log('Delete request received with no ID');
		return res.status(400).json({
			status: "error",
			message: "Product ID must be provided"
		});
	}

	Product.findOneAndDelete({ id: Number(id) })  // Convert id to Number since it's stored as Number in schema
		.then((deletedProduct) => {
			if (deletedProduct) {
				console.log(`Successfully deleted product: ${JSON.stringify(deletedProduct)}`);
				res.status(200).json({
					status: "success",
					message: "Product deleted successfully",
					deletedProduct: {
						id: deletedProduct.id,
						title: deletedProduct.title
					}
				});
			} else {
				console.log(`No product found with ID: ${id}`);
				res.status(404).json({
					status: "error",
					message: "Product not found"
				});
			}
		})
		.catch((err) => {
			console.error(`Error deleting product with ID ${id}:`, err);
			res.status(500).json({
				status: "error",
				message: "Failed to delete product",
				error: err.message
			});
		});
};
