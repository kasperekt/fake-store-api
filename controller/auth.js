const User = require('../model/user');
const jwt = require('jsonwebtoken');

module.exports.login = (req, res) => {
	const { username, password } = req.body;
	
	if (!username || !password) {
		return res.status(400).json({
			status: "error",
			message: "Username and password are required"
		});
	}

	User.findOne({
		username: username,
		password: password,
	})
		.then((user) => {
			if (user) {
				const token = jwt.sign(
					{ 
						userId: user.id,
						username: user.username 
					}, 
					'secret_key',
					{ expiresIn: '24h' }
				);
				
				res.json({
					status: "success",
					token,
					user: {
						id: user.id,
						username: user.username,
						email: user.email
					}
				});
			} else {
				res.status(401).json({
					status: "error",
					message: "Invalid username or password"
				});
			}
		})
		.catch((err) => {
			console.error(err);
			res.status(500).json({
				status: "error",
				message: "Server error",
				error: err.message
			});
		});
};
