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
			res.json(product);
		})
		.catch((err) => console.log(err));
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
		res.json({
			id: parseInt(req.params.id),
			title: req.body.title,
			price: req.body.price,
			description: req.body.description,
			image: req.body.image,
			category: req.body.category,
		});
	}
};

module.exports.deleteProduct = (req, res) => {
	if (req.params.id == null) {
		res.json({
			status: "error",
			message: "cart id should be provided",
		});
	} else {
		Product.findOne({
			id: req.params.id,
		})
			.select(["-_id"])
			.then((product) => {
				res.json(product);
			})
			.catch((err) => console.log(err));
	}
};
