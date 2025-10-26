const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Trigger: When a new user is created
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  const userRef = db.collection("users").doc(user.uid);
  const userData = {
    email: user.email || null,
    role: "student",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await userRef.set(userData);
  console.log(`✅ User document created for ${user.uid}`);
});

// Trigger: When a user is deleted
exports.onUserDelete = functions.auth.user().onDelete(async (user) => {
  const uid = user.uid;
  await db.collection("users").doc(uid).delete();
  console.log(`🗑️ Deleted Firestore user doc for ${uid}`);

  const driverRef = db.collection("drivers").doc(uid);
  const driverDoc = await driverRef.get();
  if (driverDoc.exists) {
    await driverRef.delete();
    console.log(`🗑️ Deleted driver doc for ${uid}`);
  }
});
