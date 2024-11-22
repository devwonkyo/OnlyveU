import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/vote_model.dart';
import 'package:onlyveyou/repositories/vote_repository.dart';
import '../../../../../utils/shared_preference_util.dart';

part 'vote_event.dart';
part 'vote_state.dart';

class VoteBloc extends Bloc<VoteEvent, VoteState> {
  final VoteRepository voteRepository;

  VoteBloc({required this.voteRepository}) : super(VoteLoading()) {
    on<SubmitVote>(_onSubmitVote);
    on<LoadVotes>(_onLoadVotes);
  }

  Future<void> _onSubmitVote(SubmitVote event, Emitter<VoteState> emit) async {
    emit(VoteLoading());
    final userId = await OnlyYouSharedPreference().getCurrentUserId();
    try {
      final hasVoted = await voteRepository.hasUserVoted(userId);
      if (!hasVoted) {
        final vote = VoteModel(
          userId: userId,
          productId: event.productId,
          timestamp: Timestamp.now(),
        );
        await voteRepository.submitVote(vote);
      } else {
        emit(const VoteError('이미 투표하였습니다.'));
      }
      add(LoadVotes());
    } catch (e) {
      emit(const VoteError('Failed to submit vote'));
    }
  }

  Future<void> _onLoadVotes(LoadVotes event, Emitter<VoteState> emit) async {
    emit(VoteLoading());
    try {
      final votes = await voteRepository.getVotes();
      emit(VotesLoaded(votes));
      print('VoteLoaded');
    } catch (e) {
      emit(const VoteError('Failed to load votes'));
    }
  }
}
