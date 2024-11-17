import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/payment/payment_bloc.dart';
import 'package:onlyveyou/blocs/payment/payment_event.dart';
import 'package:onlyveyou/blocs/payment/payment_state.dart';
import 'package:onlyveyou/blocs/shutter/shutterpost_event.dart';
import 'package:onlyveyou/blocs/store/store_bloc.dart';
import 'package:onlyveyou/blocs/store/store_state.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/models/order_item_model.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/models/store_model.dart';
import 'package:onlyveyou/screens/payment/delivery_order_screen.dart';
import 'package:onlyveyou/screens/payment/new_delivery_address_screen.dart';
import 'package:onlyveyou/screens/payment/pickup_order_screen.dart';
import 'package:onlyveyou/utils/format_price.dart';
import 'package:onlyveyou/utils/styles.dart';

class PaymentScreen extends StatefulWidget {
  final List<String> deliveryMessages = [
    '배송 메시지를 선택해주세요.',
    '그냥 문 앞에 놓아 주시면 돼요.',
    '직접 받을게요.(부재 시 문앞)',
    '벨을 누르지 말아주세요.',
    '도착 후 전화주시면 직접 받으러 갈게요.'
  ];
  final OrderModel order;

  // 생성자에서 order 데이터를 받도록 설정
  PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  DeliveryInfoModel? _currentDeliveryInfo;
  String selectedDeliveryMessage = '배송 메시지를 선택해주세요.';
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    // 주문 상품 가져오기 이벤트 추가
    // 전달된 order 값 확인
    final bloc = context.read<PaymentBloc>();
    _currentDeliveryInfo = bloc.deliveryInfo; // 초기값 설정
    if (!_isInitialized) {
      context.read<PaymentBloc>().add(InitializePayment(widget.order));
      _isInitialized = true; // 초기화 플래그를 설정합니다.
    }

