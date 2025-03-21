const Cart = require("../model/cart");

module.exports.getAllCarts = (req, res) => {
	const limit = Number(req.query.limit) || 0;
	const sort = req.query.sort == "desc" ? -1 : 1;
	const startDate = req.query.startdate || new Date("1970-1-1");
	const endDate = req.query.enddate || new Date();

	console.log(startDate, endDate);

	Cart.find({
		date: { $gte: new Date(startDate), $lt: new Date(endDate) },
	})
		.select("-_id -products._id")
		.limit(limit)
		.sort({ id: sort })
		.then((carts) => {
			res.json(carts);
		})
		.catch((err) => console.log(err));
};

module.exports.getCartsbyUserid = (req, res) => {
	const userId = req.params.userid;
	const startDate = req.query.startdate || new Date("1970-1-1");
	const endDate = req.query.enddate || new Date();

	console.log(startDate, endDate);
	Cart.find({
		userId,
		date: { $gte: new Date(startDate), $lt: new Date(endDate) },
	})
		.select("-_id -products._id")
		.then((carts) => {
			res.json(carts);
		})
		.catch((err) => console.log(err));
};

module.exports.getSingleCart = (req, res) => {
	const id = req.params.id;
	Cart.findOne({
		id,
	})
		.select("-_id -products._id")
		.then((cart) => {
			if (!cart) {
				return res.status(404).json({
					status: "error",
					message: "Cart not found"
				});
			}
			res.status(200).json(cart);
		})
		.catch((err) => {
			console.log(err);
			res.status(500).json({
				status: "error",
				message: "Failed to retrieve cart",
				error: err.message
			});
		});
};

module.exports.addCart = (req, res) => {
	if (typeof req.body == undefined) {
		res.json({
			status: "error",
			message: "data is undefined",
		});
	} else {
		// Create a new Cart instance with the data from the request
		const cart = new Cart({
			id: req.body.id || Math.floor(Math.random() * 1000), // Use provided ID or generate a random one
			userId: req.body.userId,
			date: req.body.date || new Date(),
			products: req.body.products || [],
		});

		// Save the cart to the database
		cart.save()
			.then((savedCart) => {
				res.status(201).json(savedCart);
			})
			.catch((err) => {
				console.log(err);
				res.status(500).json({
					status: "error",
					message: "Failed to save cart",
					error: err.message,
				});
			});
	}
};

module.exports.editCart = (req, res) => {
	if (typeof req.body == undefined || req.params.id == null) {
		res.json({
			status: "error",
			message: "something went wrong! check your sent data",
		});
	} else {
		// Currently just returns the request data without updating the database
		// Should be updated to actually modify the cart
		Cart.findOneAndUpdate(
			{ id: parseInt(req.params.id) },
			{
				userId: req.body.userId,
				date: req.body.date,
				products: req.body.products
			},
			{ new: true, runValidators: true }
		)
		.then(updatedCart => {
			if (!updatedCart) {
				return res.status(404).json({
					status: "error",
					message: "Cart not found"
				});
			}
			res.json(updatedCart);
		})
		.catch(err => {
			console.log(err);
			res.status(500).json({
				status: "error",
				message: "Failed to update cart",
				error: err.message
			});
		});
	}
};

module.exports.deleteCart = (req, res) => {
	if (req.params.id == null) {
		return res.status(400).json({
			status: "error",
			message: "cart id should be provided",
		});
	}
	
	Cart.findOneAndDelete({ id: parseInt(req.params.id) })
		.then((deletedCart) => {
			if (!deletedCart) {
				return res.status(404).json({
					status: "error",
					message: "Cart not found"
				});
			}
			res.json({
				status: "success",
				message: "Cart deleted successfully",
				deletedCart
			});
		})
		.catch((err) => {
			console.log(err);
			res.status(500).json({
				status: "error",
				message: "Failed to delete cart",
				error: err.message
			});
		});
};
