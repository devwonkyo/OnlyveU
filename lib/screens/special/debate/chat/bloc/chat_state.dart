part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

final class ChatLoading extends ChatState {}

final class ChatLoaded extends ChatState {
  final List<ChatModel> chats;

  const ChatLoaded(this.chats);
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
