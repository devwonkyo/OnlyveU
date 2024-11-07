import 'package:flutter_bloc/flutter_bloc.dart';
import 'shutter_event.dart';
import 'shutter_state.dart';

class ShutterBloc extends Bloc<ShutterEvent, ShutterState> {
  ShutterBloc()
      : super(const ShutterState(selectedTag: '#데일리메이크업', images: [])) {
    on<TagSelected>((event, emit) {
      List<String> images = _getImagesForTag(event.tag);
      emit(state.copyWith(selectedTag: event.tag, images: images));
    });
  }

  List<String> _getImagesForTag(String tag) {
    switch (tag) {
      case '#데일리메이크업':
        return [
          'assets/image/shutter/daily1.jpeg',
          'assets/image/shutter/daily2.jpeg',
          'assets/image/shutter/daily3.jpeg',
          'assets/image/shutter/daily4.jpeg',
        ];
      case '#틴트':
        return [
          'assets/image/shutter/tint1.jpeg',
          'assets/image/shutter/tint2.jpeg',
          'assets/image/shutter/tint3.jpeg',
          'assets/image/shutter/tint4.jpeg',
        ];
      case '#홈케어':
        return [
          'assets/image/shutter/homecare1.jpeg',
          'assets/image/shutter/homecare2.jpeg',
          'assets/image/shutter/homecare3.jpeg',
          'assets/image/shutter/homecare4.jpeg',
        ];
      case '#건강관리':
        return [
          'assets/image/shutter/health1.jpeg',
          'assets/image/shutter/health2.jpeg',
          'assets/image/shutter/health3.jpeg',
          'assets/image/shutter/health4.jpeg',
        ];
      default:
        return [];
    }
  }
}
