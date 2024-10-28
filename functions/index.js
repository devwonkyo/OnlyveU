const functions = require("firebase-functions");

exports.helloWorld = functions.region("asia-northeast3").https.onRequest((request, response) => {
    response.send("Hello from Firebase!");
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
