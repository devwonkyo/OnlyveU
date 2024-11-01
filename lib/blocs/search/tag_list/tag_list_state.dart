part of 'tag_list_cubit.dart';

class TagListState extends Equatable {
  final List<SuggestionModel> tags;
  const TagListState({
    required this.tags,
  });

  factory TagListState.initial() {
    return const TagListState(
      tags: [
        SuggestionModel(term: '1', category: '아이라이너'),
        SuggestionModel(term: '2', category: '립스틱'),
        SuggestionModel(term: '3', category: '파운데이션'),
        SuggestionModel(term: '4', category: '마스카라'),
        SuggestionModel(term: '5', category: '블러셔'),
        SuggestionModel(term: '6', category: '아이섀도우'),
        SuggestionModel(term: '7', category: '컨실러'),
        SuggestionModel(term: '8', category: '브론저'),
        SuggestionModel(term: '9', category: '하이라이터'),
        SuggestionModel(term: '10', category: '프라이머'),
        SuggestionModel(term: '11', category: 'BB크림'),
        SuggestionModel(term: '12', category: 'CC크림'),
        SuggestionModel(term: '13', category: '쿠션'),
        SuggestionModel(term: '14', category: '틴트'),
        SuggestionModel(term: '15', category: '립밤'),
        SuggestionModel(term: '16', category: '립글로스'),
        SuggestionModel(term: '17', category: '립라이너'),
        SuggestionModel(term: '18', category: '아이브로우'),
        SuggestionModel(term: '19', category: '아이프라이머'),
        SuggestionModel(term: '20', category: '아이리무버'),
        SuggestionModel(term: '21', category: '페이스파우더'),
        SuggestionModel(term: '22', category: '페이스오일'),
        SuggestionModel(term: '23', category: '페이스미스트'),
        SuggestionModel(term: '24', category: '페이스크림'),
        SuggestionModel(term: '25', category: '페이스로션'),
        SuggestionModel(term: '26', category: '페이스세럼'),
        SuggestionModel(term: '27', category: '페이스토너'),
        SuggestionModel(term: '28', category: '페이스클렌저'),
        SuggestionModel(term: '29', category: '페이스마스크'),
        SuggestionModel(term: '30', category: '페이스스크럽'),
        SuggestionModel(term: '31', category: '바디로션'),
        SuggestionModel(term: '32', category: '바디오일'),
        SuggestionModel(term: '33', category: '바디크림'),
        SuggestionModel(term: '34', category: '바디워시'),
        SuggestionModel(term: '35', category: '바디스크럽'),
        SuggestionModel(term: '36', category: '바디미스트'),
        SuggestionModel(term: '37', category: '바디버터'),
        SuggestionModel(term: '38', category: '바디파우더'),
        SuggestionModel(term: '39', category: '바디스프레이'),
        SuggestionModel(term: '40', category: '바디클렌저'),
        SuggestionModel(term: '41', category: '헤어샴푸'),
        SuggestionModel(term: '42', category: '헤어컨디셔너'),
        SuggestionModel(term: '43', category: '헤어마스크'),
        SuggestionModel(term: '44', category: '헤어오일'),
        SuggestionModel(term: '45', category: '헤어세럼'),
        SuggestionModel(term: '46', category: '헤어스프레이'),
        SuggestionModel(term: '47', category: '헤어젤'),
        SuggestionModel(term: '48', category: '헤어무스'),
        SuggestionModel(term: '49', category: '헤어크림'),
        SuggestionModel(term: '50', category: '헤어토닉'),
      ],
    );
  }

  @override
  List<Object> get props => [tags];

  @override
  String toString() => 'TagListState(tags: $tags)';

  TagListState copyWith({
    List<SuggestionModel>? tags,
  }) {
    return TagListState(
      tags: tags ?? this.tags,
    );
  }
}
