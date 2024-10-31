part of 'tag_list_cubit.dart';

class TagListState extends Equatable {
  final List<Tag> tags;
  const TagListState({
    required this.tags,
  });

  factory TagListState.initial() {
    return const TagListState(
      tags: [
        Tag(tagId: '1', name: '아이라이너'),
        Tag(tagId: '2', name: '립스틱'),
        Tag(tagId: '3', name: '파운데이션'),
        Tag(tagId: '4', name: '마스카라'),
        Tag(tagId: '5', name: '블러셔'),
        Tag(tagId: '6', name: '아이섀도우'),
        Tag(tagId: '7', name: '컨실러'),
        Tag(tagId: '8', name: '브론저'),
        Tag(tagId: '9', name: '하이라이터'),
        Tag(tagId: '10', name: '프라이머'),
        Tag(tagId: '11', name: 'BB크림'),
        Tag(tagId: '12', name: 'CC크림'),
        Tag(tagId: '13', name: '쿠션'),
        Tag(tagId: '14', name: '틴트'),
        Tag(tagId: '15', name: '립밤'),
        Tag(tagId: '16', name: '립글로스'),
        Tag(tagId: '17', name: '립라이너'),
        Tag(tagId: '18', name: '아이브로우'),
        Tag(tagId: '19', name: '아이프라이머'),
        Tag(tagId: '20', name: '아이리무버'),
        Tag(tagId: '21', name: '페이스파우더'),
        Tag(tagId: '22', name: '페이스오일'),
        Tag(tagId: '23', name: '페이스미스트'),
        Tag(tagId: '24', name: '페이스크림'),
        Tag(tagId: '25', name: '페이스로션'),
        Tag(tagId: '26', name: '페이스세럼'),
        Tag(tagId: '27', name: '페이스토너'),
        Tag(tagId: '28', name: '페이스클렌저'),
        Tag(tagId: '29', name: '페이스마스크'),
        Tag(tagId: '30', name: '페이스스크럽'),
        Tag(tagId: '31', name: '바디로션'),
        Tag(tagId: '32', name: '바디오일'),
        Tag(tagId: '33', name: '바디크림'),
        Tag(tagId: '34', name: '바디워시'),
        Tag(tagId: '35', name: '바디스크럽'),
        Tag(tagId: '36', name: '바디미스트'),
        Tag(tagId: '37', name: '바디버터'),
        Tag(tagId: '38', name: '바디파우더'),
        Tag(tagId: '39', name: '바디스프레이'),
        Tag(tagId: '40', name: '바디클렌저'),
        Tag(tagId: '41', name: '헤어샴푸'),
        Tag(tagId: '42', name: '헤어컨디셔너'),
        Tag(tagId: '43', name: '헤어마스크'),
        Tag(tagId: '44', name: '헤어오일'),
        Tag(tagId: '45', name: '헤어세럼'),
        Tag(tagId: '46', name: '헤어스프레이'),
        Tag(tagId: '47', name: '헤어젤'),
        Tag(tagId: '48', name: '헤어무스'),
        Tag(tagId: '49', name: '헤어크림'),
        Tag(tagId: '50', name: '헤어토닉'),
      ],
    );
  }

  @override
  List<Object> get props => [tags];

  @override
  String toString() => 'TagListState(todos: $tags)';

  TagListState copyWith({
    List<Tag>? tags,
  }) {
    return TagListState(
      tags: tags ?? this.tags,
    );
  }
}
