const admin = require("firebase-admin");

admin.initializeApp();

exports.onUserCreate = require("./src/auth/onUserCreate");
