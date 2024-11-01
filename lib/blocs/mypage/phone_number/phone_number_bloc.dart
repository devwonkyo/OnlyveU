import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'phone_number_event.dart';
import 'phone_number_state.dart';

class PhoneNumberBloc extends Bloc<PhoneNumberEvent, PhoneNumberState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PhoneNumberBloc() : super(PhoneNumberInitial()) {
    on<LoadPhoneNumber>(_onLoadPhoneNumber);
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<SubmitPhoneNumberChange>(_onSubmitPhoneNumberChange);
  }

  Future<void> _onLoadPhoneNumber(
      LoadPhoneNumber event, Emitter<PhoneNumberState> emit) async {
    emit(PhoneNumberLoading());
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(PhoneNumberError("로그인이 필요합니다."));
        return;
      }

      final userDoc =
          await _firestore.collection('users').doc(currentUser.email).get();
      if (userDoc.exists) {
        final phoneNumber = userDoc.get('phone') as String;
        emit(PhoneNumberLoaded(phoneNumber));
      } else {
        emit(PhoneNumberError("전화번호를 찾을 수 없습니다."));
      }
    } catch (e) {
      emit(PhoneNumberError("전화번호 로드에 실패했습니다: $e"));
    }
  }

  void _onPhoneNumberChanged(
      PhoneNumberChanged event, Emitter<PhoneNumberState> emit) {
    // Update button enabled state based on if the phone number is not empty
    emit(PhoneNumberEditing(
        phoneNumber: event.phoneNumber,
        isButtonEnabled: event.phoneNumber.isNotEmpty));
  }

  Future<void> _onSubmitPhoneNumberChange(
      SubmitPhoneNumberChange event, Emitter<PhoneNumberState> emit) async {
    emit(PhoneNumberLoading());
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(PhoneNumberError("로그인이 필요합니다."));
        return;
      }

      // Update the phone number in Firestore
      await _firestore
          .collection('users')
          .doc(currentUser.email)
          .update({'phone': event.phoneNumber});

      emit(PhoneNumberLoaded(
          event.phoneNumber)); // Emit the new phone number state
    } catch (e) {
      emit(PhoneNumberError("전화번호 변경에 실패했습니다: $e"));
    }
  }
}
