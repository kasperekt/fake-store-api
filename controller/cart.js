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
		.then((cart) => res.json(cart))
		.catch((err) => console.log(err));
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
		res.json({
			id: parseInt(req.params.id),
			userId: req.body.userId,
			date: req.body.date,
			products: req.body.products,
		});
	}
};

module.exports.deleteCart = (req, res) => {
	if (req.params.id == null) {
		res.json({
			status: "error",
			message: "cart id should be provided",
		});
	} else {
		Cart.findOne({ id: req.params.id })
			.select("-_id -products._id")
			.then((cart) => {
				res.json(cart);
			})
			.catch((err) => console.log(err));
	}
};
