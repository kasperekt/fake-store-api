const User = require("../model/user");

module.exports.getAllUser = (req, res) => {
	const limit = Number(req.query.limit) || 0;
	const sort = req.query.sort == "desc" ? -1 : 1;

	User.find()
		.select(["-_id"])
		.limit(limit)
		.sort({
			id: sort,
		})
		.then((users) => {
			res.json(users);
		})
		.catch((err) => console.log(err));
};

module.exports.getUser = (req, res) => {
	const id = req.params.id;

	User.findOne({
		id,
	})
		.select(["-_id"])
		.then((user) => {
			res.json(user);
		})
		.catch((err) => console.log(err));
};

module.exports.addUser = (req, res) => {
	if (typeof req.body == undefined) {
		res.json({
			status: "error",
			message: "data is undefined",
		});
	} else {
		User.countDocuments()
			.then((userCount) => {
				const user = new User({
					id: userCount + 1,
					email: req.body.email,
					username: req.body.username,
					password: req.body.password,
					name: {
						firstname:
							req.body.name?.firstname || req.body.firstname,
						lastname: req.body.name?.lastname || req.body.lastname,
					},
					address: {
						city: req.body.address?.city,
						street: req.body.address?.street,
						number: req.body.address?.number || req.body.number,
						zipcode: req.body.address?.zipcode || req.body.zipcode,
						geolocation: {
							lat: req.body.address?.geolocation?.lat || "",
							long: req.body.address?.geolocation?.long || "",
						},
					},
					phone: req.body.phone,
				});

				return user.save();
			})
			.then((savedUser) => {
				res.status(201).json(savedUser);
			})
			.catch((err) => {
				console.log(err);
				res.status(500).json({
					status: "error",
					message: "Failed to save user",
					error: err.message,
				});
			});
	}
};

module.exports.editUser = (req, res) => {
	if (typeof req.body == undefined || req.params.id == null) {
		res.json({
			status: "error",
			message: "something went wrong! check your sent data",
		});
	} else {
		res.json({
			id: parseInt(req.params.id),
			email: req.body.email,
			username: req.body.username,
			password: req.body.password,
			name: {
				firstname: req.body.firstname,
				lastname: req.body.lastname,
			},
			address: {
				city: req.body.address.city,
				street: req.body.address.street,
				number: req.body.number,
				zipcode: req.body.zipcode,
				geolocation: {
					lat: req.body.address.geolocation.lat,
					long: req.body.address.geolocation.long,
				},
			},
			phone: req.body.phone,
		});
	}
};

module.exports.deleteUser = (req, res) => {
	if (req.params.id == null) {
		res.json({
			status: "error",
			message: "cart id should be provided",
		});
	} else {
		User.findOne({ id: req.params.id })
			.select(["-_id"])
			.then((user) => {
				res.json(user);
			})
			.catch((err) => console.log(err));
	}
};
