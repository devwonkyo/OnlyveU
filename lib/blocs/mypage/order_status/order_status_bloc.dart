import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_status_event.dart';
import 'order_status_state.dart';

class OrderStatusBloc extends Bloc<OrderStatusEvent, OrderStatusState> {
  OrderStatusBloc() : super(OrderStatusInitial()) {
    on<SelectPurchaseType>(_onSelectPurchaseType);
    on<SelectStatus>(_onSelectStatus);

    // Bloc이 생성될 때 기본 구매 유형과 상태 설정
    add(const SelectPurchaseType('온라인몰 구매'));
  }

  // 구매 유형 선택 시 상태 옵션 업데이트
  void _onSelectPurchaseType(
      SelectPurchaseType event, Emitter<OrderStatusState> emit) {
    List<String> statusOptions;
    String defaultStatus = '전체 상태'; // 기본값 설정

    // 구매 유형에 따라 상태 옵션 설정
    if (event.purchaseType == '온라인몰 구매') {
      statusOptions = ['전체 상태', '주문접수', '결제완료', '배송준비중', '배송중', '배송완료'];
    } else {
      statusOptions = ['전체 상태', '매장 구매완료', '매장 구매취소'];
    }

    // 상태 옵션이 업데이트될 때, 기본 선택 상태를 '전체 상태'로 초기화
    emit(
        PurchaseTypeSelected(event.purchaseType, statusOptions, defaultStatus));
  }

  // 상태 선택 시 상태 저장
  void _onSelectStatus(SelectStatus event, Emitter<OrderStatusState> emit) {
    if (state is PurchaseTypeSelected || state is StatusSelected) {
      final currentState = state as dynamic;
      emit(StatusSelected(currentState.selectedPurchaseType,
          currentState.statusOptions, event.status));
    }
  }
}
