import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/chat_model.dart';

class ChatRepository {
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');

  Future<List<ChatModel>> getAllChats() async {
    QuerySnapshot snapshot =
        await chatCollection.orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
  }

  Future<void> sendChat(ChatModel chat) async {
    await chatCollection.add(chat.toMap());
  }
}
