import 'package:onlyveyou/screens/special/debate/chat_model.dart';

abstract class ChatRepository {
  Future<List<ChatModel>> getAllChats();
  Future<void> sendChat(ChatModel chat);

  // Future<List<SuggestionModel>> search(String term);
  // Future<void> fetchAndStoreAllSuggestions();
  // Future<List<SuggestionModel>> getStoredSuggestions();
  // Future<List<SuggestionModel>> searchLocal(String term);
  // Future<void> incrementPopularity(String term, int currentPopularity);
  // Future<List<SuggestionModel>> getTrendSearches();
}
