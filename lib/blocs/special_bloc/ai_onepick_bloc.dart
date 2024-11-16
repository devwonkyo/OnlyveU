import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/special/ai_onepick_repository.dart';

// 1.로딩시회색말고인공지능이생각하는걸로하기
// 2.말끊기는거해결해야함
// 3.실제태그가없어서제목에서유추해야함

// Events
abstract class AIOnepickEvent extends Equatable {
  const AIOnepickEvent();

  @override
  List<Object?> get props => [];
}

class StartChat extends AIOnepickEvent {}

class SendMessage extends AIOnepickEvent {
  final String message;
  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetChat extends AIOnepickEvent {}

// States
abstract class AIOnepickState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  const AIOnepickState({
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, errorMessage];
}

class AIOnepickInitial extends AIOnepickState {}

class AIOnepickInProgress extends AIOnepickState {
  const AIOnepickInProgress({
    super.isLoading = false,
    super.errorMessage,
  });
}

class AIOnepickComplete extends AIOnepickState {
  final ProductModel product;
  final String recommendationReason;

  const AIOnepickComplete({
    required this.product,
    required this.recommendationReason,
    super.errorMessage,
  });

  @override
  List<Object?> get props => [product, recommendationReason, errorMessage];
}

//
// Bloc
class AIOnepickBloc extends Bloc<AIOnepickEvent, AIOnepickState> {
  final AIOnepickRepository _repository;

  AIOnepickBloc({
    required AIOnepickRepository repository,
  })  : _repository = repository,
        super(AIOnepickInitial()) {
    on<StartChat>((event, emit) async {
      try {
        emit(const AIOnepickInProgress(isLoading: true));
        await _repository.startChat();
        emit(const AIOnepickInProgress());
      } catch (e) {
        emit(AIOnepickInProgress(errorMessage: e.toString()));
      }
    });

    on<SendMessage>((event, emit) async {
      try {
        emit(AIOnepickInProgress(isLoading: true));
        await _repository.handleUserMessage(event.message);

        // 5단계 대화가 완료되면 제품 추천
        if (_repository.currentStep >= 5) {
          final recommendation = await _repository.recommendProduct();
          emit(AIOnepickComplete(
            product: recommendation['product'],
            recommendationReason: recommendation['reason'],
          ));
        } else {
          emit(const AIOnepickInProgress());
        }
      } catch (e) {
        emit(AIOnepickInProgress(errorMessage: e.toString()));
      }
    });

    on<ResetChat>((event, emit) {
      _repository.resetChat();
      emit(AIOnepickInitial());
      add(StartChat());
    });
  }
}
