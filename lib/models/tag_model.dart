import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final String tagId;
  final String name;
  const Tag({
    required this.tagId,
    required this.name,
  });

  @override
  List<Object> get props => [tagId, name];

  @override
  String toString() => 'Tag(tagId: $tagId, name: $name)';
}
