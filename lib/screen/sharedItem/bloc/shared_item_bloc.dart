import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'shared_item_event.dart';
part 'shared_item_state.dart';

class SharedItemBloc extends Bloc<SharedItemEvent, SharedItemState> {
  SharedItemBloc() : super(SharedItemInitial()) {
    on<SharedItemEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