    //  context.read<PaymentBloc>().add(UpdateDeliveryInfo(  //배송지 정보 업데이트 하기 위해서
    //     deliveryName: deliveryName,
    //     address: address,
    //     detailAddress: detailAddress,
    //     recipientName: recipientName,
    //     recipientPhone: recipientPhone));
    print("Order details received:");
    print("- User ID: ${widget.order.userId}");
    print("- Order Type: ${widget.order.orderType}");
    print("- Total Items: ${widget.order.items.length}");
    print("- Total Price: ${widget.order.totalPrice}");
  }

  String _selectedPaymentMethod = '빠른결제';
  bool _saveAsDefault = false;
  bool _agreeToAll = false;

  // NewDeliveryAddressScreen으로 이동하고 데이터를 받아오기
  void _navigateToNewAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewDeliveryAddressScreen()),
    );

    if (result != null && result is DeliveryInfoModel) {
      setState(() {
        _currentDeliveryInfo = result; // 받은 데이터를 상태에 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '주문/결제',
          style: AppStyles.headingStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              height: 1,
              color: Colors.grey[400],
            ),
            // 주문 유형에 따른 UI 표시
            // 주문 유형에 따른 UI 표시
            BlocListener<PaymentBloc, PaymentState>(
              listener: (context, state) {
                if (state is DeliveryInfoUpdated) {
                  print("PaymentScreen에서 DeliveryInfoUpdated 상태를 받았습니다.");
                  setState(() {
                    state.deliveryInfo;
                  });
                }
              },
              //배송 요청사항, 배송지 등록 모두 delivery_info_updated state를 배출해주는데 배송 요청사항만 emit이 되는 상태

              //payment screen에 들어오면 기본적으로 paymentloaded state가 된다.
              //배송지를 등록하거나 배송 요청사항을 업데이트 할 때 delivery_info_updated state를 emit하게 설정했는데 요청사항만 된다
              //그래서 배송지 등록을 하고 나서 state를 print하면 paymentloaded가 유지가 된다
              //emit state한 게 적용이 잘 안 되는 것 같다. router문제? 차이는 화면이 하나 더 있다?
              child: BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  if (state is PaymentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (widget.order.orderType == OrderType.delivery) {
                    print("Curredt state: $state");
                    // _currentDeliveryInfo가 null이 아니면 업데이트된 정보를 사용
                    return DeliveryOrderInfo(
                        deliveryInfo:
                            _currentDeliveryInfo ?? state.deliveryInfo,
                        deliveryMessages: widget.deliveryMessages,
                        onAddressChange: _navigateToNewAddress, // 콜백 전달
                        onDeliveryMessageSelected: (message) {
                          setState(() {
                            selectedDeliveryMessage = message;
                          });
                        });
                  } else if (widget.order.orderType == OrderType.pickup) {
                    return const PickupOrderInfo();
                  } else {
                    return Container();
                  }
                },
              ),
            ),

            const SizedBox(height: 20),
            Divider(
              height: 1,
              color: Colors.grey[200],
              thickness: 10,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '주문 상품',
                    style: AppStyles.headingStyle,
                  ),
                  const SizedBox(height: 10),
                  // payment_screen.dart
                  // payment_screen.dart
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.order.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.order.items[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.network(item.productImageUrl,
                              fit: BoxFit.cover),
                        ),
                        title: Text(item.productName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '수량: ${item.quantity}',
                              style: AppStyles.smallTextStyle,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              '${formatPrice((item.productPrice * item.quantity).toString())}원',
                              style: AppStyles.priceTextStyle,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 5,
              color: Colors.grey[200],
            ),
            const SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  int totalAmount = widget.order.items.fold(0, (sum, item) {
                    return sum + (item.productPrice * item.quantity);
                  });

                  //totalAmount 상태관리 수정해야 한다(0원으로 뜸 )
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '최종 결제금액',
                        style: AppStyles.headingStyle,
                      ),
                      Text(
                        '${formatPrice(totalAmount.toString())}원', // formatPrice 메서드 적용
                        style: AppStyles.headingStyle,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 5,
              color: Colors.grey[200],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Text(
                '결제 수단',
                style: AppStyles.headingStyle,
              ),
            ),
            Divider(
              height: 1,
              color: Colors.grey[200],
              thickness: 1,
            ),
            const SizedBox(height: 10),

            // "빠른결제" Option
            RadioListTile(
              value: '빠른결제',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value.toString();
                });
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('빠른결제', style: AppStyles.bodyTextStyle),
                  const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                ],
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            // Card Registration Button
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.17,
                child: OutlinedButton(
                  onPressed: () {
                    // Handle card registration action
                    print("결제 카드 등록 버튼 클릭");
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        '자주 사용하는 카드나 계좌를 등록하고\n더욱 빠르게 결제할 수 있습니다.',
                        style: AppStyles.smallTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• 빠른결제 이용 시 더블적립 혜택이나 KB알파원카드 혜택은 적용되지 않습니다.',
                    style: AppStyles.smallTextStyle,
                  ),
                  Text(
                    '• 등록하신 결제수단이나 원터치결제 관리는 마이페이지 > 마이월렛 > 빠른결제 관리에서 가능합니다.',
                    style: AppStyles.smallTextStyle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // "일반결제" Option
            RadioListTile(
              value: '일반결제',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value.toString();
                });
              },
              title: Text('일반결제', style: AppStyles.bodyTextStyle),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 20),

            Divider(
              height: 1,
              color: Colors.grey[200],
              thickness: 10,
            ),

            // Agreement Checkbox
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _saveAsDefault,
                    onChanged: (value) {
                      setState(() {
                        _saveAsDefault = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '지금 설정한 배송지와 결제정보를 기본으로 사용하기',
                      style: AppStyles.bodyTextStyle,
                    ),
                  ),
                ],
              ),
            ),
            // Agree to All Checkbox
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _agreeToAll,
                    onChanged: (value) {
                      setState(() {
                        _agreeToAll = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '모두 동의합니다.',
                      style: AppStyles.bodyTextStyle,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Total Price Button
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                // default amount as 0 to avoid null issues
                int totalAmount = widget.order.items.fold(0, (sum, item) {
                  return sum + (item.productPrice * item.quantity);
                });

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: BlocBuilder<StoreBloc, StoreState>(
                      builder: (context, storeState) {
                        StoreModel? selectedStore;
                        // StoreBloc의 상태에서 선택된 매장 정보 가져오기
                        if (storeState is StoreSelected) {
                          selectedStore = storeState.selectedStore;
                        }
                        return ElevatedButton(
                          onPressed: () {
                            // 결제 버튼 로직
                            // OrderModel 생성
                            final updatedDeliveryInfo =
                                _currentDeliveryInfo != null
                                    ? DeliveryInfoModel(
                                        deliveryName:
                                            _currentDeliveryInfo!.deliveryName,
                                        address: _currentDeliveryInfo!.address,
                                        detailAddress:
                                            _currentDeliveryInfo!.detailAddress,
                                        recipientName:
                                            _currentDeliveryInfo!.recipientName,
                                        recipientPhone: _currentDeliveryInfo!
                                            .recipientPhone,
                                        deliveryRequest:
                                            selectedDeliveryMessage, // 추가
                                      )
                                    : null;
                            final order = OrderModel(
                              userId: widget.order.userId,
                              items: widget.order.items,
                              orderType: widget.order.orderType,
                              deliveryInfo: updatedDeliveryInfo,
                              status: OrderStatus.pending,
                              createdAt: DateTime.now(),
                              pickupTime: DateTime.now()
                                  .add(const Duration(hours: 3)), // 3시간 후 픽업
                              pickStore: selectedStore?.storeName, // 선택된 매장명
                              pickInfo: selectedStore, // 선택된 StoreModel
                            );

                            // SubmitOrder 이벤트를 Bloc에 전달
                            context.read<PaymentBloc>().add(SubmitOrder(order));

                            // 주문 성공 시 처리
                            context.read<PaymentBloc>().stream.listen((state) {
                              if (state is PaymentSuccess) {
                                print('주문 성공');
                                Navigator.pop(context); // 화면 닫기
                              } else if (state is PaymentError) {
                                print('주문 실패: ${state.message}');
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            '${formatPrice(totalAmount.toString())}원 결제하기',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
