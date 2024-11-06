import 'package:equatable/equatable.dart';

class ShutterState extends Equatable {
  final String selectedTag;
  final List<String> images;

  const ShutterState({
    required this.selectedTag,
    this.images = const [], // 기본값으로 빈 리스트 할당
  });

  ShutterState copyWith({
    String? selectedTag,
    List<String>? images,
  }) {
    return ShutterState(
      selectedTag: selectedTag ?? this.selectedTag,
      images: images ?? this.images,
    );
  }

  @override
  List<Object> get props => [selectedTag, images];
}
