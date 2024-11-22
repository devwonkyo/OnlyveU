import 'package:cloud_firestore/cloud_firestore.dart';
import 'vote_model.dart';

class VoteRepository {
  final CollectionReference voteCollection =
      FirebaseFirestore.instance.collection('votes');

  Future<void> submitVote(VoteModel vote) async {
    await voteCollection.add(vote.toMap());
  }

  Future<List<VoteModel>> getVotes() async {
    QuerySnapshot snapshot = await voteCollection.get();
    return snapshot.docs.map((doc) => VoteModel.fromFirestore(doc)).toList();
  }

  Future<bool> hasUserVoted(String userId) async {
    final querySnapshot =
        await voteCollection.where('userId', isEqualTo: userId).get();
    return querySnapshot.docs.isNotEmpty;
  }
}
