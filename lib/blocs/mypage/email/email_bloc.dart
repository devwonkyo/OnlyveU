import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_event.dart';
import 'email_state.dart';

class EmailBloc extends Bloc<EmailEvent, EmailState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EmailBloc() : super(EmailInitial()) {
    on<LoadEmail>(_onLoadEmail);
  }

  Future<void> _onLoadEmail(LoadEmail event, Emitter<EmailState> emit) async {
    emit(EmailLoading());
    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        if (currentUser.email != null) {
          emit(EmailLoaded(currentUser.email!));
          return;
        }

        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        final email = userDoc.data()?['email'] as String?;
        if (email != null) {
          emit(EmailLoaded(email));
        } else {
          emit(EmailError("Email not found in Firestore."));
        }
      } else {
        emit(EmailError("User not logged in."));
      }
    } catch (e) {
      emit(EmailError("Failed to load email: $e"));
    }
  }
}
