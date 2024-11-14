import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

      // Firestore에서 사용자 문서 조회 (uid를 사용)
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid) // email 대신 uid 사용
          .get();

      print("Phone Number Data: ${userDoc.data()}"); // 디버깅용 로그

      if (userDoc.exists && userDoc.data()?['phone'] != null) {
        final phoneNumber = userDoc.data()!['phone'] as String;
        print("Successfully loaded phone number: $phoneNumber"); // 디버깅용 로그
        emit(PhoneNumberLoaded(phoneNumber));
      } else {
        // 사용자 문서는 있지만 전화번호가 없는 경우
        print("No phone number found in user document"); // 디버깅용 로그
        emit(PhoneNumberError("전화번호를 찾을 수 없습니다."));
      }
    } catch (e) {
      print("Error loading phone number: $e"); // 디버깅용 로그
      emit(PhoneNumberError("전화번호 로드에 실패했습니다: $e"));
    }
  }

  void _onPhoneNumberChanged(
      PhoneNumberChanged event, Emitter<PhoneNumberState> emit) {
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

      // Firestore에서 전화번호 업데이트
      await _firestore
          .collection('users')
          .doc(currentUser.uid) // email 대신 uid 사용
          .update({'phone': event.phoneNumber});

      print(
          "Successfully updated phone number: ${event.phoneNumber}"); // 디버깅용 로그
      emit(PhoneNumberLoaded(event.phoneNumber));
    } catch (e) {
      print("Error updating phone number: $e"); // 디버깅용 로그
      emit(PhoneNumberError("전화번호 변경에 실패했습니다: $e"));
    }
  }
}
