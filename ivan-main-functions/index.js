const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();

/**
 * Trigger: When a new user is created in Firebase Authentication.
 */
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  try {
    const userRef = db.collection("users").doc(user.uid);

    // Define base user data
    const userData = {
      email: user.email || null,
      role: "student", // default role (can be changed later)
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Add user document to Firestore
    await userRef.set(userData);
    console.log(`User doc created for ${user.uid}`);

    // If driver, also create a driver doc
    if (userData.role === "driver") {
      await db.collection("drivers").doc(user.uid).set({
        isActive: false,
        lastUpdated: null,
      });
      console.log(`Driver doc created for ${user.uid}`);
    }
  } catch (error) {
    console.error("Error creating Firestore user:", error);
  }
});

/**
 * Trigger: When a Firebase user is deleted.
 */
exports.onUserDelete = functions.auth.user().onDelete(async (user) => {
  try {
    const uid = user.uid;

    // Delete from users collection
    await db.collection("users").doc(uid).delete();
    console.log(`Deleted user doc for ${uid}`);

    // Delete from drivers collection if exists
    const driverRef = db.collection("drivers").doc(uid);
    const driverDoc = await driverRef.get();

    if (driverDoc.exists) {
      await driverRef.delete();
      console.log(`Deleted driver doc for ${uid}`);
    }

    // TODO: Optionally remove from route.studentIds array later
  } catch (error) {
    console.error("Error cleaning up deleted user:", error);
  }
});
