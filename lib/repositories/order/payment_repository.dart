import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';

import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';

class PaymentRepository {
  final PaymentWidget paymentWidget;

  PaymentRepository()
      : paymentWidget = PaymentWidget(
          clientKey: dotenv.env['TOSS_CLIENT_KEY']!,
          customerKey: 'customer_key', // 필요에 따라 설정
        );

  // Future<void> processPayment({
  //   required String orderId,
  //   required String orderName,
  //   required int amount,
  //   required Function(String paymentKey, String orderId, int amount) onSuccess,
  //   required Function(String code, String message) onFail,
  // }) async {
  //   try {
  //     await paymentWidget.requestPayment(
  //       paymentInfo: PaymentInfo(
  //         orderId: orderId,
  //         orderName: orderName,
  //         amount: Amount(
  //           value: amount,
  //           currency: Currency.KRW,
  //           country: "KR",
  //         ),
  //         successUrl: dotenv.env['TOSS_SUCCESS_URL']!,
  //         failUrl: dotenv.env['TOSS_FAIL_URL']!,
  //       ),
  //       onSuccess: (String paymentKey, String orderId, int amount) {
  //         // 결제 성공 콜백
  //         onSuccess(paymentKey, orderId, amount);
  //       },
  //       onFail: (String code, String message) {
  //         // 결제 실패 콜백
  //         onFail(code, message);
  //       },
  //     );
  //   } catch (e) {
  //     throw Exception('결제 처리 중 오류 발생: $e');
  //   }
  // }
}
