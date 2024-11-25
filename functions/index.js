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


exports.sendPushOnStatusChange = functions.firestore
    .document("orders/{orderId}")
    .onUpdate(async (change, context) => {
        const beforeData = change.before.data();
        const afterData = change.after.data();

        // 관심있는 상태 변경인지 체크
        const targetStatuses = ["readyForPickup", "shipping", "delivered"];
        if (!targetStatuses.includes(afterData.status)) {
            console.log("Status change not in target statuses:", afterData.status);
            return null;
        }

        // status가 변경되지 않았다면 함수를 종료
        if (beforeData.status === afterData.status) {
            return null;
        }

        try {
            const userSnapshot = await admin.firestore()
                .collection("users")
                .doc(afterData.userId)
                .get();

            const userFcmToken = userSnapshot.data().token;

            if (!userFcmToken) {
                console.log("No FCM token found for user:", afterData.userId);
                return null;
            }

            // 상태별 메시지 포맷 생성
            const getMessageByStatus = (status, items) => {
                if (!items || items.length === 0) {
                    return null; // items가 없는 경우 푸시 발송하지 않음
                }

                // 상품명 말줄임표 처리 함수
                    const truncateProductName = (name) => {
                        return name.length > 20 ?
                            `${name.slice(0, 20)}...` :
                            name;
                    };

                    const productText = items.length === 1 ?
                        truncateProductName(items[0].productName) :
                        `${truncateProductName(items[0].productName)} 외 ${items.length - 1}건`;

                switch (status) {
                    case "readyForPickup":
                        return `${productText} 상품의 픽업 준비가 완료되었습니다.`;
                    case "shipping":
                        return `${productText} 상품이 배송중입니다.`;
                    case "delivered":
                        return `${productText} 상품이 배송 완료되었습니다.`;
                    default:
                        return null; // 다른 상태는 푸시 발송하지 않음
                }
            };

            const messageBody = getMessageByStatus(afterData.status, afterData.items);

            // messageBody가 null이면 푸시를 보내지 않음
            if (!messageBody) {
                console.log("No message to send for status:", afterData.status);
                return null;
            }

            // 푸시 알림 메시지를 구성합니다
            const message = {
                notification: {
                    title: "알림",
                    body: messageBody,
                },
                data: {
                    screen: "/order-status",
                },
                token: userFcmToken,
            };

            // 푸시 알림을 전송합니다
            const response = await admin.messaging().send(message);
            console.log("Successfully sent message:", response);

            return response;
        } catch (error) {
            console.error("Error sending push notification:", error);
            return null;
        }
    });
