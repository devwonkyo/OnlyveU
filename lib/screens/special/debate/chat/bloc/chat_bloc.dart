import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:onlyveyou/screens/special/debate/chat/chat_model.dart';
import 'package:onlyveyou/screens/special/debate/chat/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  ChatBloc({
    required this.chatRepository,
  }) : super(ChatLoading()) {
    on<LoadChats>(_onLoadChats);
    on<SendChat>(_onSendChat);

    add(LoadChats());
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chats = await chatRepository.getAllChats();
      emit(ChatLoaded(chats));
      print('ChatLoaded');
    } catch (e) {
      emit(const ChatError('Failed to load chats'));
    }
  }

  Future<void> _onSendChat(SendChat event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.sendChat(event.chat);
      add(LoadChats()); // 채팅을 보낸 후 채팅 목록을 다시 로드
    } catch (e) {
      emit(const ChatError('Failed to send chat'));
    }
  }
}
