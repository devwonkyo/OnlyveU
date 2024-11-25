part of 'vote_bloc.dart';

abstract class VoteState extends Equatable {
  const VoteState();

  @override
  List<Object> get props => [];
}

class VoteInitial extends VoteState {}

class VoteLoading extends VoteState {}

class VotesLoaded extends VoteState {
  final List<VoteModel> votes;

  const VotesLoaded(this.votes);

  @override
  List<Object> get props => [votes];
}

class VoteError extends VoteState {
  final String message;

  const VoteError(this.message);

  @override
  List<Object> get props => [message];
}
