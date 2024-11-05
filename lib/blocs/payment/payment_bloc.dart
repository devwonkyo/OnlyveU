import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitial()) {
    on<SelectDeliveryMessage>((event, emit) {
      emit(PaymentMessageSelected(event.message));
    });
  }
}
