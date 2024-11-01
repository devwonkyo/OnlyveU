import 'package:equatable/equatable.dart'; //값 기반 비교 (불필요한 상태 변화와 그로 인한 UI 업데이트를 방지)
import 'dart:io';

abstract class ProfileEditEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

//이미지 고르는 이벤트
class PickProfileImage extends ProfileEditEvent {}

//이미지 저장하는 이벤트
class SaveProfileImage extends ProfileEditEvent {
  final File image;

  SaveProfileImage(this.image);

  @override
  List<Object?> get props => [image]; //props: 객체의 동등성을 판단하기 위한 리스트
  //props에 포함된 속성들의 값이 같으면, equatable은 두 객체를 같은 객체로 간주
  //이 코드에서는 이미지가 같다면 같은 객체로 인식해서 재렌더링 방지 -> 앱 성능 최적화
}

// 이메일을 불러오는 이벤트 추가
class LoadEmail extends ProfileEditEvent {}
