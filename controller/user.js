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

	User.findOne({ id })
		.select(["-_id"])
		.then((user) => {
			if (!user) {
				return res.status(404).json({
					status: "error",
					message: "User not found"
				});
			}
			res.json(user);
		})
		.catch((err) => {
			console.log(err);
			res.status(500).json({
				status: "error",
				message: "Server error",
				error: err.message
			});
		});
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
		const updateData = {
			email: req.body.email,
			username: req.body.username,
			password: req.body.password,
			name: {
				firstname: req.body.name?.firstname || req.body.firstname,
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
		};

		User.findOneAndUpdate(
			{ id: parseInt(req.params.id) },
			updateData,
			{ new: true, runValidators: true }
		)
			.then((updatedUser) => {
				if (!updatedUser) {
					return res.status(404).json({
						status: "error",
						message: "User not found",
					});
				}
				res.json(updatedUser);
			})
			.catch((err) => {
				console.log(err);
				res.status(500).json({
					status: "error",
					message: "Failed to update user",
					error: err.message,
				});
			});
	}
};

module.exports.deleteUser = (req, res) => {
	if (req.params.id == null) {
		return res.status(400).json({
			status: "error",
			message: "User ID must be provided",
		});
	}

	User.findOneAndDelete({ id: parseInt(req.params.id) })
		.then((deletedUser) => {
			if (!deletedUser) {
				return res.status(404).json({
					status: "error",
					message: "User not found"
				});
			}
			res.json({
				status: "success",
				message: "User deleted successfully",
				deletedUser
			});
		})
		.catch((err) => {
			console.log(err);
			res.status(500).json({
				status: "error",
				message: "Failed to delete user",
				error: err.message
			});
		});
};
