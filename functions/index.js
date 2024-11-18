const functions = require("firebase-functions");
const admin = require("firebase-admin");


admin.initializeApp();

exports.sendPushNotification = functions.region("asia-northeast3").https.onCall(async (data, context) => {
    // 클라이언트로부터 받은 데이터
    const {token, title, body, screen} = data;
    console.log("token:", token, "title:", title, "body:", body);
    // 푸시 알림 메시지 구성
    const message = {
        notification: {
            title: title,
            body: body,
        },
        data: {
            screen: screen,
        },
        token: token,
    };

    try {
        // 푸시 알림 전송
        const response = await admin.messaging().send(message);
        console.log("Successfully sent message:", response);
        return {success: true, message: "Notification sent successfully"};
    } catch (error) {
        console.log("Error sending message:", error);
        throw new functions.https.HttpsError("internal", "Error sending push notification");
    }
});
