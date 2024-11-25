part of 'vote_bloc.dart';

abstract class VoteEvent extends Equatable {
  const VoteEvent();

  @override
  List<Object> get props => [];
}

class SubmitVote extends VoteEvent {
  final String productId;

  const SubmitVote({
    required this.productId,
  });

  @override
  List<Object> get props => [productId];
}

class LoadVotes extends VoteEvent {}
