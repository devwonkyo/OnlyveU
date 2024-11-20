import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/special/ai_onepick_repository.dart';

///블럭에는 주로 초기화 관련한 작업을 함
/// AIOnepickBloc: AI Onepick 대화 흐름을 관리하는 Bloc입니다.
///
/// 기능 요구 사항:
/// 1. 로딩 중 회색 상태 대신 "AI가 생각하는 중"이라는 상태를 표현.
/// 2. AI 응답 메시지의 말 끊김 문제 해결.
/// 3. 태그가 없기 때문에 제목에서 유추해 데이터를 제공해야 함.

// Events: Bloc에서 처리할 이벤트를 정의합니다.
abstract class AIOnepickEvent extends Equatable {
  const AIOnepickEvent();

  @override
  List<Object?> get props => [];
}

// 대화를 시작하는 이벤트
class StartChat extends AIOnepickEvent {}

// 사용자 메시지를 전송하는 이벤트
class SendMessage extends AIOnepickEvent {
  final String message; // 전송할 메시지
  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

// 대화를 초기화하는 이벤트
class ResetChat extends AIOnepickEvent {}

// States: Bloc에서 사용할 상태를 정의합니다.
abstract class AIOnepickState extends Equatable {
  final bool isLoading; // 로딩 상태
  final String? errorMessage; // 에러 메시지

  const AIOnepickState({
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, errorMessage];
}

// 초기 상태
class AIOnepickInitial extends AIOnepickState {}

// 대화가 진행 중인 상태
class AIOnepickInProgress extends AIOnepickState {
  const AIOnepickInProgress({
    super.isLoading = false,
    super.errorMessage,
  });
}

// 대화가 완료되고 추천 결과를 제공하는 상태
class AIOnepickComplete extends AIOnepickState {
  final ProductModel product; // 추천된 상품 정보
  final String recommendationReason; // 추천 이유

  const AIOnepickComplete({
    required this.product,
    required this.recommendationReason,
    super.errorMessage,
  });

  @override
  List<Object?> get props => [product, recommendationReason, errorMessage];
}

////////////////////////////
// Bloc: 이벤트를 처리하여 상태를 변경합니다.
class AIOnepickBloc extends Bloc<AIOnepickEvent, AIOnepickState> {
  final AIOnepickRepository _repository; // 대화 로직 및 데이터 처리를 위한 레포지토리

  AIOnepickBloc({
    required AIOnepickRepository repository,
  })  : _repository = repository,
        super(AIOnepickInitial()) {
    // 대화 시작 이벤트 처리
    on<StartChat>((event, emit) async {
      try {
        emit(const AIOnepickInProgress(isLoading: true)); // 로딩 상태로 전환
        await _repository.startChat(); // 대화 초기화 처리
        emit(const AIOnepickInProgress()); // 로딩 완료 후 진행 상태
      } catch (e) {
        emit(AIOnepickInProgress(errorMessage: e.toString())); // 에러 처리
      }
    });

    // 메시지 전송 이벤트 처리
    on<SendMessage>((event, emit) async {
      try {
        emit(AIOnepickInProgress(isLoading: true)); // 로딩 상태로 전환
        await _repository.handleUserMessage(event.message); // 사용자 메시지 처리

        // 5단계 대화가 완료되었는지 확인 - 5단계되면 여기서 카드 띄울라고
        if (_repository.currentStep >= 5) {
          final recommendation =
              await _repository.recommendProduct(); // 추천 결과 가져오기
          emit(AIOnepickComplete(
            product: recommendation['product'], // 추천된 상품
            recommendationReason: recommendation['reason'], // 추천 이유
          ));
        } else {
          emit(const AIOnepickInProgress()); // 진행 상태 유지
        }
      } catch (e) {
        emit(AIOnepickInProgress(errorMessage: e.toString())); // 에러 처리
      }
    });

    // 대화 초기화 이벤트 처리
    on<ResetChat>((event, emit) {
      _repository.resetChat(); // 레포지토리의 대화 초기화
      emit(AIOnepickInitial()); // 초기 상태로 전환
      add(StartChat()); // 대화 시작 이벤트 트리거
    });
  }
}
