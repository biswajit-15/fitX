const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

module.exports = functions.auth.user().onCreate(async (user) => {
  const uid = user.uid;
  const updates = {};
  updates[`users/${uid}/auth`] = {
    uid: uid,
    email: user.email || "",
    phone: user.phoneNumber || "",
    provider: user.providerData.map((p) => p.providerId),
    emailVerified: user.emailVerified || false,
    role: "user",
    isActive: true,
    createdAt: admin.database.ServerValue.TIMESTAMP,
    updatedAt: admin.database.ServerValue.TIMESTAMP,
  };
  updates[`users/${uid}/profile`]= {
    name: user.displayName||"",
    photoUrl: user.photoURL||"",
    age: "",
    gender: "",
    height: "",
    weight: "",
    goal: "",
    dietType: "",
    profileCompleted: false,
  };
  await admin.database().ref().update(updates);
  return null;
});
