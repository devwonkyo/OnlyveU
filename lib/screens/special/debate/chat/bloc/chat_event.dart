part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

final class LoadChats extends ChatEvent {}

final class SendChat extends ChatEvent {
  final ChatModel chat;

  const SendChat({required this.chat});
}
